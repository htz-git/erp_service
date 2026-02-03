import request from '@/utils/request'

/**
 * 商品 API（对接后端 /products）
 * 查询参数与 CompanyProductQueryDTO 一致：zid, sid, productName, productCode, pageNum, pageSize
 */
export const productApi = {
  queryProducts(params) {
    return request.get('/products', { params })
  },

  getProductById(id) {
    return request.get(`/products/${id}`)
  },

  createProduct(data) {
    return request.post('/products', data)
  },

  updateProduct(id, data) {
    return request.put(`/products/${id}`, data)
  },

  deleteProduct(id) {
    return request.delete(`/products/${id}`)
  }
}
