import request from '@/utils/request'

/**
 * 补货建议：对接后端 GET /replenishments/suggestions（LSTM 预测）
 * @param {Object} params - startDate(YYYY-MM-DD), endDate(YYYY-MM-DD), forecastDays(1-30), sid(可选)
 * @returns {Promise<{ code, data: ReplenishmentSuggestionDTO[], message }>}
 */
export function getReplenishmentSuggestions(params = {}) {
  const query = {}
  if (params.startDate) query.startDate = params.startDate
  if (params.endDate) query.endDate = params.endDate
  if (params.forecastDays != null && params.forecastDays !== '') query.forecastDays = params.forecastDays
  if (params.sid != null && params.sid !== '') query.sid = params.sid
  return request.get('/replenishments/suggestions', { params: query })
}
