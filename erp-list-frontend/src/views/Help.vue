<template>
  <div class="help-page">
    <el-card class="section-card" shadow="hover">
      <template #header>
        <div class="card-header">
          <span>使用说明</span>
        </div>
      </template>
      <div class="help-section">
        <p>本系统为企业资源计划（ERP）客户端，主要功能包括：</p>
        <ul>
          <li><strong>首页</strong>：查看初始化引导、订单趋势与订单分布。</li>
          <li><strong>用户管理</strong>：管理本公司的用户账号。</li>
          <li><strong>店铺管理</strong>：管理关联的店铺信息。</li>
          <li><strong>订单管理</strong>：查看与处理订单。</li>
          <li><strong>商品管理</strong>：维护商品信息。</li>
          <li><strong>采购管理</strong>：创建与跟踪采购单。</li>
          <li><strong>退款管理</strong>：处理退款相关记录。</li>
          <li><strong>补货管理</strong>：生成与查看补货建议。</li>
          <li><strong>库存管理</strong>：查看库存明细。</li>
        </ul>
        <p>通过左侧菜单进入对应模块，顶栏可切换已打开的页面标签；点击「帮助」进入本页，「设置」可修改个人资料、时区显示与密码。</p>
      </div>
    </el-card>

    <el-card class="section-card" shadow="hover">
      <template #header>
        <div class="card-header">
          <span>常见问题</span>
        </div>
      </template>
      <div class="help-section">
        <div class="faq-item">
          <div class="faq-q">登录失败或提示「登录已过期」？</div>
          <div class="faq-a">请确认账号与密码正确；若此前已登录，可能因长时间未操作导致会话过期，请重新登录。</div>
        </div>
        <div class="faq-item">
          <div class="faq-q">看不到某些菜单或无权限操作？</div>
          <div class="faq-a">权限由管理员分配，请联系本公司管理员或平台管理员开通相应权限。</div>
        </div>
        <div class="faq-item">
          <div class="faq-q">页面数据不刷新？</div>
          <div class="faq-a">可点击顶栏第二行的刷新图标，或重新进入该页面；若仍异常，请尝试退出登录后重新登录。</div>
        </div>
      </div>
    </el-card>

    <el-card class="section-card" shadow="hover">
      <template #header>
        <div class="card-header">
          <span>联系支持</span>
        </div>
      </template>
      <div class="help-section">
        <p>如遇系统异常或需要进一步协助，请联系您的公司管理员或平台技术支持。</p>
      </div>
    </el-card>
  </div>
</template>

<script setup>
</script>

<style scoped>
.help-page {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.section-card {
  border-radius: 8px;
}

.section-card :deep(.el-card__header) {
  padding: 14px 20px;
  border-bottom: 1px solid var(--header-border);
}

.card-header {
  font-size: 18px;
  font-weight: bold;
}

.help-section {
  padding: 4px 0;
  line-height: 1.7;
  color: var(--text-regular);
}

.help-section ul {
  margin: 12px 0;
  padding-left: 24px;
}

.help-section li {
  margin: 6px 0;
}

.faq-item {
  margin-bottom: 16px;
}

.faq-q {
  font-weight: 600;
  color: var(--text-primary);
  margin-bottom: 6px;
}

.faq-a {
  color: var(--text-regular);
  padding-left: 12px;
}
</style>
