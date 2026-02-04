<template>
  <el-container class="layout-container">
    <el-aside width="88px" class="sidebar">
      <div class="logo" title="企业资源计划">
        <!-- ERP 蓝色标识：突出企业资源计划特点 -->
        <span class="logo-erp">ERP</span>
      </div>
      <el-menu
        :default-active="activeMenu"
        router
        class="sidebar-menu"
        :background-color="sidebarBg"
        text-color="#bfcbd9"
        active-text-color="#409EFF"
      >
        <el-menu-item index="/dashboard">
          <span class="menu-item-inner">
            <el-icon class="menu-icon"><HomeFilled /></el-icon>
            <span class="menu-label">首页</span>
          </span>
        </el-menu-item>
        <el-menu-item index="/user/list">
          <span class="menu-item-inner">
            <el-icon class="menu-icon"><User /></el-icon>
            <span class="menu-label">用户</span>
          </span>
        </el-menu-item>
        <el-menu-item index="/seller/list">
          <span class="menu-item-inner">
            <el-icon class="menu-icon"><Shop /></el-icon>
            <span class="menu-label">店铺</span>
          </span>
        </el-menu-item>
        <el-menu-item index="/order/list">
          <span class="menu-item-inner">
            <el-icon class="menu-icon"><ShoppingBag /></el-icon>
            <span class="menu-label">订单</span>
          </span>
        </el-menu-item>
        <el-menu-item index="/product/list">
          <span class="menu-item-inner">
            <el-icon class="menu-icon"><Goods /></el-icon>
            <span class="menu-label">商品</span>
          </span>
        </el-menu-item>
        <el-menu-item index="/purchase/list">
          <span class="menu-item-inner">
            <el-icon class="menu-icon"><ShoppingCart /></el-icon>
            <span class="menu-label">采购</span>
          </span>
        </el-menu-item>
        <el-menu-item index="/refund/list">
          <span class="menu-item-inner">
            <el-icon class="menu-icon"><Money /></el-icon>
            <span class="menu-label">退款</span>
          </span>
        </el-menu-item>
        <el-menu-item index="/replenishment/list">
          <span class="menu-item-inner">
            <el-icon class="menu-icon"><Box /></el-icon>
            <span class="menu-label">补货</span>
          </span>
        </el-menu-item>
      </el-menu>
    </el-aside>
    <el-container class="right-container">
      <!-- 顶栏第一行：标签（首页固定 + 点击左侧打开的页面）+ 右侧仅用户信息 -->
      <div class="header-row header-row-1">
        <div class="header-left">
          <div
            v-for="tab in topTabs"
            :key="tab.path"
            class="tab-item"
            :class="{ active: isTabActive(tab.path) }"
          >
            <router-link :to="tab.path" class="tab-link">
              {{ tab.title }}
            </router-link>
            <el-icon
              v-if="tab.path !== '/dashboard'"
              class="tab-close"
              @click.stop="closeTab(tab.path)"
            >
              <Close />
            </el-icon>
          </div>
        </div>
        <div class="header-right">
          <el-tooltip content="帮助" placement="bottom">
            <el-icon class="header-icon-row1" @click="onHelp"><QuestionFilled /></el-icon>
          </el-tooltip>
          <el-tooltip content="通知" placement="bottom">
            <el-icon class="header-icon-row1" @click="onNotification"><Bell /></el-icon>
          </el-tooltip>
          <el-tooltip content="消息" placement="bottom">
            <el-icon class="header-icon-row1" @click="onMessage"><ChatDotRound /></el-icon>
          </el-tooltip>
          <el-tooltip content="设置" placement="bottom">
            <el-icon class="header-icon-row1" @click="onSetting"><Setting /></el-icon>
          </el-tooltip>
          <el-dropdown @command="handleCommand">
            <span class="user-info">
              <el-avatar :size="28" class="user-avatar">{{ userInitial }}</el-avatar>
              {{ currentUser?.realName || currentUser?.real_name || currentUser?.username || '用户' }}
              <el-icon class="el-icon--right"><ArrowDown /></el-icon>
            </span>
            <template #dropdown>
              <el-dropdown-menu>
                <el-dropdown-item command="logout">退出登录</el-dropdown-item>
              </el-dropdown-menu>
            </template>
          </el-dropdown>
        </div>
      </div>
      <!-- 顶栏第二行：全局筛选 + 时区 -->
      <div class="header-row header-row-2">
        <div class="filter-bar">
          <el-select v-model="filterCountry" placeholder="全部国家" clearable style="width: 120px" />
          <el-select v-model="filterShop" placeholder="全部店铺" clearable style="width: 120px" />
          <el-select v-model="filterOwner" placeholder="Listing负责人" clearable style="width: 140px" />
          <el-select v-model="filterCurrency" placeholder="货币" style="width: 90px">
            <el-option label="USD" value="USD" />
            <el-option label="CNY" value="CNY" />
          </el-select>
          <el-button @click="handleFilterReset">重置</el-button>
        </div>
        <div class="timezone-bar">
          <span class="tz-item">北京 {{ timeBeijing }}</span>
          <span class="tz-item">英国 {{ timeUK }}</span>
          <span class="tz-item">美东 {{ timeUSEast }}</span>
          <span class="tz-item">太平洋 {{ timePacific }}</span>
          <el-dropdown trigger="click">
            <el-icon class="header-icon"><Clock /></el-icon>
            <template #dropdown>
              <el-dropdown-menu><el-dropdown-item>时区设置</el-dropdown-item></el-dropdown-menu>
            </template>
          </el-dropdown>
          <el-button type="primary" link size="small">旧版</el-button>
        </div>
        <div class="header-actions-right">
          <el-dropdown trigger="click" @command="handleGuideCommand">
            <span class="header-action">初始化引导<el-icon><ArrowDown /></el-icon></span>
            <template #dropdown>
              <el-dropdown-menu>
                <el-dropdown-item command="show" :disabled="!guideSectionHidden">
                  显示初始化引导
                </el-dropdown-item>
                <el-dropdown-item command="hide" :disabled="guideSectionHidden">
                  隐藏初始化引导
                </el-dropdown-item>
              </el-dropdown-menu>
            </template>
          </el-dropdown>
          <el-icon class="header-icon"><Refresh /></el-icon>
          <el-icon class="header-icon"><QuestionFilled /></el-icon>
          <el-icon class="header-icon"><Setting /></el-icon>
        </div>
      </div>
      <el-main class="main-content">
        <router-view />
      </el-main>
    </el-container>
  </el-container>
</template>

<script setup>
import { computed, ref, watch, onMounted, onUnmounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { storeToRefs } from 'pinia'
import { useUserStore } from '@/store/user'
import { useDashboardStore } from '@/store/dashboard'
import { ElMessageBox, ElMessage } from 'element-plus'
import {
  HomeFilled,
  User,
  Shop,
  ShoppingBag,
  Goods,
  ShoppingCart,
  Money,
  Box,
  ArrowDown,
  Clock,
  Refresh,
  QuestionFilled,
  Setting,
  Close,
  Bell,
  ChatDotRound
} from '@element-plus/icons-vue'

const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const dashboardStore = useDashboardStore()
const { guideSectionHidden } = storeToRefs(dashboardStore)

const sidebarBg = '#1a2332'

/** 顶栏「初始化引导」下拉：显示/隐藏首页初始化引导模块 */
function handleGuideCommand(command) {
  if (command === 'show') dashboardStore.showGuideSection()
  else if (command === 'hide') dashboardStore.hideGuideSection()
}

// 首页固定，其余标签在点击左侧菜单打开对应页面时动态添加
const openedTabs = ref([])
const topTabs = computed(() => [
  { path: '/dashboard', title: '首页' },
  ...openedTabs.value
])

watch(
  () => route.path,
  (path) => {
    if (path === '/dashboard' || !path) return
    const title = route.meta?.title
    if (!title) return
    if (openedTabs.value.some((t) => t.path === path)) return
    openedTabs.value.push({ path, title })
  },
  { immediate: true }
)

const filterCountry = ref('')
const filterShop = ref('')
const filterOwner = ref('')
const filterCurrency = ref('USD')

const timeBeijing = ref('')
const timeUK = ref('')
const timeUSEast = ref('')
const timePacific = ref('')

let timer = null
function formatInTZ(date, tz) {
  try {
    return new Intl.DateTimeFormat('zh-CN', {
      timeZone: tz,
      month: '2-digit',
      day: '2-digit',
      hour: '2-digit',
      minute: '2-digit',
      hour12: false
    }).format(date)
  } catch {
    return '--'
  }
}
function updateTimes() {
  const d = new Date()
  timeBeijing.value = formatInTZ(d, 'Asia/Shanghai')
  timeUK.value = formatInTZ(d, 'Europe/London')
  timeUSEast.value = formatInTZ(d, 'America/New_York')
  timePacific.value = formatInTZ(d, 'America/Los_Angeles')
}

const activeMenu = computed(() => route.path)
const currentUser = computed(() => userStore.currentUser())
const userInitial = computed(() => {
  const name = currentUser.value?.realName || currentUser.value?.real_name || currentUser.value?.username || '用'
  return name.charAt(0)
})

function isTabActive(path) {
  return route.path === path
}

/** 关闭顶部标签（首页不可关闭） */
function closeTab(path) {
  if (path === '/dashboard') return
  const idx = openedTabs.value.findIndex((t) => t.path === path)
  if (idx === -1) return
  const wasActive = route.path === path
  openedTabs.value.splice(idx, 1)
  if (wasActive) {
    // 若关闭的是当前页，跳转到相邻标签或首页
    const remaining = openedTabs.value
    if (remaining.length > 0) {
      const nextIdx = Math.min(idx, remaining.length - 1)
      router.push(remaining[nextIdx].path)
    } else {
      router.push('/dashboard')
    }
  }
}

function handleFilterReset() {
  filterCountry.value = ''
  filterShop.value = ''
  filterOwner.value = ''
  filterCurrency.value = 'USD'
}

function onHelp() {
  ElMessage.info('帮助中心（占位）')
}
function onNotification() {
  ElMessage.info('通知（占位）')
}
function onMessage() {
  ElMessage.info('消息（占位）')
}
function onSetting() {
  ElMessage.info('设置（占位）')
}

const handleCommand = async (command) => {
  if (command === 'logout') {
    try {
      await ElMessageBox.confirm('确定要退出登录吗？', '提示', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      })
      userStore.logout()
      router.push('/login')
    } catch {
      // 用户取消
    }
  }
}

onMounted(() => {
  updateTimes()
  timer = setInterval(updateTimes, 1000)
})
onUnmounted(() => {
  if (timer) clearInterval(timer)
})
</script>

<style scoped>
.layout-container {
  height: 100vh;
}

.sidebar {
  background-color: var(--sidebar-bg);
  overflow-y: auto;
}

.logo {
  height: 56px;
  display: flex;
  align-items: center;
  justify-content: center;
  background-color: var(--sidebar-bg-logo);
}

.logo-erp {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  min-width: 44px;
  height: 32px;
  padding: 0 10px;
  font-size: 15px;
  font-weight: 700;
  letter-spacing: 0.08em;
  color: #fff;
  background: linear-gradient(135deg, #409eff 0%, #66b1ff 100%);
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(64, 158, 255, 0.35);
  user-select: none;
}

.sidebar-menu {
  border: none;
  padding: 0;
  width: 100%;
  display: flex;
  flex-direction: column;
  align-items: center;
}

/* 清除 Element 菜单默认左内边距，保证整列居中 */
.sidebar-menu :deep(ul),
.sidebar-menu :deep(.el-menu) {
  padding-left: 0 !important;
  padding-right: 0 !important;
  display: flex;
  flex-direction: column;
  align-items: center;
  width: 100%;
}

.sidebar-menu :deep(.el-menu-item) {
  height: 64px;
  padding: 0 !important;
  margin: 0;
  display: flex;
  align-items: center;
  justify-content: center;
  text-align: center;
  width: 100%;
}

.sidebar-menu :deep(.el-menu-item > *) {
  width: 100%;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  text-align: center;
  margin: 0 !important;
  padding: 0 !important;
}

.sidebar-menu :deep(.el-menu > li) {
  width: 100%;
  padding-left: 0 !important;
  padding-right: 0 !important;
}

.menu-item-inner {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 6px;
  width: 100%;
}

.menu-icon {
  font-size: 26px;
}

.menu-label {
  font-size: 12px;
  line-height: 1;
}

.sidebar-menu :deep(.el-menu-item.is-active) {
  color: var(--sidebar-text-active);
  background-color: rgba(64, 158, 255, 0.15);
}

.right-container {
  display: flex;
  flex-direction: column;
  min-width: 0;
}

.header-row {
  background: var(--header-bg);
  border-bottom: 1px solid var(--header-border);
  display: flex;
  align-items: center;
  padding: 0 16px;
  flex-shrink: 0;
}

.header-row-1 {
  min-height: 48px;
  justify-content: space-between;
}

.header-row-2 {
  min-height: 44px;
  gap: 16px;
  flex-wrap: wrap;
}

.header-left {
  display: flex;
  align-items: center;
  gap: 8px;
}

.tab-item {
  display: inline-flex;
  align-items: center;
  padding: 8px 8px 8px 12px;
  border-radius: 4px;
  font-size: 14px;
}

.tab-item:hover .tab-close {
  opacity: 1;
}

.tab-link {
  color: var(--text-regular);
  text-decoration: none;
}

.tab-link:hover {
  color: var(--primary-color);
}

.tab-item.active .tab-link {
  color: var(--primary-color);
}

.tab-item.active {
  background: rgba(64, 158, 255, 0.1);
}

.tab-close {
  margin-left: 4px;
  font-size: 14px;
  color: var(--text-regular);
  cursor: pointer;
  opacity: 0.6;
}

.tab-close:hover {
  color: var(--el-color-danger);
  opacity: 1;
}

.header-right {
  display: flex;
  align-items: center;
  gap: 12px;
}

.header-icon-row1 {
  font-size: 18px;
  color: var(--text-regular);
  cursor: pointer;
  padding: 4px;
}

.header-icon-row1:hover {
  color: var(--primary-color);
}

.header-action {
  cursor: pointer;
  display: inline-flex;
  align-items: center;
  font-size: 14px;
  color: var(--text-primary);
}

.header-icon {
  font-size: 18px;
  color: var(--text-regular);
  cursor: pointer;
}

.header-icon:hover {
  color: var(--primary-color);
}

.user-info {
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 8px;
  color: var(--text-primary);
  font-size: 14px;
}

.user-avatar {
  background: var(--primary-color);
  color: #fff;
}

.filter-bar {
  display: flex;
  align-items: center;
  gap: 12px;
}

.timezone-bar {
  display: flex;
  align-items: center;
  gap: 12px;
  font-size: 12px;
  color: var(--text-secondary);
}

.tz-item {
  white-space: nowrap;
}

.header-actions-right {
  margin-left: auto;
  display: flex;
  align-items: center;
  gap: 8px;
}

.main-content {
  background: var(--main-bg);
  padding: var(--page-padding);
  overflow: auto;
  flex: 1;
}
</style>
