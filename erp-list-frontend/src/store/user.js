import { defineStore } from 'pinia'
import { ref } from 'vue'
import { userApi } from '@/api/user'

const USER_IS_ADMIN_KEY = 'user_is_admin'

export const useUserStore = defineStore('user', () => {
  const user = ref(null)
  const token = ref(null)
  const isAdmin = ref(false)

  const USER_ID_KEY = 'user_id'
  const USER_ZID_KEY = 'user_zid'

  function setUser(userData) {
    user.value = userData
    if (userData) {
      if (userData.id != null) localStorage.setItem(USER_ID_KEY, String(userData.id))
      if (userData.zid != null) localStorage.setItem(USER_ZID_KEY, String(userData.zid))
    }
  }

  function setToken(tokenValue) {
    token.value = tokenValue
    if (tokenValue) {
      localStorage.setItem('token', tokenValue)
    } else {
      localStorage.removeItem('token')
    }
  }

  function setAdmin(v) {
    isAdmin.value = !!v
    localStorage.setItem(USER_IS_ADMIN_KEY, v ? '1' : '0')
  }

  function clearAdmin() {
    isAdmin.value = false
    localStorage.removeItem(USER_IS_ADMIN_KEY)
  }

  function clearUser() {
    user.value = null
    token.value = null
    clearAdmin()
    localStorage.removeItem('token')
    localStorage.removeItem(USER_ID_KEY)
    localStorage.removeItem(USER_ZID_KEY)
  }

  function login(userData, tokenValue, adminFlag) {
    setUser(userData)
    setToken(tokenValue)
    setAdmin(adminFlag)
  }

  function logout() {
    clearUser()
  }

  function initAuth() {
    const savedToken = localStorage.getItem('token')
    if (savedToken) {
      token.value = savedToken
    }
    const savedAdmin = localStorage.getItem(USER_IS_ADMIN_KEY)
    if (savedAdmin === '1') {
      isAdmin.value = true
    }
  }

  /** 根据 token 拉取当前用户信息（刷新后或首次进入时用） */
  async function fetchAndSetUser() {
    if (!token.value) return
    try {
      const res = await userApi.getCurrentUser()
      if (res && res.data) {
        setUser(res.data)
      }
    } catch {
      clearUser()
    }
  }

  const isAuthenticated = () => !!token.value
  const currentUser = () => user.value
  const currentZid = () => user.value?.zid
  const isAdminUser = () => isAdmin.value === true

  /** 供请求拦截器用：优先从 store 取，否则从 localStorage 取（刷新后首请求时 store 可能尚未拉取） */
  function getUserIdForHeader() {
    const u = user.value
    if (u && u.id != null) return String(u.id)
    return localStorage.getItem(USER_ID_KEY)
  }
  function getZidForHeader() {
    const u = user.value
    if (u && u.zid != null) return String(u.zid)
    return localStorage.getItem(USER_ZID_KEY)
  }

  return {
    user,
    token,
    isAdmin,
    setUser,
    setToken,
    setAdmin,
    clearAdmin,
    clearUser,
    login,
    logout,
    initAuth,
    fetchAndSetUser,
    isAuthenticated,
    currentUser,
    currentZid,
    isAdminUser,
    getUserIdForHeader,
    getZidForHeader
  }
})


