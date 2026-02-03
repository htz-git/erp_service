import request from '@/utils/request'

/**
 * 店铺 API（对接后端 /sellers）
 * 查询参数与 SellerQueryDTO 一致：sellerName, platform, status, userId, zid, pageNum, pageSize
 */
export const sellerApi = {
  querySellers(params) {
    return request.get('/sellers', { params })
  },

  getSellerById(id) {
    return request.get(`/sellers/${id}`)
  },

  createSeller(data) {
    return request.post('/sellers', data)
  },

  updateSeller(id, data) {
    return request.put(`/sellers/${id}`, data)
  },

  deleteSeller(id) {
    return request.delete(`/sellers/${id}`)
  },

  updateStatus(id, status) {
    return request.put(`/sellers/${id}/status`, null, { params: { status } })
  }
}
