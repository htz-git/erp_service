package com.erplist.replenishment.service.impl;

import com.erplist.api.client.OrderClient;
import com.erplist.api.dto.SalesTimeSeriesItemDTO;
import com.erplist.common.exception.BusinessException;
import com.erplist.common.result.Result;
import com.erplist.common.utils.UserContext;
import com.erplist.replenishment.dto.ReplenishmentSuggestionDTO;
import com.erplist.replenishment.entity.Inventory;
import com.erplist.replenishment.mapper.InventoryMapper;
import com.erplist.replenishment.service.LstmForecastService;
import com.erplist.replenishment.dto.ReplenishmentSuggestionQueryDTO;
import com.erplist.replenishment.service.ReplenishmentSuggestionService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.util.CollectionUtils;
import org.springframework.util.StringUtils;

import java.time.LocalDate;
import java.util.*;
import java.util.stream.Collectors;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;

/**
 * 补货建议服务实现：拉取订单销售时序 → 调用 LSTM 预测 → 返回补货建议
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class ReplenishmentSuggestionServiceImpl implements ReplenishmentSuggestionService {

    private final OrderClient orderClient;
    private final LstmForecastService lstmForecastService;
    private final InventoryMapper inventoryMapper;

    private static final int DEFAULT_HISTORY_DAYS = 30;
    private static final int DEFAULT_FORECAST_DAYS = 7;
    /** 预测需求加成系数（1.1 = 10% 盈余），用于应对销量激增，避免断货 */
    private static final double FORECAST_BUFFER_RATIO = 1.1;

    @Override
    public List<ReplenishmentSuggestionDTO> getSuggestions(ReplenishmentSuggestionQueryDTO queryDTO) {
        String zid = UserContext.getZid();
        if (!StringUtils.hasText(zid)) {
            throw new BusinessException("未登录或缺少租户信息，仅能查看当前公司下的补货建议");
        }
        Long sid = (queryDTO != null && queryDTO.getSid() != null) ? queryDTO.getSid() : UserContext.getSid();
        if (sid == null) {
            sid = 1L; // 未传店铺时默认使用默认店铺 id=1，与 init 数据一致
        }

        LocalDate endDate = queryDTO != null && queryDTO.getEndDate() != null
                ? queryDTO.getEndDate()
                : LocalDate.now().minusDays(1);
        LocalDate startDate = queryDTO != null && queryDTO.getStartDate() != null
                ? queryDTO.getStartDate()
                : endDate.minusDays(DEFAULT_HISTORY_DAYS);
        int forecastDays = queryDTO != null && queryDTO.getForecastDays() != null
                ? Math.min(30, Math.max(1, queryDTO.getForecastDays()))
                : DEFAULT_FORECAST_DAYS;

        Result<List<SalesTimeSeriesItemDTO>> result = orderClient.getSalesTimeSeries(zid, sid, startDate, endDate, null);
        if (result == null || result.getData() == null || result.getData().isEmpty()) {
            return Collections.emptyList();
        }
        List<SalesTimeSeriesItemDTO> raw = result.getData();

        // 按 SKU 分组（订单可能只返回 productId 不返回 skuId，用 productId 兜底），并按日期升序排列
        Map<Long, List<SalesTimeSeriesItemDTO>> bySku = raw.stream()
                .filter(item -> effectiveSkuId(item) != null)
                .collect(Collectors.groupingBy(ReplenishmentSuggestionServiceImpl::effectiveSkuId));

        List<Map<String, Object>> series = new ArrayList<>();
        for (Map.Entry<Long, List<SalesTimeSeriesItemDTO>> e : bySku.entrySet()) {
            List<SalesTimeSeriesItemDTO> list = e.getValue().stream()
                    .sorted(Comparator.comparing(SalesTimeSeriesItemDTO::getDate))
                    .collect(Collectors.toList());
            if (list.isEmpty()) continue;
            List<Double> values = list.stream()
                    .map(item -> item.getQuantity() == null ? 0.0 : item.getQuantity().doubleValue())
                    .collect(Collectors.toList());
            SalesTimeSeriesItemDTO first = list.get(0);
            Long skuKey = effectiveSkuId(first);
            Map<String, Object> item = new HashMap<>();
            item.put("skuId", skuKey);
            item.put("skuCode", first.getSkuCode() != null ? first.getSkuCode() : "");
            item.put("productName", first.getProductName() != null ? first.getProductName() : "");
            item.put("productId", first.getProductId() != null ? first.getProductId() : 0L);
            item.put("values", values);
            series.add(item);
        }
        if (series.isEmpty()) {
            return Collections.emptyList();
        }

        List<Map<String, Object>> predictions = lstmForecastService.predict(series, forecastDays);
        if (CollectionUtils.isEmpty(predictions)) {
            return Collections.emptyList();
        }

        // 按 zid + skuIds 批量查库存，无记录视为 0
        List<Long> skuIds = predictions.stream()
                .map(p -> longFrom(p.get("skuId")))
                .filter(Objects::nonNull)
                .distinct()
                .collect(Collectors.toList());
        Map<Long, Integer> skuIdToStock = new HashMap<>();
        if (!skuIds.isEmpty() && sid != null) {
            LambdaQueryWrapper<Inventory> wrapper = new LambdaQueryWrapper<>();
            wrapper.eq(Inventory::getZid, zid).eq(Inventory::getSid, sid).in(Inventory::getSkuId, skuIds);
            List<Inventory> inventories = inventoryMapper.selectList(wrapper);
            for (Inventory inv : inventories) {
                if (inv.getSkuId() != null && inv.getCurrentStock() != null) {
                    skuIdToStock.put(inv.getSkuId(), inv.getCurrentStock());
                }
            }
        }

        List<ReplenishmentSuggestionDTO> suggestions = new ArrayList<>();
        for (Map<String, Object> p : predictions) {
            Long skuId = longFrom(p.get("skuId"));
            Integer forecastTotal = numberToInt(p.get("forecastTotal"));
            List<Double> forecastDaily = toDoubleList(p.get("forecastDaily"));
            int total = forecastTotal != null ? forecastTotal : 0;
            int currentStock = skuId != null ? skuIdToStock.getOrDefault(skuId, 0) : 0;
            // 建议量 = (预测总需求 * 1.1 盈余) - 当前库存，避免销量激增时断货
            int demandWithBuffer = (int) Math.round(total * FORECAST_BUFFER_RATIO);
            int suggestedQuantity = Math.max(0, demandWithBuffer - currentStock);
            suggestions.add(ReplenishmentSuggestionDTO.builder()
                    .sid(sid)
                    .skuId(skuId)
                    .skuCode(stringOf(p.get("skuCode")))
                    .productName(stringOf(p.get("productName")))
                    .productId(longFrom(p.get("productId")))
                    .forecastTotal(total)
                    .forecastDaily(forecastDaily)
                    .currentStock(currentStock)
                    .suggestedQuantity(suggestedQuantity)
                    .build());
        }
        return suggestions;
    }

    /** 订单销售数据可能只带 productId 不带 skuId，用 productId 作为 SKU 维度兜底（与 inventory.sku_id 一致） */
    private static Long effectiveSkuId(SalesTimeSeriesItemDTO item) {
        if (item == null) return null;
        if (item.getSkuId() != null) return item.getSkuId();
        return item.getProductId();
    }

    private static Long longFrom(Object o) {
        if (o == null) return null;
        if (o instanceof Number) return ((Number) o).longValue();
        try {
            return Long.parseLong(o.toString());
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private static String stringOf(Object o) {
        return o != null ? o.toString() : "";
    }

    private static Integer numberToInt(Object o) {
        if (o == null) return null;
        if (o instanceof Number) return ((Number) o).intValue();
        try {
            return Integer.parseInt(o.toString());
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private static List<Double> toDoubleList(Object o) {
        if (o == null || !(o instanceof List)) return Collections.emptyList();
        List<Double> out = new ArrayList<>();
        for (Object e : (List<?>) o) {
            if (e instanceof Number) out.add(((Number) e).doubleValue());
            else if (e != null) try { out.add(Double.parseDouble(e.toString())); } catch (NumberFormatException ignored) { }
        }
        return out;
    }
}
