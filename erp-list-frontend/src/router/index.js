import { createRouter, createWebHistory } from 'vue-router'
import Layout from '@/layout/index.vue'
import AdminLayout from '@/layout/AdminLayout.vue'
import { useUserStore } from '@/store/user'

const routes = [
  {
    path: '/login',
    name: 'Login',
    component: () => import('@/views/Login.vue'),
    meta: { title: '登录' }
  },
  {
    path: '/admin',
    component: AdminLayout,
    redirect: '/admin/dashboard',
    meta: { requiresAuth: true, requiresAdmin: true },
    children: [
      {
        path: 'dashboard',
        name: 'AdminDashboard',
        component: () => import('@/views/admin/Dashboard.vue'),
        meta: { title: '管理首页', icon: 'HomeFilled' }
      },
      {
        path: 'companies',
        name: 'AdminCompanyList',
        component: () => import('@/views/admin/company/CompanyList.vue'),
        meta: { title: '公司列表', icon: 'OfficeBuilding' }
      },
      {
        path: 'companies/onboard',
        name: 'AdminCompanyOnboard',
        component: () => import('@/views/admin/company/CompanyOnboard.vue'),
        meta: { title: '开通公司', icon: 'OfficeBuilding' }
      },
      {
        path: 'companies/:zid',
        name: 'AdminCompanyDetail',
        component: () => import('@/views/admin/company/CompanyDetail.vue'),
        meta: { title: '公司详情', icon: 'OfficeBuilding' }
      },
      {
        path: 'users',
        name: 'AdminUserList',
        component: () => import('@/views/admin/user/AdminUserList.vue'),
        meta: { title: '用户管理', icon: 'User' }
      },
      {
        path: 'data-view',
        name: 'AdminDataView',
        component: () => import('@/views/admin/DataView.vue'),
        meta: { title: '数据查看', icon: 'DataAnalysis' }
      },
      {
        path: 'audit-logs',
        name: 'AdminAuditLogs',
        component: () => import('@/views/admin/AuditLogs.vue'),
        meta: { title: '审计日志', icon: 'Document' }
      }
    ]
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
  },
  {
    path: '/inventory',
    component: Layout,
    meta: { requiresAuth: true },
    children: [
      {
        path: 'list',
        name: 'InventoryList',
        component: () => import('@/views/inventory/InventoryList.vue'),
        meta: { title: '库存管理', icon: 'Box' }
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
    // 已有当前用户（如刚登录）时不再请求 getCurrentUser，避免平台管理员首次进入管理端时 401 导致被踢回登录
    if (!userStore.currentUser()) {
      await userStore.fetchAndSetUser()
    }
    if (!userStore.currentUser()) {
      next('/login')
      return
    }
    // 管理端：若 isAdmin 未设置但 localStorage 有标记，则恢复（如刷新后）
    if (to.meta.requiresAdmin && !userStore.isAdminUser()) {
      const savedAdmin = localStorage.getItem('user_is_admin')
      if (savedAdmin === '1') {
        userStore.setAdmin(true)
      }
      if (!userStore.isAdminUser()) {
        next('/')
        return
      }
    }
    next()
  } else if (to.path === '/login') {
    if (userStore.isAuthenticated()) {
      next(userStore.isAdminUser() ? '/admin/dashboard' : '/')
    } else {
      next()
    }
  } else {
    next()
  }
})

export default router


