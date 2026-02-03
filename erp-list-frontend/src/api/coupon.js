import request from '@/utils/request'

/**
 * 优惠券 API（对接后端 /coupons）
 * 查询参数与 CouponQueryDTO 一致：couponName, couponType, status, pageNum, pageSize
 */
export const couponApi = {
  queryCoupons(params) {
    return request.get('/coupons', { params })
  },

  getCouponById(id) {
    return request.get(`/coupons/${id}`)
  },

  createCoupon(data) {
    return request.post('/coupons', data)
  },

  updateCoupon(id, data) {
    return request.put(`/coupons/${id}`, data)
  },

  deleteCoupon(id) {
    return request.delete(`/coupons/${id}`)
  },

  updateCouponStatus(id, status) {
    return request.put(`/coupons/${id}/status`, null, { params: { status } })
  }
}
