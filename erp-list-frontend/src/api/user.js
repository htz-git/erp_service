import request from '@/utils/request'

export const userApi = {
  // 登录
  login(data) {
    return request.post('/users/login', data)
  },
  
  // 获取当前用户
  getCurrentUser() {
    return request.get('/users/current')
  },
  
  // 创建用户
  createUser(data) {
    return request.post('/users', data)
  },
  
  // 查询用户列表
  queryUsers(params) {
    return request.get('/users', { params })
  },
  
  // 根据ID查询用户
  getUserById(id) {
    return request.get(`/users/${id}`)
  },
  
  // 更新用户
  updateUser(id, data) {
    return request.put(`/users/${id}`, data)
  },
  
  // 删除用户
  deleteUser(id) {
    return request.delete(`/users/${id}`)
  },
  
  // 启用/禁用用户
  updateStatus(id, status) {
    return request.put(`/users/${id}/status`, null, { params: { status } })
  }
}


