package com.erplist.replenishment.service.impl;

import com.erplist.api.client.OrderClient;
import com.erplist.api.dto.SalesTimeSeriesItemDTO;
import com.erplist.common.exception.BusinessException;
import com.erplist.common.result.Result;
import com.erplist.common.utils.UserContext;
import com.erplist.replenishment.config.ReplenishmentSuggestionProperties;
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
    private final ReplenishmentSuggestionProperties suggestionProps;

    @Override
    public List<ReplenishmentSuggestionDTO> getSuggestions(ReplenishmentSuggestionQueryDTO queryDTO) {
        String zid = UserContext.getZid();
        if (!StringUtils.hasText(zid)) {
            throw new BusinessException("未登录或缺少租户信息，仅能查看当前公司下的补货建议");
        }

        LocalDate endDate = queryDTO != null && queryDTO.getEndDate() != null
                ? queryDTO.getEndDate()
                : LocalDate.now().minusDays(1);
        LocalDate startDate = queryDTO != null && queryDTO.getStartDate() != null
                ? queryDTO.getStartDate()
                : endDate.minusDays(suggestionProps.getHistoryDays());
        int forecastDays = queryDTO != null && queryDTO.getForecastDays() != null
                ? Math.min(30, Math.max(1, queryDTO.getForecastDays()))
                : suggestionProps.getForecastDays();

        // 未选店铺：查询当前公司下所有有订单的店铺，分别生成补货建议（每条带对应 sid）
        // 已选店铺：只查选中店铺的订单并生成该店铺的补货建议
        Long querySid = (queryDTO != null && queryDTO.getSid() != null) ? queryDTO.getSid() : null;
        List<Long> sidsToUse;
        if (querySid != null) {
            sidsToUse = Collections.singletonList(querySid);
        } else {
            Result<List<Long>> sidsResult = orderClient.getDistinctSids(zid);
            if (sidsResult == null || sidsResult.getData() == null || sidsResult.getData().isEmpty()) {
                return Collections.emptyList();
            }
            sidsToUse = sidsResult.getData();
        }

        List<ReplenishmentSuggestionDTO> allSuggestions = new ArrayList<>();
        for (Long sid : sidsToUse) {
            if (sid == null) continue;
            List<ReplenishmentSuggestionDTO> oneStore = getSuggestionsForStore(zid, sid, startDate, endDate, forecastDays);
            allSuggestions.addAll(oneStore);
        }
        return allSuggestions;
    }

    /**
     * 为单个店铺生成补货建议（保证每条建议的 sid 均为该店铺 ID）
     */
    private List<ReplenishmentSuggestionDTO> getSuggestionsForStore(String zid, Long sid,
            LocalDate startDate, LocalDate endDate, int forecastDays) {
        Result<List<SalesTimeSeriesItemDTO>> result = orderClient.getSalesTimeSeries(zid, sid, startDate, endDate, null);
        if (result == null || result.getData() == null || result.getData().isEmpty()) {
            return Collections.emptyList();
        }
        List<SalesTimeSeriesItemDTO> raw = result.getData();

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

        List<Long> skuIds = predictions.stream()
                .map(p -> longFrom(p.get("skuId")))
                .filter(Objects::nonNull)
                .distinct()
                .collect(Collectors.toList());
        Map<Long, Integer> skuIdToStock = new HashMap<>();
        Map<Long, Integer> skuIdToMinStock = new HashMap<>();
        if (!skuIds.isEmpty()) {
            LambdaQueryWrapper<Inventory> wrapper = new LambdaQueryWrapper<>();
            wrapper.eq(Inventory::getZid, zid).eq(Inventory::getSid, sid).in(Inventory::getSkuId, skuIds);
            List<Inventory> inventories = inventoryMapper.selectList(wrapper);
            for (Inventory inv : inventories) {
                if (inv.getSkuId() != null && inv.getCurrentStock() != null) {
                    skuIdToStock.put(inv.getSkuId(), inv.getCurrentStock());
                }
                if (inv.getSkuId() != null && inv.getMinStock() != null) {
                    skuIdToMinStock.put(inv.getSkuId(), inv.getMinStock());
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

            // 安全库存：默认取库存表 minStock（无记录/为空则 0）
            int safetyStock = 0;
            if (suggestionProps.isUseMinStockAsSafetyStock() && skuId != null) {
                safetyStock = skuIdToMinStock.getOrDefault(skuId, 0);
            }

            int leadTimeDays = Math.max(0, suggestionProps.getLeadTimeDays());
            double bufferRatio = suggestionProps.getForecastBufferRatio();
            double avgDaily = forecastDays > 0 ? (double) total / forecastDays : 0d;
            int leadTimeDemand = (int) Math.ceil(Math.max(0d, avgDaily * leadTimeDays * Math.max(0d, bufferRatio)));
            int reorderPoint = leadTimeDemand + Math.max(0, safetyStock);
            int suggestedQuantity = Math.max(0, reorderPoint - currentStock);

            String reason = String.format("预测%d天总需求=%d，日均=%.2f；提前期=%d天，缓冲系数=%.2f；安全库存=%d；ROP=%d；当前库存=%d",
                    forecastDays, total, avgDaily, leadTimeDays, bufferRatio, safetyStock, reorderPoint, currentStock);
            suggestions.add(ReplenishmentSuggestionDTO.builder()
                    .sid(sid)
                    .skuId(skuId)
                    .skuCode(stringOf(p.get("skuCode")))
                    .productName(stringOf(p.get("productName")))
                    .productId(longFrom(p.get("productId")))
                    .forecastTotal(total)
                    .forecastDaily(forecastDaily)
                    .currentStock(currentStock)
                    .safetyStock(safetyStock)
                    .leadTimeDays(leadTimeDays)
                    .leadTimeDemand(leadTimeDemand)
                    .reorderPoint(reorderPoint)
                    .suggestedQuantity(suggestedQuantity)
                    .suggestionReason(reason)
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
