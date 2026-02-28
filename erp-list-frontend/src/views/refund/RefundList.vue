<template>
  <div class="page refund-list-page">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>退款管理</span>
        </div>
      </template>

      <!-- 筛选区 -->
      <div class="filter-section">
        <el-form :model="filterForm" inline class="filter-form">
          <el-form-item label="退款单号">
            <el-input v-model="filterForm.refundNo" placeholder="退款单号" clearable style="width: 160px" />
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
          <el-form-item label="退款状态">
            <el-select v-model="filterForm.refundStatus" placeholder="全部" clearable style="width: 120px">
              <el-option label="待审核" :value="0" />
              <el-option label="已通过" :value="1" />
              <el-option label="已拒绝" :value="2" />
              <el-option label="退款中" :value="3" />
              <el-option label="退款成功" :value="4" />
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
          <el-table-column label="商品图" width="80" align="center">
            <template #default="{ row }">
              <el-image
                v-if="refundProductImage(row)"
                :src="refundProductImage(row)"
                fit="cover"
                class="refund-list-product-img"
                :preview-src-list="[refundProductImage(row)]"
              />
              <div v-else class="refund-list-img-placeholder">
                <el-icon :size="20"><Picture /></el-icon>
              </div>
            </template>
          </el-table-column>
          <el-table-column prop="refundNo" label="退款单号" width="160" show-overflow-tooltip />
          <el-table-column prop="orderNo" label="订单号" width="160" show-overflow-tooltip />
          <el-table-column label="订单明细" width="100" align="center">
            <template #default="{ row }">{{ row.orderItemId != null ? '商品退款' : '-' }}</template>
          </el-table-column>
          <el-table-column prop="userId" label="用户ID" width="90" />
          <el-table-column prop="refundAmount" label="退款金额" width="100" align="right">
            <template #default="{ row }">{{ row.refundAmount ?? '-' }}</template>
          </el-table-column>
          <el-table-column prop="refundStatus" label="退款状态" width="90" align="center">
            <template #default="{ row }">{{ refundStatusText(row.refundStatus) }}</template>
          </el-table-column>
          <el-table-column prop="refundReason" label="退款原因" min-width="120" show-overflow-tooltip />
          <el-table-column prop="applyTime" label="申请时间" width="170" />
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
import { Picture } from '@element-plus/icons-vue'
import { useUserStore } from '@/store/user'
import { refundApi } from '@/api/refund'
import { sellerApi } from '@/api/seller'

const userStore = useUserStore()
const currentZid = computed(() => userStore.currentZid())

const loading = ref(false)
const list = ref([])
const shopOptions = ref([])
const shopOptionsLoading = ref(false)

const filterForm = ref({
  refundNo: '',
  orderNo: '',
  orderId: null,
  userId: null,
  sid: null,
  paymentId: null,
  refundStatus: null
})
const pagination = reactive({
  pageNum: 1,
  pageSize: 10,
  total: 0
})

const refundStatusMap = { 0: '待审核', 1: '已通过', 2: '已拒绝', 3: '退款中', 4: '退款成功' }
function refundStatusText(v) {
  return v != null ? (refundStatusMap[v] ?? String(v)) : '-'
}

function refundProductImage(row) {
  const url = row?.productImageUrl ?? row?.product_image_url ?? ''
  return url || ''
}

function buildParams() {
  const p = {
    pageNum: pagination.pageNum,
    pageSize: pagination.pageSize
  }
  const zid = currentZid.value
  if (zid != null && zid !== '') p.zid = zid
  if (filterForm.value.refundNo) p.refundNo = filterForm.value.refundNo
  if (filterForm.value.orderNo) p.orderNo = filterForm.value.orderNo
  if (filterForm.value.orderId != null && filterForm.value.orderId !== '') p.orderId = filterForm.value.orderId
  if (filterForm.value.userId != null && filterForm.value.userId !== '') p.userId = filterForm.value.userId
  if (filterForm.value.sid != null && filterForm.value.sid !== '') p.sid = filterForm.value.sid
  if (filterForm.value.paymentId != null && filterForm.value.paymentId !== '') p.paymentId = filterForm.value.paymentId
  if (filterForm.value.refundStatus !== null && filterForm.value.refundStatus !== '') p.refundStatus = filterForm.value.refundStatus
  return p
}

async function fetchList() {
  loading.value = true
  try {
    const res = await refundApi.queryRefundApplications(buildParams())
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
    refundNo: '',
    orderNo: '',
    orderId: null,
    userId: null,
    sid: null,
    paymentId: null,
    refundStatus: null
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
.refund-list-page { padding: 20px; }
.card-header { font-size: 18px; font-weight: bold; }
.filter-section { margin-bottom: 16px; }
.filter-form { margin: 0; }
.table-section { margin-top: 12px; }
.pagination-section { margin-top: 16px; display: flex; justify-content: flex-end; }

.refund-list-product-img {
  width: 48px;
  height: 48px;
  border-radius: 6px;
  display: block;
  object-fit: cover;
}
.refund-list-img-placeholder {
  width: 48px;
  height: 48px;
  border-radius: 6px;
  background: var(--el-fill-color-light);
  color: var(--el-text-color-placeholder);
  display: inline-flex;
  align-items: center;
  justify-content: center;
}
</style>
