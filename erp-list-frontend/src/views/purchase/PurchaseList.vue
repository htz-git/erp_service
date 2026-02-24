<template>
  <div class="page purchase-list-page">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>采购管理</span>
        </div>
      </template>

      <!-- 筛选区 -->
      <div class="filter-section">
        <el-form :model="filterForm" inline class="filter-form">
          <el-form-item label="采购单号">
            <el-input v-model="filterForm.purchaseNo" placeholder="采购单号" clearable style="width: 160px" />
          </el-form-item>
          <el-form-item label="供应商ID">
            <el-input v-model.number="filterForm.supplierId" placeholder="供应商ID" clearable style="width: 110px" />
          </el-form-item>
          <el-form-item label="店铺">
            <el-select
              v-model="filterForm.sid"
              placeholder="全部店铺"
              clearable
              style="width: 160px"
              :loading="shopOptionsLoading"
            >
              <el-option
                v-for="s in shopOptions"
                :key="s.id"
                :label="s.sellerName || s.seller_name || `店铺 ${s.id}`"
                :value="s.id"
              />
            </el-select>
          </el-form-item>
          <el-form-item label="采购状态">
            <el-select v-model="filterForm.purchaseStatus" placeholder="全部" clearable style="width: 100px">
              <el-option label="待提交" :value="0" />
              <el-option label="待审批" :value="1" />
              <el-option label="已通过" :value="2" />
              <el-option label="已入库" :value="3" />
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
          <el-table-column prop="purchaseNo" label="采购单号" width="160" show-overflow-tooltip />
          <el-table-column prop="supplierName" label="供应商" width="120" show-overflow-tooltip />
          <el-table-column prop="totalAmount" label="总金额" width="100" align="right">
            <template #default="{ row }">{{ row.totalAmount ?? '-' }}</template>
          </el-table-column>
          <el-table-column prop="purchaseStatus" label="采购状态" width="90" align="center">
            <template #default="{ row }">{{ purchaseStatusText(row.purchaseStatus) }}</template>
          </el-table-column>
          <el-table-column prop="purchaserName" label="采购员" width="100" />
          <el-table-column prop="expectedArrivalTime" label="预计到货" width="170" />
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
          @size-change="handleSizeChange"
          @current-change="fetchList"
        />
      </div>
    </el-card>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, computed } from 'vue'
import { ElMessage } from 'element-plus'
import { useUserStore } from '@/store/user'
import { purchaseApi } from '@/api/purchase'
import { sellerApi } from '@/api/seller'

const userStore = useUserStore()
const currentZid = computed(() => userStore.currentZid())

const loading = ref(false)
const list = ref([])
const shopOptions = ref([])
const shopOptionsLoading = ref(false)

const filterForm = ref({
  purchaseNo: '',
  supplierId: null,
  sid: null,
  purchaseStatus: null,
  purchaserId: null
})
const pagination = reactive({
  pageNum: 1,
  pageSize: 10,
  total: 0
})

const purchaseStatusMap = { 0: '待提交', 1: '待审批', 2: '已通过', 3: '已入库' }
function purchaseStatusText(v) {
  return v != null ? purchaseStatusMap[v] ?? v : '-'
}

function buildParams() {
  const p = {
    pageNum: pagination.pageNum,
    pageSize: pagination.pageSize
  }
  const zid = currentZid.value
  if (zid != null && zid !== '') p.zid = zid
  if (filterForm.value.purchaseNo) p.purchaseNo = filterForm.value.purchaseNo
  if (filterForm.value.supplierId != null && filterForm.value.supplierId !== '') p.supplierId = filterForm.value.supplierId
  if (filterForm.value.sid != null && filterForm.value.sid !== '') p.sid = filterForm.value.sid
  if (filterForm.value.purchaseStatus !== null && filterForm.value.purchaseStatus !== '') p.purchaseStatus = filterForm.value.purchaseStatus
  if (filterForm.value.purchaserId != null && filterForm.value.purchaserId !== '') p.purchaserId = filterForm.value.purchaserId
  return p
}

async function fetchList() {
  loading.value = true
  try {
    const res = await purchaseApi.queryPurchaseOrders(buildParams())
    list.value = res.data?.records ?? []
    pagination.total = res.data?.total ?? 0
  } catch (e) {
    list.value = []
    ElMessage.error(e.message || '加载失败')
  } finally {
    loading.value = false
  }
}

function handleSizeChange() {
  pagination.pageNum = 1
  fetchList()
}

function handleSearch() {
  pagination.pageNum = 1
  fetchList()
}

function handleReset() {
  filterForm.value = {
    purchaseNo: '',
    supplierId: null,
    sid: null,
    purchaseStatus: null,
    purchaserId: null
  }
  pagination.pageNum = 1
  fetchList()
}

async function loadShopOptions() {
  const zid = currentZid.value
  if (zid == null || zid === '') {
    shopOptions.value = []
    return
  }
  shopOptionsLoading.value = true
  try {
    const res = await sellerApi.querySellers({ zid, pageNum: 1, pageSize: 500 })
    shopOptions.value = res.data?.records ?? []
  } catch {
    shopOptions.value = []
  } finally {
    shopOptionsLoading.value = false
  }
}

onMounted(() => {
  loadShopOptions()
  fetchList()
})
</script>

<style scoped>
.purchase-list-page { padding: 20px; }
.card-header { font-size: 18px; font-weight: bold; }
.filter-section { margin-bottom: 16px; }
.filter-form { margin: 0; }
.table-section { margin-top: 12px; }
.pagination-section { margin-top: 16px; display: flex; justify-content: flex-end; }
</style>
