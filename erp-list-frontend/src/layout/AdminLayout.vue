<template>
  <el-container class="admin-layout">
    <el-aside width="200px" class="admin-aside">
      <div class="admin-logo">管理后台</div>
      <el-menu
        :default-active="activeMenu"
        router
        class="admin-menu"
        background-color="#1a2332"
        text-color="#bfcbd9"
        active-text-color="#409EFF"
      >
        <el-menu-item index="/admin/dashboard">
          <el-icon><HomeFilled /></el-icon>
          <span>管理首页</span>
        </el-menu-item>
        <el-sub-menu index="company">
          <template #title>
            <el-icon><OfficeBuilding /></el-icon>
            <span>公司管理</span>
          </template>
          <el-menu-item index="/admin/companies/onboard">开通公司</el-menu-item>
          <el-menu-item index="/admin/companies">公司列表</el-menu-item>
        </el-sub-menu>
        <el-menu-item index="/admin/users">
          <el-icon><User /></el-icon>
          <span>用户管理</span>
        </el-menu-item>
        <el-menu-item index="/admin/data-view">
          <el-icon><DataAnalysis /></el-icon>
          <span>数据查看</span>
        </el-menu-item>
        <el-menu-item index="/admin/audit-logs">
          <el-icon><Document /></el-icon>
          <span>审计日志</span>
        </el-menu-item>
      </el-menu>
    </el-aside>
    <el-container class="admin-main-wrap">
      <header class="admin-header">
        <div class="header-left">
          <router-link to="/" class="link-client">返回客户端</router-link>
        </div>
        <div class="header-right">
          <el-dropdown @command="handleCommand">
            <span class="user-info">
              <el-avatar :size="28" class="user-avatar">{{ userInitial }}</el-avatar>
              {{ currentUser?.realName || currentUser?.real_name || currentUser?.username || '管理员' }}
              <el-icon><ArrowDown /></el-icon>
            </span>
            <template #dropdown>
              <el-dropdown-menu>
                <el-dropdown-item command="logout">退出登录</el-dropdown-item>
              </el-dropdown-menu>
            </template>
          </el-dropdown>
        </div>
      </header>
      <el-main class="admin-main">
        <router-view />
      </el-main>
    </el-container>
  </el-container>
</template>

<script setup>
import { computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useUserStore } from '@/store/user'
import { ElMessageBox, ElMessage } from 'element-plus'
import { HomeFilled, OfficeBuilding, User, DataAnalysis, Document, ArrowDown } from '@element-plus/icons-vue'

const route = useRoute()
const router = useRouter()
const userStore = useUserStore()

const activeMenu = computed(() => route.path)
const currentUser = computed(() => userStore.currentUser())
const userInitial = computed(() => {
  const name = currentUser.value?.realName || currentUser.value?.real_name || currentUser.value?.username || '管'
  return name.charAt(0)
})

function handleCommand(command) {
  if (command === 'logout') {
    ElMessageBox.confirm('确定要退出登录吗？', '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
      .then(() => {
        userStore.logout()
        router.push('/login')
      })
      .catch(() => {})
  }
}
</script>

<style scoped>
.admin-layout {
  height: 100vh;
}

.admin-aside {
  background-color: #1a2332;
}

.admin-logo {
  height: 56px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #fff;
  font-weight: 600;
  font-size: 16px;
  border-bottom: 1px solid rgba(255, 255, 255, 0.1);
}

.admin-menu {
  border: none;
}

.admin-main-wrap {
  display: flex;
  flex-direction: column;
  min-width: 0;
}

.admin-header {
  height: 48px;
  padding: 0 16px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  background: var(--header-bg, #fff);
  border-bottom: 1px solid var(--header-border, #ebeef5);
}

.header-left .link-client {
  color: var(--el-color-primary);
  text-decoration: none;
  font-size: 14px;
}

.header-left .link-client:hover {
  text-decoration: underline;
}

.user-info {
  display: flex;
  align-items: center;
  gap: 8px;
  cursor: pointer;
  color: var(--text-primary, #303133);
  font-size: 14px;
}

.user-avatar {
  background: var(--el-color-primary);
  color: #fff;
}

.admin-main {
  flex: 1;
  padding: var(--page-padding, 16px);
  overflow: auto;
  background: var(--main-bg, #f5f7fa);
}
</style>
