<template>
  <div class="page order-list-page">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>订单管理</span>
        </div>
      </template>

      <!-- 筛选区 -->
      <div class="filter-section">
        <el-form :model="filterForm" inline class="filter-form">
          <el-form-item label="订单号">
            <el-input v-model="filterForm.orderNo" placeholder="订单号" clearable style="width: 160px" />
          </el-form-item>
          <el-form-item label="用户ID">
            <el-input v-model.number="filterForm.userId" placeholder="用户ID" clearable style="width: 120px" />
          </el-form-item>
          <el-form-item label="zid">
            <el-input v-model="filterForm.zid" placeholder="zid" clearable style="width: 120px" />
          </el-form-item>
          <el-form-item label="sid">
            <el-input v-model.number="filterForm.sid" placeholder="sid" clearable style="width: 100px" />
          </el-form-item>
          <el-form-item label="订单状态">
            <el-select v-model="filterForm.orderStatus" placeholder="全部" clearable style="width: 100px">
              <el-option label="待支付" :value="0" />
              <el-option label="已支付" :value="1" />
              <el-option label="已发货" :value="2" />
              <el-option label="已完成" :value="3" />
              <el-option label="已取消" :value="4" />
            </el-select>
          </el-form-item>
          <el-form-item label="支付状态">
            <el-select v-model="filterForm.payStatus" placeholder="全部" clearable style="width: 100px">
              <el-option label="未支付" :value="0" />
              <el-option label="已支付" :value="1" />
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
          <el-table-column prop="orderNo" label="订单号" width="160" show-overflow-tooltip />
          <el-table-column prop="userId" label="用户ID" width="90" />
          <el-table-column prop="zid" label="zid" width="80" />
          <el-table-column prop="sid" label="sid" width="80" />
          <el-table-column prop="totalAmount" label="总金额" width="100" align="right">
            <template #default="{ row }">{{ row.totalAmount ?? '-' }}</template>
          </el-table-column>
          <el-table-column prop="payAmount" label="实付" width="100" align="right">
            <template #default="{ row }">{{ row.payAmount ?? '-' }}</template>
          </el-table-column>
          <el-table-column prop="orderStatus" label="订单状态" width="90" align="center">
            <template #default="{ row }">{{ orderStatusText(row.orderStatus) }}</template>
          </el-table-column>
          <el-table-column prop="payStatus" label="支付状态" width="90" align="center">
            <template #default="{ row }">{{ payStatusText(row.payStatus) }}</template>
          </el-table-column>
          <el-table-column prop="receiverName" label="收货人" width="100" />
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
import { orderApi } from '@/api/order'

const loading = ref(false)
const list = ref([])
const filterForm = ref({
  orderNo: '',
  userId: null,
  zid: '',
  sid: null,
  orderStatus: null,
  payStatus: null
})
const pagination = reactive({
  pageNum: 1,
  pageSize: 10,
  total: 0
})

const orderStatusMap = { 0: '待支付', 1: '已支付', 2: '已发货', 3: '已完成', 4: '已取消' }
const payStatusMap = { 0: '未支付', 1: '已支付' }
function orderStatusText(v) {
  return v != null ? orderStatusMap[v] ?? v : '-'
}
function payStatusText(v) {
  return v != null ? payStatusMap[v] ?? v : '-'
}

function buildParams() {
  const p = {
    pageNum: pagination.pageNum,
    pageSize: pagination.pageSize
  }
  if (filterForm.value.orderNo) p.orderNo = filterForm.value.orderNo
  if (filterForm.value.userId != null && filterForm.value.userId !== '') p.userId = filterForm.value.userId
  if (filterForm.value.zid) p.zid = filterForm.value.zid
  if (filterForm.value.sid != null && filterForm.value.sid !== '') p.sid = filterForm.value.sid
  if (filterForm.value.orderStatus !== null && filterForm.value.orderStatus !== '') p.orderStatus = filterForm.value.orderStatus
  if (filterForm.value.payStatus !== null && filterForm.value.payStatus !== '') p.payStatus = filterForm.value.payStatus
  return p
}

async function fetchList() {
  loading.value = true
  try {
    const res = await orderApi.queryOrders(buildParams())
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
    orderNo: '',
    userId: null,
    zid: '',
    sid: null,
    orderStatus: null,
    payStatus: null
  }
  pagination.pageNum = 1
  fetchList()
}

onMounted(() => {
  fetchList()
})
</script>

<style scoped>
.order-list-page { padding: 20px; }
.card-header { font-size: 18px; font-weight: bold; }
.filter-section { margin-bottom: 16px; }
.filter-form { margin: 0; }
.table-section { margin-top: 12px; }
.pagination-section { margin-top: 16px; display: flex; justify-content: flex-end; }
</style>
