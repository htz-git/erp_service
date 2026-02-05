<template>
  <div class="page">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>公司列表</span>
          <el-button type="primary" @click="goOnboard">开通公司</el-button>
        </div>
      </template>

      <div class="filter-section">
        <el-form :model="filterForm" inline class="filter-form">
          <el-form-item label="zid">
            <el-input v-model="filterForm.zid" placeholder="公司ID" clearable style="width: 120px" />
          </el-form-item>
          <el-form-item label="公司名称">
            <el-input v-model="filterForm.companyName" placeholder="公司名称" clearable style="width: 160px" />
          </el-form-item>
          <el-form-item label="状态">
            <el-select v-model="filterForm.status" placeholder="全部" clearable style="width: 100px">
              <el-option label="启用" :value="1" />
              <el-option label="禁用" :value="0" />
            </el-select>
          </el-form-item>
          <el-form-item>
            <el-button type="primary" :loading="loading" @click="fetchList">查询</el-button>
            <el-button @click="handleReset">重置</el-button>
          </el-form-item>
        </el-form>
      </div>

      <el-table v-loading="loading" :data="list" stripe border style="width: 100%">
        <el-table-column prop="id" label="zid" width="80" />
        <el-table-column prop="companyName" label="公司名称" min-width="140" show-overflow-tooltip />
        <el-table-column prop="contactName" label="联系人" width="100" />
        <el-table-column prop="contactPhone" label="电话" width="120" />
        <el-table-column prop="contactEmail" label="邮箱" width="160" show-overflow-tooltip />
        <el-table-column prop="address" label="地址" min-width="140" show-overflow-tooltip />
        <el-table-column prop="status" label="状态" width="80" align="center">
          <template #default="{ row }">
            <el-tag :type="row.status === 1 ? 'success' : 'info'">
              {{ row.status === 1 ? '启用' : '禁用' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="remark" label="备注" width="120" show-overflow-tooltip />
        <el-table-column prop="createTime" label="创建时间" width="170" />
        <el-table-column label="操作" width="160" fixed="right">
          <template #default="{ row }">
            <el-button type="primary" link size="small" @click="goDetail(row.id)">详情/编辑</el-button>
            <el-button
              v-if="row.status === 0"
              type="success"
              link
              size="small"
              @click="handleStatus(row, 1)"
            >
              启用
            </el-button>
            <el-button v-else type="warning" link size="small" @click="handleStatus(row, 0)">
              禁用
            </el-button>
          </template>
        </el-table-column>
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
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { adminApi } from '@/api/admin'

const router = useRouter()
const loading = ref(false)
const list = ref([])

const filterForm = reactive({
  zid: '',
  companyName: '',
  status: null
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
      zid: filterForm.zid || undefined,
      companyName: filterForm.companyName || undefined,
      status: filterForm.status ?? undefined
    }
    const data = await adminApi.listCompanies(params)
    list.value = data.records || []
    pagination.total = data.total || 0
  } catch (e) {
    ElMessage.error(e.message || '加载失败')
  } finally {
    loading.value = false
  }
}

function handleReset() {
  filterForm.zid = ''
  filterForm.companyName = ''
  filterForm.status = null
  pagination.pageNum = 1
  fetchList()
}

function goOnboard() {
  router.push('/admin/companies/onboard')
}

function goDetail(zid) {
  router.push(`/admin/companies/${zid}`)
}

async function handleStatus(row, status) {
  try {
    await adminApi.updateCompanyStatus(row.id, status)
    ElMessage.success(status === 1 ? '已启用' : '已禁用')
    fetchList()
  } catch (e) {
    ElMessage.error(e.message || '操作失败')
  }
}

onMounted(() => fetchList())
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
.pagination-section {
  margin-top: 16px;
  display: flex;
  justify-content: flex-end;
}
</style>
