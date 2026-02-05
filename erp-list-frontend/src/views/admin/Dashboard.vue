<template>
  <div class="admin-dashboard">
    <el-card>
      <template #header>
        <span>管理首页</span>
      </template>
      <p>欢迎使用 ERP List 管理后台。请从左侧菜单进入：公司管理、用户管理、数据查看、审计日志。</p>
    </el-card>
  </div>
</template>

<script setup>
</script>

<style scoped>
.admin-dashboard p {
  margin: 0;
  color: var(--text-regular);
}
</style>
