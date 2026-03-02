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
            <el-select v-model="filterForm.purchaseStatus" placeholder="全部" clearable style="width: 110px">
              <el-option label="待审核" :value="0" />
              <el-option label="已审核" :value="1" />
              <el-option label="采购中" :value="2" />
              <el-option label="部分到货" :value="3" />
              <el-option label="已完成" :value="4" />
              <el-option label="已取消" :value="5" />
            </el-select>
          </el-form-item>
          <el-form-item>
            <el-button type="primary" :loading="loading" @click="handleSearch">查询</el-button>
            <el-button @click="handleReset">重置</el-button>
          </el-form-item>
        </el-form>
      </div>

      <!-- 表格：最后一列不设固定宽度，自动填充右侧空白 -->
      <div class="table-section table-wrapper">
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
                v-if="row.firstItemImageUrl"
                :src="row.firstItemImageUrl"
                fit="cover"
                class="purchase-list-product-img"
                :preview-src-list="[row.firstItemImageUrl]"
              />
              <div v-else class="purchase-list-img-placeholder">
                <el-icon :size="20"><Picture /></el-icon>
              </div>
            </template>
          </el-table-column>
          <el-table-column prop="purchaseNo" label="采购单号" min-width="160" show-overflow-tooltip />
          <el-table-column prop="supplierName" label="供应商" min-width="120" show-overflow-tooltip />
          <el-table-column prop="totalAmount" label="总金额" width="100" align="right">
            <template #default="{ row }">{{ row.totalAmount ?? '-' }}</template>
          </el-table-column>
          <el-table-column prop="purchaseStatus" label="采购状态" width="90" align="center">
            <template #default="{ row }">{{ purchaseStatusText(row.purchaseStatus) }}</template>
          </el-table-column>
          <el-table-column prop="purchaserName" label="采购员" width="100" />
          <el-table-column prop="expectedArrivalTime" label="预计到货" min-width="170" />
          <el-table-column prop="createTime" label="创建时间" min-width="170" />
          <el-table-column label="操作" width="90" fixed="right">
            <template #default="{ row }">
              <el-button type="primary" link @click="openDetail(row.id)">详情</el-button>
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
          @size-change="handleSizeChange"
          @current-change="fetchList"
        />
      </div>
    </el-card>

    <!-- 采购单详情抽屉 -->
    <el-drawer
      v-model="detailVisible"
      title="采购单详情"
      size="560px"
      direction="rtl"
      @closed="detailVisible = false"
    >
      <div v-loading="detailLoading" class="detail-body">
        <template v-if="detail.order">
          <el-steps :active="detailStepActive" finish-status="success" align-center class="detail-steps">
            <el-step title="补货审核" />
            <el-step title="审核通过" />
            <el-step title="采购中" />
            <el-step title="发货" />
            <el-step title="已完成" />
          </el-steps>
          <div class="detail-info">
            <p><span class="label">采购单号：</span>{{ detail.order.purchaseNo }}</p>
            <p><span class="label">供应商：</span>{{ detail.order.supplierName ?? '-' }}</p>
            <p><span class="label">总金额：</span>{{ detail.order.totalAmount ?? '-' }}</p>
            <p><span class="label">状态：</span>{{ purchaseStatusText(detail.order.purchaseStatus) }}</p>
            <p><span class="label">预计到货：</span>{{ detail.order.expectedArrivalTime ?? '-' }}</p>
            <p><span class="label">创建时间：</span>{{ detail.order.createTime ?? '-' }}</p>
            <p v-if="detail.order.approveTime"><span class="label">审核时间：</span>{{ detail.order.approveTime }}</p>
          </div>
          <div class="detail-items">
            <div class="sub-title">采购商品</div>
            <el-table :data="detail.items || []" border size="small" max-height="280">
              <el-table-column label="商品图" width="64" align="center">
                <template #default="{ row }">
                  <el-image
                    v-if="row.productImageUrl"
                    :src="row.productImageUrl"
                    fit="cover"
                    class="purchase-detail-item-img"
                    :preview-src-list="[row.productImageUrl]"
                  />
                  <div v-else class="purchase-detail-img-placeholder">
                    <el-icon :size="16"><Picture /></el-icon>
                  </div>
                </template>
              </el-table-column>
              <el-table-column prop="productName" label="商品名称" min-width="140" show-overflow-tooltip />
              <el-table-column prop="skuCode" label="SKU" width="100" />
              <el-table-column prop="purchasePrice" label="单价" width="90" align="right" />
              <el-table-column prop="purchaseQuantity" label="数量" width="70" align="right" />
              <el-table-column prop="totalPrice" label="小计" width="90" align="right" />
              <el-table-column prop="arrivalQuantity" label="到货数" width="70" align="right" />
            </el-table>
          </div>
          <div v-if="detail.order.purchaseStatus === 0" class="detail-actions">
            <el-button type="primary" :loading="approving" @click="approveOrder">审核通过</el-button>
          </div>
        </template>
      </div>
    </el-drawer>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, computed } from 'vue'
import { Picture } from '@element-plus/icons-vue'
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
const detailVisible = ref(false)
const detailLoading = ref(false)
const approving = ref(false)
const detail = ref({ order: null, items: [] })

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

// 与建表一致：0-待审核，1-已审核，2-采购中，3-部分到货，4-已完成，5-已取消
const purchaseStatusMap = { 0: '待审核', 1: '已审核', 2: '采购中', 3: '部分到货', 4: '已完成', 5: '已取消' }
function purchaseStatusText(v) {
  return v != null ? (purchaseStatusMap[v] ?? String(v)) : '-'
}

// 步骤条：0→第1步，1→第2步，…；已取消(5)不展示在步骤条，按 0 处理
const detailStepActive = computed(() => {
  const status = detail.value.order?.purchaseStatus
  if (status == null || status === 5) return 0
  if (status >= 0 && status <= 4) return status + 1
  return 0
})

async function openDetail(id) {
  detail.value = { order: null, items: [] }
  detailVisible.value = true
  detailLoading.value = true
  try {
    const res = await purchaseApi.getPurchaseOrderDetail(id)
    const data = res?.data ?? res
    detail.value = {
      order: data.order ?? data,
      items: data.items ?? []
    }
  } catch (e) {
    ElMessage.error(e.message || '加载详情失败')
    detail.value = { order: null, items: [] }
  } finally {
    detailLoading.value = false
  }
}

async function approveOrder() {
  const id = detail.value.order?.id
  if (!id) return
  approving.value = true
  try {
    await purchaseApi.approvePurchaseOrder(id)
    ElMessage.success('已审核通过')
    await openDetail(id)
  } catch (e) {
    ElMessage.error(e.message || '审核失败')
  } finally {
    approving.value = false
  }
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
.table-wrapper { width: 100%; }
.table-wrapper :deep(.el-table) { width: 100% !important; }
.pagination-section { margin-top: 16px; display: flex; justify-content: flex-end; }

.detail-body { padding: 0 8px; }
.detail-steps { margin-bottom: 20px; }
.detail-info { margin-bottom: 16px; font-size: 14px; }
.detail-info .label { color: #606266; margin-right: 8px; }
.detail-info p { margin: 6px 0; }
.sub-title { font-weight: bold; margin-bottom: 8px; }
.detail-items { margin-bottom: 16px; }
.detail-actions { margin-top: 16px; }

.purchase-list-product-img { width: 48px; height: 48px; border-radius: 4px; object-fit: cover; }
.purchase-list-img-placeholder { width: 48px; height: 48px; border-radius: 4px; background: var(--el-fill-color-light); display: flex; align-items: center; justify-content: center; color: var(--el-text-color-placeholder); }
.purchase-detail-item-img { width: 40px; height: 40px; border-radius: 4px; object-fit: cover; }
.purchase-detail-img-placeholder { width: 40px; height: 40px; border-radius: 4px; background: var(--el-fill-color-light); display: flex; align-items: center; justify-content: center; color: var(--el-text-color-placeholder); }
</style>
