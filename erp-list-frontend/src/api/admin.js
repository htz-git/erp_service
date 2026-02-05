import request from '@/utils/request'

/** 管理端接口：返回 res.data，列表为 Page { records, total, current, size } */
export const adminApi = {
  // 公司
  onboardCompany(data) {
    return request.post('/admin/companies/onboard', data).then((res) => res.data)
  },
  listCompanies(params) {
    return request.get('/admin/companies', { params }).then((res) => res.data)
  },
  getCompany(zid) {
    return request.get(`/admin/companies/${zid}`).then((res) => res.data)
  },
  updateCompany(zid, data) {
    return request.put(`/admin/companies/${zid}`, data).then((res) => res.data)
  },
  updateCompanyStatus(zid, status) {
    return request.put(`/admin/companies/${zid}/status`, null, { params: { status } }).then((res) => res.data)
  },

  // 全平台用户
  listAllUsers(params) {
    return request.get('/admin/users', { params }).then((res) => res.data)
  },
  updateUserStatus(id, status) {
    return request.put(`/admin/users/${id}/status`, null, { params: { status } }).then((res) => res.data)
  },
  resetUserPassword(id, newPassword) {
    return request.post(`/admin/users/${id}/reset-password`, { newPassword }).then((res) => res.data)
  },

  // 数据查看
  dataView(zid) {
    return request.get('/admin/data/view', { params: zid ? { zid } : {} }).then((res) => res.data)
  },

  // 审计日志
  listAuditLogs(params) {
    return request.get('/admin/audit-logs', { params }).then((res) => res.data)
  }
}
