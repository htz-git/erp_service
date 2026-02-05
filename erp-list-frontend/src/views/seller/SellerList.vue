<template>
  <div class="page seller-list-page">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>授权店铺</span>
          <span class="card-subtitle">创建并授权公司下店铺</span>
        </div>
      </template>

      <!-- 筛选区 -->
      <div class="filter-section">
        <el-form :model="filterForm" inline class="filter-form">
          <el-form-item label="店铺名称">
            <el-input v-model="filterForm.sellerName" placeholder="店铺名称" clearable style="width: 160px" />
          </el-form-item>
          <el-form-item label="平台">
            <el-select v-model="filterForm.platform" placeholder="全部" clearable style="width: 120px">
              <el-option label="亚马逊" value="amazon" />
              <el-option label="eBay" value="ebay" />
              <el-option label="速卖通" value="aliexpress" />
            </el-select>
          </el-form-item>
          <el-form-item label="用户ID">
            <el-input v-model.number="filterForm.userId" placeholder="用户ID" clearable style="width: 100px" />
          </el-form-item>
          <el-form-item label="状态">
            <el-select v-model="filterForm.status" placeholder="全部" clearable style="width: 100px">
              <el-option label="启用" :value="1" />
              <el-option label="禁用" :value="0" />
            </el-select>
          </el-form-item>
          <el-form-item>
            <el-button type="primary" :loading="loading" @click="handleSearch">查询</el-button>
            <el-button @click="handleReset">重置</el-button>
            <el-button type="primary" @click="goCreate">新增店铺</el-button>
          </el-form-item>
        </el-form>
      </div>

      <!-- 表格 -->
      <div class="table-section">
        <el-table
          v-loading="loading"
          :data="list"
          stripe
          border
          style="width: 100%"
        >
          <el-table-column prop="id" label="ID(sid)" width="90" />
          <el-table-column prop="sellerName" label="店铺名称" min-width="140" show-overflow-tooltip />
          <el-table-column prop="platform" label="平台" width="100" />
          <el-table-column prop="platformAccount" label="平台账号" width="120" show-overflow-tooltip />
          <el-table-column prop="userId" label="用户ID" width="90" />
          <el-table-column prop="status" label="状态" width="80" align="center">
            <template #default="{ row }">
              <el-tag :type="row.status === 1 ? 'success' : 'info'">
                {{ row.status === 1 ? '启用' : '禁用' }}
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column prop="authorizeTime" label="授权时间" width="170" />
          <el-table-column prop="createTime" label="创建时间" width="170" />
          <el-table-column label="操作" width="180" fixed="right">
            <template #default="{ row }">
              <el-button
                v-if="row.status === 0"
                type="success"
                link
                size="small"
                @click="handleToggleStatus(row, 1)"
              >
                启用
              </el-button>
              <el-button
                v-else
                type="warning"
                link
                size="small"
                @click="handleToggleStatus(row, 0)"
              >
                禁用
              </el-button>
              <el-button type="danger" link size="small" @click="handleDelete(row)">删除</el-button>
            </template>
          </el-table-column>
        </el-table>
      </div>

      <!-- 分页 -->
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
import { ref, reactive, onMounted, computed } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { useUserStore } from '@/store/user'
import { sellerApi } from '@/api/seller'

const router = useRouter()
const userStore = useUserStore()
const currentZid = computed(() => userStore.currentZid())

const loading = ref(false)
const list = ref([])
const filterForm = ref({
  sellerName: '',
  platform: null,
  userId: null,
  status: null
})
const pagination = reactive({
  pageNum: 1,
  pageSize: 10,
  total: 0
})

function buildParams() {
  const p = {
    pageNum: pagination.pageNum,
    pageSize: pagination.pageSize
  }
  const zid = currentZid.value
  if (zid != null && zid !== '') p.zid = zid
  if (filterForm.value.sellerName) p.sellerName = filterForm.value.sellerName
  if (filterForm.value.platform) p.platform = filterForm.value.platform
  if (filterForm.value.userId != null && filterForm.value.userId !== '') p.userId = filterForm.value.userId
  if (filterForm.value.status !== null && filterForm.value.status !== '') p.status = filterForm.value.status
  return p
}

async function fetchList() {
  loading.value = true
  try {
    const res = await sellerApi.querySellers(buildParams())
    list.value = res.data?.records ?? []
    pagination.total = res.data?.total ?? 0
  } catch (e) {
    list.value = []
    ElMessage.error(e.message || '加载失败')
  } finally {
    loading.value = false
  }
}

function handleSearch() {
  pagination.pageNum = 1
  fetchList()
}

function handleReset() {
  filterForm.value = {
    sellerName: '',
    platform: null,
    userId: null,
    status: null
  }
  pagination.pageNum = 1
  fetchList()
}

function goCreate() {
  router.push('/seller/create')
}

async function handleToggleStatus(row, status) {
  try {
    await ElMessageBox.confirm(
      status === 1 ? '确定启用该店铺？' : '确定禁用该店铺？',
      '提示',
      { confirmButtonText: '确定', cancelButtonText: '取消', type: 'warning' }
    )
    await sellerApi.updateStatus(row.id, status)
    ElMessage.success('操作成功')
    fetchList()
  } catch (e) {
    if (e !== 'cancel') ElMessage.error(e.message || '操作失败')
  }
}

async function handleDelete(row) {
  try {
    await ElMessageBox.confirm('确定删除该店铺？', '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
    await sellerApi.deleteSeller(row.id)
    ElMessage.success('删除成功')
    fetchList()
  } catch (e) {
    if (e !== 'cancel') ElMessage.error(e.message || '删除失败')
  }
}

onMounted(() => {
  fetchList()
})
</script>

<style scoped>
.seller-list-page { padding: 0; }
.card-header { font-size: 16px; font-weight: 600; color: var(--text-primary); display: flex; flex-direction: column; gap: 4px; }
.card-subtitle { font-size: 12px; font-weight: normal; color: var(--text-secondary); }
.filter-section { margin-bottom: 16px; }
.filter-form { margin: 0; }
.table-section { margin-top: 12px; }
.pagination-section { margin-top: 16px; display: flex; justify-content: flex-end; }
</style>
