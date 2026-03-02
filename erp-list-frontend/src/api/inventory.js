import request from '@/utils/request'

/**
 * 库存列表（分页）
 */
export function getInventoryList(params = {}) {
  const query = {}
  if (params.pageNum != null) query.pageNum = params.pageNum
  if (params.pageSize != null) query.pageSize = params.pageSize
  if (params.sid != null && params.sid !== '') query.sid = params.sid
  if (params.skuCode) query.skuCode = params.skuCode
  if (params.keyword) query.keyword = params.keyword
  return request.get('/inventories', { params: query })
}

/**
 * 库存详情
 */
export function getInventoryById(id) {
  return request.get(`/inventories/${id}`)
}

/**
 * 新增库存
 */
export function createInventory(data) {
  return request.post('/inventories', data)
}

/**
 * 更新库存
 */
export function updateInventory(id, data) {
  return request.put(`/inventories/${id}`, data)
}

/**
 * 入库：增加库存。data: { quantity: number, purchaseId?: number }（可选关联采购单）
 */
export function stockIn(id, data) {
  return request.post(`/inventories/${id}/stock-in`, data)
}

/**
 * 出库：减少库存。data: { quantity: number }
 */
export function stockOut(id, data) {
  return request.post(`/inventories/${id}/stock-out`, data)
}
