import request from '@/utils/request'

/**
 * 采购单 API（对接后端 /purchases）
 * 查询参数与 PurchaseOrderQueryDTO 一致：zid, sid, purchaseNo, supplierId, purchaseStatus, purchaserId, pageNum, pageSize
 */
export const purchaseApi = {
  queryPurchaseOrders(params) {
    return request.get('/purchases', { params })
  },

  getPurchaseOrderById(id) {
    return request.get(`/purchases/${id}`)
  },

  getItemsByPurchaseId(id) {
    return request.get(`/purchases/${id}/items`)
  },

  getPurchaseOrderDetail(id) {
    return request.get(`/purchases/${id}/detail`)
  },

  createPurchaseOrder(data) {
    return request.post('/purchases', data)
  },

  updatePurchaseOrder(id, data) {
    return request.put(`/purchases/${id}`, data)
  },

  deletePurchaseOrder(id) {
    return request.delete(`/purchases/${id}`)
  },

  /** 根据补货建议生成采购单 body: { supplierId, suggestions: [{ sid, productId, productName, skuId, skuCode, suggestedQuantity }] } */
  createPurchaseFromSuggestions(data) {
    return request.post('/purchases/from-suggestions', data)
  },

  approvePurchaseOrder(id) {
    return request.put(`/purchases/${id}/approve`)
  },

  /** 供应商列表，用于补货页选供应商 */
  querySuppliers(params) {
    return request.get('/suppliers', { params })
  }
}
