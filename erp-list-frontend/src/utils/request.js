import axios from 'axios'
import { ElMessage } from 'element-plus'
import { useUserStore } from '@/store/user'

const baseURL = import.meta.env.VITE_API_BASE
  ? import.meta.env.VITE_API_BASE + '/api'
  : '/api'

const service = axios.create({
  baseURL,
  timeout: 10000
})

// 请求拦截器
service.interceptors.request.use(
  config => {
    const userStore = useUserStore()
    // 添加 token
    const token = userStore.token
    if (token) {
      config.headers['Authorization'] = `Bearer ${token}`
    }
    // 从 store 或 localStorage 带上 user-id、user-zid，供下游服务设置 UserContext（不依赖网关解析）
    const userId = userStore.getUserIdForHeader?.()
    const zid = userStore.getZidForHeader?.()
    if (userId) config.headers['user-id'] = userId
    if (zid) config.headers['user-zid'] = zid
    return config
  },
  error => {
    console.error('请求错误:', error)
    return Promise.reject(error)
  }
)

// 响应拦截器
service.interceptors.response.use(
  response => {
    const res = response.data
    // 如果返回的状态码为200，说明接口请求成功
    if (res.code === 200) {
      return res
    } else {
      ElMessage.error(res.message || '请求失败')
      return Promise.reject(new Error(res.message || '请求失败'))
    }
  },
  error => {
    console.error('响应错误:', error)
    // 401未授权，跳转到登录页
    if (error.response?.status === 401) {
      const userStore = useUserStore()
      userStore.logout()
      window.location.href = '/login'
    } else {
      ElMessage.error(error.response?.data?.message || error.message || '网络错误')
    }
    return Promise.reject(error)
  }
)

export default service


