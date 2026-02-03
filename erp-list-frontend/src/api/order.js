import request from '@/utils/request'

/**
 * 订单 API（对接后端 /orders）
 * 查询参数与 OrderQueryDTO 一致：orderNo, userId, zid, sid, orderStatus, payStatus, pageNum, pageSize
 */
export const orderApi = {
  queryOrders(params) {
    return request.get('/orders', { params })
  },

  getOrderById(id) {
    return request.get(`/orders/${id}`)
  },

  createOrder(data) {
    return request.post('/orders', data)
  },

  updateOrder(id, data) {
    return request.put(`/orders/${id}`, data)
  },

  deleteOrder(id) {
    return request.delete(`/orders/${id}`)
  },

  /** 按国家统计订单数，供首页地图使用。params: zid, sid, startDate, endDate */
  getOrderStatsByCountry(params) {
    return request.get('/orders/stats-by-country', { params })
  }
}
