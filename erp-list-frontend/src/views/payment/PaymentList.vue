<template>
  <div class="page payment-list-page">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>支付管理</span>
        </div>
      </template>

      <!-- 筛选区 -->
      <div class="filter-section">
        <el-form :model="filterForm" inline class="filter-form">
          <el-form-item label="支付单号">
            <el-input v-model="filterForm.paymentNo" placeholder="支付单号" clearable style="width: 160px" />
          </el-form-item>
          <el-form-item label="订单号">
            <el-input v-model="filterForm.orderNo" placeholder="订单号" clearable style="width: 160px" />
          </el-form-item>
          <el-form-item label="订单ID">
            <el-input v-model.number="filterForm.orderId" placeholder="订单ID" clearable style="width: 100px" />
          </el-form-item>
          <el-form-item label="用户ID">
            <el-input v-model.number="filterForm.userId" placeholder="用户ID" clearable style="width: 100px" />
          </el-form-item>
          <el-form-item label="zid">
            <el-input v-model="filterForm.zid" placeholder="zid" clearable style="width: 100px" />
          </el-form-item>
          <el-form-item label="sid">
            <el-input v-model.number="filterForm.sid" placeholder="sid" clearable style="width: 80px" />
          </el-form-item>
          <el-form-item label="支付状态">
            <el-select v-model="filterForm.paymentStatus" placeholder="全部" clearable style="width: 100px">
              <el-option label="待支付" :value="0" />
              <el-option label="已支付" :value="1" />
              <el-option label="已退款" :value="2" />
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
          <el-table-column prop="paymentNo" label="支付单号" width="160" show-overflow-tooltip />
          <el-table-column prop="orderNo" label="订单号" width="160" show-overflow-tooltip />
          <el-table-column prop="userId" label="用户ID" width="90" />
          <el-table-column prop="paymentMethodName" label="支付方式" width="100" />
          <el-table-column prop="amount" label="金额" width="100" align="right">
            <template #default="{ row }">{{ row.amount ?? '-' }}</template>
          </el-table-column>
          <el-table-column prop="paymentStatus" label="支付状态" width="90" align="center">
            <template #default="{ row }">{{ paymentStatusText(row.paymentStatus) }}</template>
          </el-table-column>
          <el-table-column prop="payTime" label="支付时间" width="170" />
          <el-table-column prop="createTime" label="创建时间" width="170" />
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
import { ElMessage } from 'element-plus'
import { paymentApi } from '@/api/payment'

const loading = ref(false)
const list = ref([])
const filterForm = ref({
  paymentNo: '',
  orderNo: '',
  orderId: null,
  userId: null,
  zid: '',
  sid: null,
  paymentStatus: null
})
const pagination = reactive({
  pageNum: 1,
  pageSize: 10,
  total: 0
})

const paymentStatusMap = { 0: '待支付', 1: '已支付', 2: '已退款' }
function paymentStatusText(v) {
  return v != null ? paymentStatusMap[v] ?? v : '-'
}

function buildParams() {
  const p = {
    pageNum: pagination.pageNum,
    pageSize: pagination.pageSize
  }
  if (filterForm.value.paymentNo) p.paymentNo = filterForm.value.paymentNo
  if (filterForm.value.orderNo) p.orderNo = filterForm.value.orderNo
  if (filterForm.value.orderId != null && filterForm.value.orderId !== '') p.orderId = filterForm.value.orderId
  if (filterForm.value.userId != null && filterForm.value.userId !== '') p.userId = filterForm.value.userId
  if (filterForm.value.zid) p.zid = filterForm.value.zid
  if (filterForm.value.sid != null && filterForm.value.sid !== '') p.sid = filterForm.value.sid
  if (filterForm.value.paymentStatus !== null && filterForm.value.paymentStatus !== '') p.paymentStatus = filterForm.value.paymentStatus
  return p
}

async function fetchList() {
  loading.value = true
  try {
    const res = await paymentApi.queryPayments(buildParams())
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
    paymentNo: '',
    orderNo: '',
    orderId: null,
    userId: null,
    zid: '',
    sid: null,
    paymentStatus: null
  }
  pagination.pageNum = 1
  fetchList()
}

onMounted(() => {
  fetchList()
})
</script>

<style scoped>
.payment-list-page { padding: 0; }
.card-header { font-size: 16px; font-weight: 600; color: var(--text-primary); }
.filter-section { margin-bottom: 16px; }
.filter-form { margin: 0; }
.table-section { margin-top: 12px; }
.pagination-section { margin-top: 16px; display: flex; justify-content: flex-end; }
</style>
