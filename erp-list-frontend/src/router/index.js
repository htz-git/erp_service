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
    path: '/payment',
    component: Layout,
    meta: { requiresAuth: true },
    children: [
      {
        path: 'list',
        name: 'PaymentList',
        component: () => import('@/views/payment/PaymentList.vue'),
        meta: { title: '支付管理', icon: 'CreditCard' }
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
    path: '/coupon',
    component: Layout,
    meta: { requiresAuth: true },
    children: [
      {
        path: 'list',
        name: 'CouponList',
        component: () => import('@/views/coupon/CouponList.vue'),
        meta: { title: '优惠券管理', icon: 'Ticket' }
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

// 路由守卫
router.beforeEach((to, from, next) => {
  const userStore = useUserStore()
  
  // 如果路由需要认证
  if (to.meta.requiresAuth) {
    if (!userStore.isAuthenticated()) {
      // 未登录，跳转到登录页
      next('/login')
    } else {
      next()
    }
  } else if (to.path === '/login') {
    // 如果已经登录，访问登录页时跳转到首页
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


