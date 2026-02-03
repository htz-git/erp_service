<template>
  <div class="page coupon-list-page">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>优惠券管理</span>
        </div>
      </template>

      <!-- 筛选区 -->
      <div class="filter-section">
        <el-form :model="filterForm" inline class="filter-form">
          <el-form-item label="优惠券名称">
            <el-input v-model="filterForm.couponName" placeholder="优惠券名称" clearable style="width: 160px" />
          </el-form-item>
          <el-form-item label="类型">
            <el-select v-model="filterForm.couponType" placeholder="全部" clearable style="width: 120px">
              <el-option label="折扣券" value="discount" />
              <el-option label="满减券" value="cash" />
              <el-option label="通用券" value="general" />
            </el-select>
          </el-form-item>
          <el-form-item label="状态">
            <el-select v-model="filterForm.status" placeholder="全部" clearable style="width: 100px">
              <el-option label="未生效" :value="0" />
              <el-option label="生效中" :value="1" />
              <el-option label="已过期" :value="2" />
              <el-option label="已禁用" :value="3" />
            </el-select>
          </el-form-item>
          <el-form-item>
            <el-button type="primary" :loading="loading" @click="handleSearch">查询</el-button>
            <el-button @click="handleReset">重置</el-button>
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
          <el-table-column prop="id" label="ID" width="80" />
          <el-table-column prop="couponName" label="优惠券名称" min-width="140" show-overflow-tooltip />
          <el-table-column prop="couponType" label="类型" width="100" />
          <el-table-column prop="discountRate" label="折扣率" width="90" align="right">
            <template #default="{ row }">{{ row.discountRate ?? '-' }}</template>
          </el-table-column>
          <el-table-column prop="discountAmount" label="面额" width="90" align="right">
            <template #default="{ row }">{{ row.discountAmount ?? '-' }}</template>
          </el-table-column>
          <el-table-column prop="minAmount" label="最低消费" width="100" align="right">
            <template #default="{ row }">{{ row.minAmount ?? '-' }}</template>
          </el-table-column>
          <el-table-column prop="totalCount" label="总量" width="80" align="right" />
          <el-table-column prop="usedCount" label="已用" width="80" align="right" />
          <el-table-column prop="startTime" label="开始时间" width="170" />
          <el-table-column prop="endTime" label="结束时间" width="170" />
          <el-table-column prop="status" label="状态" width="90" align="center">
            <template #default="{ row }">{{ statusText(row.status) }}</template>
          </el-table-column>
          <el-table-column label="操作" width="160" fixed="right">
            <template #default="{ row }">
              <el-button
                v-if="row.status === 3"
                type="success"
                link
                size="small"
                @click="handleToggleStatus(row, 1)"
              >
                启用
              </el-button>
              <el-button
                v-else-if="row.status === 1"
                type="warning"
                link
                size="small"
                @click="handleToggleStatus(row, 3)"
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
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { couponApi } from '@/api/coupon'

const loading = ref(false)
const list = ref([])
const filterForm = ref({
  couponName: '',
  couponType: null,
  status: null
})
const pagination = reactive({
  pageNum: 1,
  pageSize: 10,
  total: 0
})

const statusMap = { 0: '未生效', 1: '生效中', 2: '已过期', 3: '已禁用' }
function statusText(v) {
  return v != null ? statusMap[v] ?? v : '-'
}

function buildParams() {
  const p = {
    pageNum: pagination.pageNum,
    pageSize: pagination.pageSize
  }
  if (filterForm.value.couponName) p.couponName = filterForm.value.couponName
  if (filterForm.value.couponType) p.couponType = filterForm.value.couponType
  if (filterForm.value.status !== null && filterForm.value.status !== '') p.status = filterForm.value.status
  return p
}

async function fetchList() {
  loading.value = true
  try {
    const res = await couponApi.queryCoupons(buildParams())
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
  filterForm.value = { couponName: '', couponType: null, status: null }
  pagination.pageNum = 1
  fetchList()
}

async function handleToggleStatus(row, status) {
  try {
    await ElMessageBox.confirm(
      status === 1 ? '确定启用该优惠券？' : '确定禁用该优惠券？',
      '提示',
      { confirmButtonText: '确定', cancelButtonText: '取消', type: 'warning' }
    )
    await couponApi.updateCouponStatus(row.id, status)
    ElMessage.success('操作成功')
    fetchList()
  } catch (e) {
    if (e !== 'cancel') ElMessage.error(e.message || '操作失败')
  }
}

async function handleDelete(row) {
  try {
    await ElMessageBox.confirm('确定删除该优惠券？', '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
    await couponApi.deleteCoupon(row.id)
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
.coupon-list-page { padding: 20px; }
.card-header { font-size: 18px; font-weight: bold; }
.filter-section { margin-bottom: 16px; }
.filter-form { margin: 0; }
.table-section { margin-top: 12px; }
.pagination-section { margin-top: 16px; display: flex; justify-content: flex-end; }
</style>
