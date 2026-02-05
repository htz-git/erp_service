import { createRouter, createWebHistory } from 'vue-router'
import Layout from '@/layout/index.vue'
import { useUserStore } from '@/store/user'

const routes = [
  {
    path: '/login',
    name: 'Login',
    component: () => import('@/views/Login.vue'),
    meta: { title: '登录' }
  },
  {
    path: '/',
    component: Layout,
    redirect: '/dashboard',
    meta: { requiresAuth: true },
    children: [
      {
        path: 'dashboard',
        name: 'Dashboard',
        component: () => import('@/views/Dashboard.vue'),
        meta: { title: '首页', icon: 'HomeFilled' }
      }
    ]
  },
  {
    path: '/user',
    component: Layout,
    meta: { requiresAuth: true },
    children: [
      {
        path: 'list',
        name: 'UserList',
        component: () => import('@/views/user/UserList.vue'),
        meta: { title: '用户管理', icon: 'User' }
      },
      {
        path: 'create',
        name: 'UserCreate',
        component: () => import('@/views/user/UserCreate.vue'),
        meta: { title: '新增用户', icon: 'User' }
      }
    ]
  },
  {
    path: '/seller',
    component: Layout,
    meta: { requiresAuth: true },
    children: [
      {
        path: 'list',
        name: 'SellerList',
        component: () => import('@/views/seller/SellerList.vue'),
        meta: { title: '店铺管理', icon: 'Shop' }
      },
      {
        path: 'create',
        name: 'SellerCreate',
        component: () => import('@/views/seller/SellerCreate.vue'),
        meta: { title: '新增店铺', icon: 'Shop' }
      }
    ]
  },
  {
    path: '/order',
    component: Layout,
    meta: { requiresAuth: true },
    children: [
      {
        path: 'list',
        name: 'OrderList',
        component: () => import('@/views/order/OrderList.vue'),
        meta: { title: '订单管理', icon: 'ShoppingBag' }
      }
    ]
  },
  {
    path: '/product',
    component: Layout,
    meta: { requiresAuth: true },
    children: [
      {
        path: 'list',
        name: 'ProductList',
        component: () => import('@/views/product/ProductList.vue'),
        meta: { title: '商品管理', icon: 'Goods' }
      }
    ]
  },
  {
    path: '/purchase',
    component: Layout,
    meta: { requiresAuth: true },
    children: [
      {
        path: 'list',
        name: 'PurchaseList',
        component: () => import('@/views/purchase/PurchaseList.vue'),
        meta: { title: '采购管理', icon: 'ShoppingCart' }
      }
    ]
  },
  {
    path: '/refund',
    component: Layout,
    meta: { requiresAuth: true },
    children: [
      {
        path: 'list',
        name: 'RefundList',
        component: () => import('@/views/refund/RefundList.vue'),
        meta: { title: '退款管理', icon: 'Money' }
      }
    ]
  },
  {
    path: '/replenishment',
    component: Layout,
    meta: { requiresAuth: true },
    children: [
      {
        path: 'list',
        name: 'ReplenishmentList',
        component: () => import('@/views/replenishment/ReplenishmentList.vue'),
        meta: { title: '补货管理', icon: 'Box' }
      }
    ]
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

// 路由守卫：需登录路由必须通过后端校验 token，失败则跳转登录
router.beforeEach(async (to, from, next) => {
  const userStore = useUserStore()

  if (to.meta.requiresAuth) {
    if (!userStore.isAuthenticated()) {
      next('/login')
      return
    }
    // 有 token 时进入需登录页面前必须用后端校验；失败则 clearUser，currentUser 为空
    await userStore.fetchAndSetUser()
    if (!userStore.currentUser()) {
      next('/login')
      return
    }
    next()
  } else if (to.path === '/login') {
    if (userStore.isAuthenticated()) {
      next('/')
    } else {
      next()
    }
  } else {
    next()
  }
})

export default router


