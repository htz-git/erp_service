package com.erplist.replenishment.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.erplist.common.result.Result;
import com.erplist.replenishment.dto.ReplenishmentOrderDTO;
import com.erplist.replenishment.dto.ReplenishmentOrderQueryDTO;
import com.erplist.replenishment.dto.ReplenishmentSuggestionDTO;
import com.erplist.replenishment.dto.ReplenishmentSuggestionQueryDTO;
import com.erplist.replenishment.dto.ForecastMetricsResultDTO;
import com.erplist.replenishment.entity.ReplenishmentItem;
import com.erplist.replenishment.entity.ReplenishmentOrder;
import com.erplist.replenishment.service.ReplenishmentOrderService;
import com.erplist.replenishment.service.ReplenishmentSuggestionService;
import com.erplist.replenishment.service.LstmForecastService;
import com.erplist.api.client.OrderClient;
import com.erplist.api.dto.SalesTimeSeriesItemDTO;
import com.erplist.common.utils.UserContext;
import com.erplist.common.exception.BusinessException;
import lombok.RequiredArgsConstructor;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.*;
import java.util.stream.Collectors;
import java.time.LocalDate;
import org.springframework.util.StringUtils;

/**
 * 补货控制器（/replenishments，与网关 /api/replenishments 对应）
 */
@RestController
@RequestMapping("/replenishments")
@RequiredArgsConstructor
public class ReplenishmentController {

    private final ReplenishmentOrderService replenishmentOrderService;
    private final ReplenishmentSuggestionService replenishmentSuggestionService;
    private final OrderClient orderClient;
    private final LstmForecastService lstmForecastService;

    @PostMapping
    public Result<ReplenishmentOrder> create(@Validated @RequestBody ReplenishmentOrderDTO dto) {
        ReplenishmentOrder order = replenishmentOrderService.createReplenishmentOrder(dto);
        return Result.success(order);
    }

    @GetMapping("/{id}")
    public Result<ReplenishmentOrder> getById(@PathVariable Long id) {
        ReplenishmentOrder order = replenishmentOrderService.getReplenishmentOrderById(id);
        return Result.success(order);
    }

    @GetMapping("/{id}/items")
    public Result<List<ReplenishmentItem>> getItems(@PathVariable Long id) {
        List<ReplenishmentItem> items = replenishmentOrderService.getItemsByReplenishmentId(id);
        return Result.success(items);
    }

    @PutMapping("/{id}")
    public Result<ReplenishmentOrder> update(@PathVariable Long id, @Validated @RequestBody ReplenishmentOrderDTO dto) {
        ReplenishmentOrder order = replenishmentOrderService.updateReplenishmentOrder(id, dto);
        return Result.success(order);
    }

    @DeleteMapping("/{id}")
    public Result<Void> delete(@PathVariable Long id) {
        replenishmentOrderService.deleteReplenishmentOrder(id);
        return Result.success();
    }

    @GetMapping
    public Result<Page<ReplenishmentOrder>> query(ReplenishmentOrderQueryDTO queryDTO) {
        Page<ReplenishmentOrder> page = replenishmentOrderService.queryReplenishmentOrders(queryDTO);
        return Result.success(page);
    }

    /**
     * 基于 LSTM 对当前用户订单销售时序的预测，获取补货建议
     */
    @GetMapping("/suggestions")
    public Result<List<ReplenishmentSuggestionDTO>> getSuggestions(ReplenishmentSuggestionQueryDTO queryDTO) {
        List<ReplenishmentSuggestionDTO> list = replenishmentSuggestionService.getSuggestions(queryDTO);
        return Result.success(list);
    }

    /**
     * 评估 LSTM 预测指标（MAE / RMSE / R²），用于论文“当前指标”直接展示
     *
     * 取数口径与 /suggestions 一致：拉取订单销售时序（按 SKU 聚合的每日销量 values），
     * 再按“时间顺序 7:3 划分训练/测试”计算指标。
     */
    @GetMapping("/forecast-metrics")
    public Result<ForecastMetricsResultDTO> forecastMetrics(
            ReplenishmentSuggestionQueryDTO queryDTO,
            @RequestParam(value = "zid", required = false) String zidParam) {
        // 生产环境通常从登录上下文取 zid；为便于本地/论文调试，允许通过 queryParam 传入 zid
        String zid = UserContext.getZid();
        if (!StringUtils.hasText(zid)) {
            zid = zidParam;
        }
        if (!StringUtils.hasText(zid)) {
            throw new BusinessException("未登录或缺少租户信息，请在请求参数中传 zid（例如 zid=1）");
        }
        if (queryDTO == null || queryDTO.getSid() == null) {
            throw new BusinessException("请指定 sid（店铺 ID）以计算该店铺的预测指标");
        }

        LocalDate endDate = queryDTO.getEndDate() != null ? queryDTO.getEndDate() : LocalDate.now().minusDays(1);
        LocalDate startDate = queryDTO.getStartDate() != null ? queryDTO.getStartDate() : endDate.minusDays(30);

        Result<List<SalesTimeSeriesItemDTO>> result = orderClient.getSalesTimeSeries(zid, queryDTO.getSid(), startDate, endDate, null);
        if (result == null || result.getData() == null || result.getData().isEmpty()) {
            return Result.success(ForecastMetricsResultDTO.builder().overall(null).perSku(Collections.emptyList()).build());
        }

        Map<Long, List<SalesTimeSeriesItemDTO>> bySku = result.getData().stream()
                .filter(item -> item != null && effectiveSkuId(item) != null)
                .collect(Collectors.groupingBy(ReplenishmentController::effectiveSkuId));

        List<Map<String, Object>> series = new ArrayList<>();
        for (Map.Entry<Long, List<SalesTimeSeriesItemDTO>> e : bySku.entrySet()) {
            List<SalesTimeSeriesItemDTO> list = e.getValue().stream()
                    .sorted(Comparator.comparing(SalesTimeSeriesItemDTO::getDate))
                    .collect(Collectors.toList());
            if (list.isEmpty()) continue;
            SalesTimeSeriesItemDTO first = list.get(0);

            List<Double> values = list.stream()
                    .map(item -> item.getQuantity() == null ? 0.0 : item.getQuantity().doubleValue())
                    .collect(Collectors.toList());

            Map<String, Object> item = new HashMap<>();
            item.put("skuId", effectiveSkuId(first));
            item.put("skuCode", first.getSkuCode() != null ? first.getSkuCode() : "");
            item.put("productName", first.getProductName() != null ? first.getProductName() : "");
            item.put("productId", first.getProductId() != null ? first.getProductId() : 0L);
            item.put("values", values);
            series.add(item);
        }

        ForecastMetricsResultDTO metrics = lstmForecastService.evaluate(series);
        return Result.success(metrics);
    }

    /** 订单销售数据可能只带 productId 不带 skuId，用 productId 作为 SKU 维度兜底 */
    private static Long effectiveSkuId(SalesTimeSeriesItemDTO item) {
        if (item == null) return null;
        if (item.getSkuId() != null) return item.getSkuId();
        return item.getProductId();
    }
}
