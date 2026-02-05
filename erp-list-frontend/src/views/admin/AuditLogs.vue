<template>
  <div class="page">
    <el-card>
      <template #header>
        <span>审计日志</span>
      </template>

      <div class="filter-section">
        <el-form :model="filterForm" inline class="filter-form">
          <el-form-item label="操作类型">
            <el-input v-model="filterForm.actionType" placeholder="如 user_disable" clearable style="width: 140px" />
          </el-form-item>
          <el-form-item label="对象类型">
            <el-input v-model="filterForm.targetType" placeholder="如 user" clearable style="width: 100px" />
          </el-form-item>
          <el-form-item label="对象ID">
            <el-input v-model="filterForm.targetId" placeholder="对象ID" clearable style="width: 120px" />
          </el-form-item>
          <el-form-item label="操作人ID">
            <el-input v-model="filterForm.operatorId" placeholder="操作人ID" clearable style="width: 120px" />
          </el-form-item>
          <el-form-item>
            <el-button type="primary" :loading="loading" @click="fetchList">查询</el-button>
            <el-button @click="handleReset">重置</el-button>
          </el-form-item>
        </el-form>
      </div>

      <el-table v-loading="loading" :data="list" stripe border style="width: 100%">
        <el-table-column prop="id" label="ID" width="80" />
        <el-table-column prop="operatorId" label="操作人ID" width="100" />
        <el-table-column prop="operatorName" label="操作人" width="120" />
        <el-table-column prop="actionType" label="操作类型" width="140" />
        <el-table-column prop="targetType" label="对象类型" width="100" />
        <el-table-column prop="targetId" label="对象ID" width="100" />
        <el-table-column prop="detail" label="详情" min-width="180" show-overflow-tooltip />
        <el-table-column prop="createTime" label="时间" width="170" />
      </el-table>

      <div class="pagination-section">
        <el-pagination
          v-model:current-page="pagination.pageNum"
          v-model:page-size="pagination.pageSize"
          :page-sizes="[10, 20, 50]"
          :total="pagination.total"
          layout="total, sizes, prev, pager, next"
          @size-change="fetchList"
          @current-change="fetchList"
        />
      </div>
    </el-card>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { adminApi } from '@/api/admin'

const loading = ref(false)
const list = ref([])

const filterForm = reactive({
  actionType: '',
  targetType: '',
  targetId: '',
  operatorId: ''
})

const pagination = reactive({
  pageNum: 1,
  pageSize: 10,
  total: 0
})

async function fetchList() {
  loading.value = true
  try {
    const params = {
      pageNum: pagination.pageNum,
      pageSize: pagination.pageSize,
      actionType: filterForm.actionType || undefined,
      targetType: filterForm.targetType || undefined,
      targetId: filterForm.targetId || undefined,
      operatorId: filterForm.operatorId || undefined
    }
    const data = await adminApi.listAuditLogs(params)
    list.value = data.records || []
    pagination.total = data.total || 0
  } catch (e) {
    ElMessage.error(e.message || '加载失败')
  } finally {
    loading.value = false
  }
}

function handleReset() {
  filterForm.actionType = ''
  filterForm.targetType = ''
  filterForm.targetId = ''
  filterForm.operatorId = ''
  pagination.pageNum = 1
  fetchList()
}

onMounted(() => fetchList())
</script>

<style scoped>
.filter-section {
  margin-bottom: 16px;
}
.pagination-section {
  margin-top: 16px;
  display: flex;
  justify-content: flex-end;
}
</style>
