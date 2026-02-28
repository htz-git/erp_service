import request from '@/utils/request'

/**
 * 退款申请 API（对接后端 /refunds）
 * 查询参数与 RefundApplicationQueryDTO 一致：zid, sid, refundNo, orderId, orderNo, userId, paymentId, refundStatus, pageNum, pageSize
 */
export const refundApi = {
  queryRefundApplications(params) {
    return request.get('/refunds', { params })
  },

  getRefundApplicationById(id) {
    return request.get(`/refunds/${id}`)
  },

  createRefundApplication(data) {
    return request.post('/refunds', data)
  },

  updateRefundApplication(id, data) {
    return request.put(`/refunds/${id}`, data)
  },

  deleteRefundApplication(id) {
    return request.delete(`/refunds/${id}`)
  },

  getRefundReasons(params) {
    return request.get('/refunds/reasons', { params })
  },

  /**
   * 批量查询存在已退款记录的订单 ID，供订单列表展示“退款”标签
   * @param {number[]} orderIds 订单 ID 数组
   */
  getOrderIdsWithRefund(orderIds) {
    if (!orderIds || orderIds.length === 0) return Promise.resolve({ data: [] })
    return request.get('/refunds/order-ids-with-refund', { params: { orderIds: orderIds.join(',') } })
  }
}
