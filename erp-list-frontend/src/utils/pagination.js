/**
 * 统一解析分页接口响应，兼容多种返回结构
 * - 业务接口：res = { code, data: { records, total }, message }
 * - 网关二次封装：res.data = { code, data: { records, total } } 即 res.data.data
 * - 直接返回 Page：res = { records, total }
 * @param {object} res - 接口返回的完整响应（拦截器返回的 res）
 * @returns {{ list: array, total: number }}
 */
export function parsePageResponse(res) {
  const list =
    res?.data?.records ??
    res?.data?.data?.records ??
    res?.records ??
    []
  const arr = Array.isArray(list) ? list : []

  // total 可能在不同层级或不同字段名
  const rawTotal =
    res?.data?.total ??
    res?.data?.data?.total ??
    res?.total ??
    res?.data?.totalCount ??
    res?.data?.data?.totalCount ??
    res?.data?.totalElements ??
    res?.data?.data?.totalElements
  let total = Number(rawTotal) || 0

  // 若接口未返回 total 但本页有数据，用本页条数兜底，避免显示「共0条」
  if (total === 0 && arr.length > 0) {
    total = arr.length
  }

  return {
    list: arr,
    total
  }
}
