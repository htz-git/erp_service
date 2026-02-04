import { createApp } from 'vue'
import ElementPlus from 'element-plus'
import 'element-plus/dist/index.css'
import '@/styles/variables.css'
import * as ElementPlusIconsVue from '@element-plus/icons-vue'
import zhCn from 'element-plus/dist/locale/zh-cn.mjs'
import { createPinia } from 'pinia'

import App from './App.vue'
import router from './router'
import { useUserStore } from './store/user'

const app = createApp(App)
const pinia = createPinia()

// 注册所有图标
for (const [key, component] of Object.entries(ElementPlusIconsVue)) {
  app.component(key, component)
}

app.use(pinia)
app.use(router)
app.use(ElementPlus, { locale: zhCn })

// 初始化认证：从 localStorage 恢复 token，若有 token 则用后端校验，失败则跳登录
;(async () => {
  const userStore = useUserStore()
  userStore.initAuth()
  if (userStore.isAuthenticated()) {
    await userStore.fetchAndSetUser()
    if (!userStore.currentUser()) {
      userStore.logout()
      router.push('/login')
    }
  }
  app.mount('#app')
})()


