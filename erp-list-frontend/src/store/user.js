import { defineStore } from 'pinia'
import { ref } from 'vue'

export const useUserStore = defineStore('user', () => {
  const user = ref(null)
  const token = ref(null)

  function setUser(userData) {
    user.value = userData
  }

  function setToken(tokenValue) {
    token.value = tokenValue
    if (tokenValue) {
      localStorage.setItem('token', tokenValue)
    } else {
      localStorage.removeItem('token')
    }
  }

  function clearUser() {
    user.value = null
    token.value = null
    localStorage.removeItem('token')
  }

  function login(userData, tokenValue) {
    setUser(userData)
    setToken(tokenValue)
  }

  function logout() {
    clearUser()
  }

  function initAuth() {
    const savedToken = localStorage.getItem('token')
    if (savedToken) {
      token.value = savedToken
    }
  }

  const isAuthenticated = () => !!token.value
  const currentUser = () => user.value
  const currentZid = () => user.value?.zid

  return {
    user,
    token,
    setUser,
    setToken,
    clearUser,
    login,
    logout,
    initAuth,
    isAuthenticated,
    currentUser,
    currentZid
  }
})


