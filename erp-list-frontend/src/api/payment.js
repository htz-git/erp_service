import request from '@/utils/request'

/**
 * 支付 API（对接后端 /payments）
 * 查询参数与 PaymentQueryDTO 一致：paymentNo, orderId, orderNo, userId, zid, sid, paymentStatus, pageNum, pageSize
 */
export const paymentApi = {
  queryPayments(params) {
    return request.get('/payments', { params })
  },

  getPaymentById(id) {
    return request.get(`/payments/${id}`)
  },

  createPayment(data) {
    return request.post('/payments', data)
  },

  updatePayment(id, data) {
    return request.put(`/payments/${id}`, data)
  },

  deletePayment(id) {
    return request.delete(`/payments/${id}`)
  },

  listPaymentMethods() {
    return request.get('/payments/methods')
  },

  getPaymentMethodById(id) {
    return request.get(`/payments/methods/${id}`)
  }
}
