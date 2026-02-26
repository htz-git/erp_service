package com.erplist.api.client;

import com.erplist.api.dto.SalesTimeSeriesItemDTO;
import com.erplist.common.result.Result;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.time.LocalDate;
import java.util.List;

/**
 * 订单服务 Feign 客户端（供补货服务拉取销售时序数据）
 */
@FeignClient(name = "erp-list-order-service", contextId = "orderClient", configuration = com.erplist.api.config.DefaultFeignConfig.class)
public interface OrderClient {

    /**
     * 查询某公司下有订单的店铺 ID 列表（去重），供补货建议“全部店铺”使用
     */
    @GetMapping("/orders/distinct-sids")
    Result<List<Long>> getDistinctSids(@RequestParam(value = "zid", required = false) String zid);

    /**
     * 获取销售时序数据（按日、按 SKU 聚合），用于 LSTM 需求预测
     *
     * @param zid      租户 ID（可选，不传则用 Feign 请求头中的 user-zid）
     * @param sid      店铺 ID（可选）
     * @param startDate 开始日期
     * @param endDate   结束日期
     * @param skuId     SKU ID（可选，不传则返回所有 SKU）
     * @return 每日每 SKU 的销量列表
     */
    @GetMapping("/orders/sales-timeseries")
    Result<List<SalesTimeSeriesItemDTO>> getSalesTimeSeries(
            @RequestParam(value = "zid", required = false) String zid,
            @RequestParam(value = "sid", required = false) Long sid,
            @RequestParam("startDate") @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam("endDate") @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate,
            @RequestParam(value = "skuId", required = false) Long skuId
    );
}
