import request from '@/utils/request'

/**
 * 补货建议：基于 LSTM + 自回归（Java 内建）对销售时序预测
 * @param {Object} params - startDate, endDate, forecastDays, sid(可选)
 */
export function getReplenishmentSuggestions(params) {
  return request.get('/replenishments/suggestions', { params })
}
