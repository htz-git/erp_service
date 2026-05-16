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

  /** 状态推进：待审核→已审核→采购中→部分到货→已完成（每次调用前进一档） */
  approvePurchaseOrder(id) {
    return request.put(`/purchases/${id}/approve`)
  },

  querySuppliers(params) {
    return request.get('/suppliers', { params })
  },

  getSupplierById(id) {
    return request.get(`/suppliers/${id}`)
  },

  createSupplier(data) {
    return request.post('/suppliers', data)
  },

  updateSupplier(id, data) {
    return request.put(`/suppliers/${id}`, data)
  },

  deleteSupplier(id) {
    return request.delete(`/suppliers/${id}`)
  },

  updateSupplierStatus(id, status) {
    return request.put(`/suppliers/${id}/status`, null, { params: { status } })
  }
}
