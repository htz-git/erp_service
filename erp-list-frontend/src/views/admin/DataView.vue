<template>
  <div class="page">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>数据查看（按公司）</span>
        </div>
      </template>

      <div class="filter-section">
        <el-form :model="filterForm" inline class="filter-form">
          <el-form-item label="zid">
            <el-input v-model="filterForm.zid" placeholder="公司ID筛选" clearable style="width: 120px" />
          </el-form-item>
          <el-form-item>
            <el-button type="primary" :loading="loading" @click="fetchData">查询</el-button>
            <el-button @click="handleReset">重置</el-button>
          </el-form-item>
        </el-form>
      </div>

      <el-table v-loading="loading" :data="list" stripe border style="width: 100%">
        <el-table-column prop="zid" label="公司 zid" width="100" />
        <el-table-column prop="companyName" label="公司名称" min-width="160" show-overflow-tooltip />
        <el-table-column prop="userCount" label="用户数" width="100" align="right" />
        <el-table-column prop="sellerCount" label="店铺数" width="100" align="right" />
      </el-table>
    </el-card>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { adminApi } from '@/api/admin'

const loading = ref(false)
const list = ref([])

const filterForm = reactive({ zid: '' })

async function fetchData() {
  loading.value = true
  try {
    const data = await adminApi.dataView(filterForm.zid || undefined)
    list.value = Array.isArray(data) ? data : []
  } catch (e) {
    ElMessage.error(e.message || '加载失败')
    list.value = []
  } finally {
    loading.value = false
  }
}

function handleReset() {
  filterForm.zid = ''
  fetchData()
}

onMounted(() => fetchData())
</script>

<style scoped>
.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}
.filter-section {
  margin-bottom: 16px;
}
</style>
