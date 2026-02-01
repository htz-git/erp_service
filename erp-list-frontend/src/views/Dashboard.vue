<template>
  <div class="dashboard">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>欢迎使用 ERP List 管理系统</span>
        </div>
      </template>
      <div class="dashboard-content">
        <p>当前用户：{{ currentUser?.realName || currentUser?.username || '未知' }}</p>
        <p>公司ID：{{ currentUser?.zid || '未设置' }}</p>
      </div>
    </el-card>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { useUserStore } from '@/store/user'

const userStore = useUserStore()
const currentUser = computed(() => userStore.currentUser())
</script>

<style scoped>
.dashboard {
  padding: 20px;
}

.card-header {
  font-size: 18px;
  font-weight: bold;
}

.dashboard-content {
  padding: 20px 0;
}

.dashboard-content p {
  margin: 10px 0;
  font-size: 14px;
  color: #666;
}
</style>


