package com.erplist.replenishment.service;

import com.erplist.replenishment.dto.ForecastMetricsResultDTO;

import java.util.List;
import java.util.Map;

/**
 * LSTM + 自回归需求预测服务（Java 内建，替代原 Python 服务）
 * 输入：每个 SKU 的历史销量序列；输出：预测总需求量与每日需求量
 */
public interface LstmForecastService {

    /**
     * 对多组时序做预测
     *
     * @param series       每组含 skuId, skuCode, productName, productId, values（历史每日销量列表，按时间升序）
     * @param forecastDays 预测未来天数（1–30）
     * @return 每组对应一项：skuId, skuCode, productName, productId, forecastTotal, forecastDaily
     */
    List<Map<String, Object>> predict(List<Map<String, Object>> series, int forecastDays);

    /**
     * 评估当前模型在给定时序上的效果指标（按“时间顺序 7:3 划分训练/测试”）
     *
     * @param series 每组含 skuId 及 values（历史每日销量列表，按时间升序）
     * @return overall + perSku 的 MAE/RMSE/R² 等指标
     */
    ForecastMetricsResultDTO evaluate(List<Map<String, Object>> series);
}
