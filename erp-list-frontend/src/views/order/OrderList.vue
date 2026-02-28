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
          <el-form-item label="国家">
            <el-select
              v-model="filterForm.countryCodes"
              placeholder="请选择国家（可多选）"
              clearable
              multiple
              collapse-tags
              collapse-tags-tooltip
              style="width: 200px"
            >
              <el-option
                v-for="item in countryOptions"
                :key="item.code"
                :label="item.label"
                :value="item.code"
              />
            </el-select>
          </el-form-item>
          <el-form-item label="创建时间">
            <el-date-picker
              v-model="filterForm.createTimeRange"
              type="daterange"
              range-separator="至"
              start-placeholder="开始日期"
              end-placeholder="结束日期"
              value-format="YYYY-MM-DD"
              clearable
              style="width: 240px"
            />
          </el-form-item>
          <el-form-item>
            <el-button type="primary" :loading="loading" @click="handleSearch">查询</el-button>
            <el-button @click="handleReset">重置</el-button>
          </el-form-item>
        </el-form>
      </div>

      <!-- 表格 -->
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
                v-if="firstItemImage(row)"
                :src="firstItemImage(row)"
                fit="cover"
                class="order-list-product-img"
                :preview-src-list="[firstItemImage(row)]"
              />
              <div v-else class="order-list-img-placeholder">
                <el-icon :size="20"><Picture /></el-icon>
              </div>
            </template>
          </el-table-column>
          <el-table-column prop="orderNo" label="订单号" min-width="160" show-overflow-tooltip />
          <el-table-column label="店铺" min-width="100">
            <template #default="{ row }">{{ storeNameBySid(row.sid) }}</template>
          </el-table-column>
          <el-table-column prop="countryCode" label="国家" width="80" />
          <el-table-column prop="totalAmount" label="总金额" width="100" align="right">
            <template #default="{ row }">{{ row.totalAmount ?? '-' }}</template>
          </el-table-column>
          <el-table-column prop="payAmount" label="实付" width="100" align="right">
            <template #default="{ row }">{{ row.payAmount ?? '-' }}</template>
          </el-table-column>
          <el-table-column prop="promotionDiscountAmount" label="促销折扣金额" min-width="120" align="right">
            <template #default="{ row }">{{ row.promotionDiscountAmount ?? '-' }}</template>
          </el-table-column>
          <el-table-column prop="taxAmount" label="税费" width="100" align="right">
            <template #default="{ row }">{{ row.taxAmount ?? '-' }}</template>
          </el-table-column>
          <el-table-column prop="orderStatus" label="订单状态" width="90" align="center">
            <template #default="{ row }">
              <span>{{ orderStatusText(row.orderStatus) }}</span>
              <el-tag v-if="row.hasRefund" type="warning" size="small" class="refund-tag">退款</el-tag>
            </template>
          </el-table-column>
          <el-table-column prop="payStatus" label="支付状态" width="90" align="center">
            <template #default="{ row }">{{ payStatusText(row.payStatus) }}</template>
          </el-table-column>
          <el-table-column prop="receiverName" label="收货人" min-width="100" />
          <el-table-column prop="createTime" label="创建时间" min-width="170" />
          <el-table-column label="操作" width="80" fixed="right">
            <template #default="{ row }">
              <el-button type="primary" link @click="openDetail(row.id)">详情</el-button>
            </template>
          </el-table-column>
        </el-table>
      </div>

      <!-- 订单详情抽屉（参考居中卡片分块格式） -->
      <el-drawer
        v-model="detailVisible"
        title="订单详情"
        size="720"
        destroy-on-close
        direction="rtl"
      >
        <div v-loading="detailLoading" class="order-detail-wrap">
          <template v-if="orderDetail">
            <!-- 顶部：订单号 + 状态标签 + 备注 -->
            <el-card class="detail-card detail-card-header" shadow="never">
              <div class="detail-order-no">{{ orderDetail.orderNo }}</div>
              <div class="detail-tags">
                <el-tag size="small" type="info">{{ orderStatusText(orderDetail.orderStatus) }}</el-tag>
                <el-tag size="small" type="info">{{ payStatusText(orderDetail.payStatus) }}</el-tag>
              </div>
              <div v-if="orderDetail.remark" class="detail-remark">
                <span class="detail-remark-label">备注：</span>{{ orderDetail.remark }}
              </div>
            </el-card>

            <!-- 中部：基本信息 | 收货地址 两列 -->
            <el-card class="detail-card" shadow="never">
              <div class="detail-two-cols">
                <div class="detail-col">
                  <div class="detail-col-title">基本信息</div>
                  <dl class="detail-dl">
                    <dt>店铺</dt>
                    <dd>店铺 ID: {{ orderDetail.sid ?? '-' }}</dd>
                    <dt>国家/地区</dt>
                    <dd>{{ countryLabel(orderDetail.countryCode) }}</dd>
                    <dt>创建时间</dt>
                    <dd>{{ orderDetail.createTime ?? '-' }}</dd>
                  </dl>
                </div>
                <div class="detail-col">
                  <div class="detail-col-title">收货地址</div>
                  <dl class="detail-dl">
                    <dt>收件人</dt>
                    <dd>{{ orderDetail.receiverName ?? '-' }}</dd>
                    <dt>电话</dt>
                    <dd>{{ orderDetail.receiverPhone ?? '-' }}</dd>
                    <dt>地址</dt>
                    <dd>{{ orderDetail.receiverAddress ?? '-' }}</dd>
                  </dl>
                </div>
              </div>
            </el-card>

            <!-- 商品信息：表格（图+名称+ID/SKU | 品名/SKU | 单价 | 数量 | 小计） -->
            <el-card class="detail-card" shadow="never">
              <div class="detail-col-title">商品信息</div>
              <el-table :data="orderDetail.items ?? []" border size="small" class="detail-product-table">
                <el-table-column label="商品信息" min-width="220">
                  <template #default="{ row }">
                    <div class="product-cell">
                      <div class="product-cell-img">
                        <el-image
                          v-if="itemProductImage(row)"
                          :src="itemProductImage(row)"
                          fit="cover"
                          class="product-img"
                          :preview-src-list="[itemProductImage(row)]"
                        />
                        <div v-else class="product-img-placeholder">
                          <el-icon :size="24"><Picture /></el-icon>
                        </div>
                      </div>
                      <div class="product-cell-info">
                        <div class="product-cell-name">{{ row.productName || '-' }}</div>
                        <div class="product-cell-meta" v-if="row.productId">商品ID: {{ row.productId }}</div>
                        <div class="product-cell-meta" v-if="row.companyProductId">公司商品ID: {{ row.companyProductId }}</div>
                      </div>
                    </div>
                  </template>
                </el-table-column>
                <el-table-column prop="skuCode" label="品名/SKU" width="120" show-overflow-tooltip />
                <el-table-column label="单价" width="100" align="right">
                  <template #default="{ row }">¥ {{ row.price ?? '-' }}</template>
                </el-table-column>
                <el-table-column label="数量" width="80" align="center">
                  <template #default="{ row }">×{{ row.quantity ?? 0 }}</template>
                </el-table-column>
                <el-table-column label="小计" width="100" align="right">
                  <template #default="{ row }">¥ {{ row.totalPrice ?? '-' }}</template>
                </el-table-column>
                <el-table-column label="操作" width="100" align="center" fixed="right">
                  <template #default="{ row }">
                    <el-button
                      type="primary"
                      link
                      :disabled="itemHasRefund(row.id) || orderDetail.payStatus !== 1"
                      @click="openRefundDialog(row)"
                    >
                      申请退款
                    </el-button>
                  </template>
                </el-table-column>
              </el-table>
            </el-card>

            <!-- 底部：订单总金额 -->
            <div class="detail-footer">
              订单总金额：<span class="detail-footer-amount">¥ {{ orderDetail.payAmount ?? orderDetail.totalAmount ?? '-' }}</span>
            </div>
          </template>
        </div>
      </el-drawer>

      <!-- 申请退款弹窗 -->
      <el-dialog
        v-model="refundDialogVisible"
        title="申请退款"
        width="440px"
        destroy-on-close
        @close="refundDialogItem = null"
      >
        <template v-if="refundDialogItem && orderDetail">
          <div class="refund-dialog-info">
            <p><span class="label">订单号：</span>{{ orderDetail.orderNo }}</p>
            <p><span class="label">商品：</span>{{ refundDialogItem.productName || '-' }}</p>
            <p><span class="label">SKU：</span>{{ refundDialogItem.skuCode || '-' }}</p>
            <p><span class="label">退款金额：</span>¥ {{ refundDialogItem.totalPrice ?? '-' }}</p>
          </div>
          <el-form ref="refundFormRef" :model="refundForm" label-width="80px">
            <el-form-item label="退款原因">
              <el-select v-model="refundForm.refundReasonId" placeholder="请选择" clearable style="width: 100%">
                <el-option
                  v-for="r in refundReasonOptions"
                  :key="r.id"
                  :label="r.reasonName"
                  :value="r.id"
                />
              </el-select>
            </el-form-item>
            <el-form-item label="备注">
              <el-input v-model="refundForm.remark" type="textarea" :rows="2" placeholder="选填" />
            </el-form-item>
          </el-form>
        </template>
        <template #footer>
          <el-button @click="refundDialogVisible = false">取消</el-button>
          <el-button type="primary" :loading="refundSubmitLoading" @click="submitRefund">确认</el-button>
        </template>
      </el-dialog>

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
import { Picture } from '@element-plus/icons-vue'
import { orderApi } from '@/api/order'
import { sellerApi } from '@/api/seller'
import { refundApi } from '@/api/refund'

const userStore = useUserStore()
const currentZid = computed(() => userStore.currentZid())

const loading = ref(false)
const list = ref([])
const shopOptions = ref([])
const shopOptionsLoading = ref(false)

const filterForm = ref({
  orderNo: '',
  sid: null,
  orderStatus: null,
  payStatus: null,
  countryCodes: [],
  createTimeRange: null
})

const countryOptions = [
  { code: 'US', label: '美国' }, { code: 'DE', label: '德国' }, { code: 'UK', label: '英国' }, { code: 'FR', label: '法国' }, { code: 'IT', label: '意大利' },
  { code: 'ES', label: '西班牙' }, { code: 'JP', label: '日本' }, { code: 'CA', label: '加拿大' }, { code: 'AU', label: '澳大利亚' }, { code: 'IN', label: '印度' },
  { code: 'MX', label: '墨西哥' }, { code: 'BR', label: '巴西' }, { code: 'NL', label: '荷兰' }, { code: 'PL', label: '波兰' }, { code: 'TR', label: '土耳其' },
  { code: 'CN', label: '中国' }, { code: 'KR', label: '韩国' }, { code: 'SG', label: '新加坡' }, { code: 'AE', label: '阿联酋' }, { code: 'SA', label: '沙特' }
]
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

function countryLabel(code) {
  if (code == null || code === '') return '-'
  const opt = countryOptions.find(c => c.code === code)
  return opt ? `${opt.label} (${code})` : code
}

function itemProductImage(item) {
  return item?.productImage || item?.product_image || ''
}

/** 订单列表行：取首件商品图（后端 OrderListVO.firstItemImageUrl） */
function firstItemImage(row) {
  const url = row?.firstItemImageUrl ?? row?.first_item_image_url ?? ''
  return url || ''
}

/** 根据 sid 显示店铺名称（用 shopOptions） */
function storeNameBySid(sid) {
  if (sid == null || sid === '') return '-'
  const s = (shopOptions.value || []).find(o => o.id === sid)
  return s ? (s.sellerName || s.seller_name || `店铺 ${sid}`) : `店铺 ${sid}`
}

function buildParams() {
  const p = {
    pageNum: pagination.pageNum,
    pageSize: pagination.pageSize
  }
  // 固定使用当前用户 zid，只查当前公司下的订单
  const zid = currentZid.value
  if (zid != null && zid !== '') p.zid = zid
  if (filterForm.value.orderNo) p.orderNo = filterForm.value.orderNo
  if (filterForm.value.sid != null && filterForm.value.sid !== '') p.sid = filterForm.value.sid
  if (filterForm.value.orderStatus !== null && filterForm.value.orderStatus !== '') p.orderStatus = filterForm.value.orderStatus
  if (filterForm.value.payStatus !== null && filterForm.value.payStatus !== '') p.payStatus = filterForm.value.payStatus
  if (filterForm.value.countryCodes && filterForm.value.countryCodes.length) p.countryCodes = filterForm.value.countryCodes
  const range = filterForm.value.createTimeRange
  if (range && Array.isArray(range) && range.length === 2) {
    p.createTimeStart = range[0]
    p.createTimeEnd = range[1]
  }
  return p
}

async function fetchList() {
  loading.value = true
  try {
    const res = await orderApi.queryOrders(buildParams())
    const rows = res.data?.records ?? []
    list.value = rows
    pagination.total = res.data?.total ?? 0
    // 批量查已退款订单，用于列表展示“退款”标签
    const orderIds = (rows || []).map(r => r.id).filter(Boolean)
    if (orderIds.length > 0) {
      try {
        const refRes = await refundApi.getOrderIdsWithRefund(orderIds)
        const refundOrderIds = new Set(refRes.data ?? [])
        rows.forEach(r => { r.hasRefund = refundOrderIds.has(r.id) })
      } catch (_) {
        rows.forEach(r => { r.hasRefund = false })
      }
    }
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
    orderNo: '',
    sid: null,
    orderStatus: null,
    payStatus: null,
    countryCodes: [],
    createTimeRange: null
  }
  pagination.pageNum = 1
  fetchList()
}

const detailVisible = ref(false)
const detailLoading = ref(false)
const orderDetail = ref(null)
const refundsOfCurrentOrder = ref([])
const refundReasonOptions = ref([])
const refundDialogVisible = ref(false)
const refundDialogItem = ref(null)
const refundFormRef = ref(null)
const refundForm = ref({ refundReasonId: null, remark: '' })
const refundSubmitLoading = ref(false)

function itemHasRefund(itemId) {
  if (itemId == null) return false
  return (refundsOfCurrentOrder.value || []).some(r => r.orderItemId === itemId)
}

async function openDetail(id) {
  detailVisible.value = true
  orderDetail.value = null
  refundsOfCurrentOrder.value = []
  detailLoading.value = true
  try {
    const res = await orderApi.getOrderById(id)
    orderDetail.value = res.data ?? null
    if (id != null) {
      const refRes = await refundApi.queryRefundApplications({ orderId: id, pageSize: 100 })
      refundsOfCurrentOrder.value = refRes.data?.records ?? []
    }
  } catch (e) {
    ElMessage.error(e.message || '加载详情失败')
  } finally {
    detailLoading.value = false
  }
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

async function loadRefundReasons() {
  if (refundReasonOptions.value.length) return
  try {
    const res = await refundApi.getRefundReasons()
    refundReasonOptions.value = res.data ?? []
  } catch {
    refundReasonOptions.value = []
  }
}

function openRefundDialog(row) {
  if (!orderDetail.value) return
  refundDialogItem.value = row
  refundForm.value = { refundReasonId: null, remark: '' }
  refundDialogVisible.value = true
  loadRefundReasons()
}

async function submitRefund() {
  const item = refundDialogItem.value
  const order = orderDetail.value
  if (!item || !order) return
  const zid = currentZid.value
  const reasonOpt = refundReasonOptions.value.find(r => r.id === refundForm.value.refundReasonId)
  const payload = {
    orderId: order.id,
    orderNo: order.orderNo,
    orderItemId: item.id,
    refundAmount: item.totalPrice,
    userId: userStore.userId ?? 1,
    paymentId: 0,
    paymentNo: 'PAY-' + order.orderNo,
    zid: zid ?? undefined,
    sid: order.sid ?? undefined,
    refundReasonId: refundForm.value.refundReasonId || undefined,
    refundReason: reasonOpt ? reasonOpt.reasonName : undefined,
    remark: refundForm.value.remark || undefined
  }
  refundSubmitLoading.value = true
  try {
    await refundApi.createRefundApplication(payload)
    ElMessage.success('申请成功')
    refundDialogVisible.value = false
    const refRes = await refundApi.queryRefundApplications({ orderId: order.id, pageSize: 100 })
    refundsOfCurrentOrder.value = refRes.data?.records ?? []
  } catch (e) {
    const msg = e?.response?.data?.message ?? e?.message ?? '申请失败'
    ElMessage.error(msg)
  } finally {
    refundSubmitLoading.value = false
  }
}

onMounted(() => {
  loadShopOptions()
  loadRefundReasons()
  fetchList()
})
</script>

<style scoped>
.order-list-page { padding: 20px; }
.card-header { font-size: 18px; font-weight: bold; }
.filter-section { margin-bottom: 16px; }
.filter-form { margin: 0; }
.table-section { margin-top: 12px; }
.table-wrapper { width: 100%; }
.table-wrapper :deep(.el-table) { width: 100% !important; }
.pagination-section { margin-top: 16px; display: flex; justify-content: flex-end; }

/* 订单列表：商品图、退款标签 */
.order-list-product-img {
  width: 48px;
  height: 48px;
  border-radius: 6px;
  display: block;
  object-fit: cover;
}
.order-list-img-placeholder {
  width: 48px;
  height: 48px;
  border-radius: 6px;
  background: var(--el-fill-color-light);
  color: var(--el-text-color-placeholder);
  display: inline-flex;
  align-items: center;
  justify-content: center;
}
.refund-tag { margin-left: 6px; }

/* 订单详情：居中卡片布局 */
.order-detail-wrap {
  max-width: 640px;
  margin: 0 auto;
  padding: 0 12px 24px;
}
.detail-card {
  margin-bottom: 16px;
}
.detail-card :deep(.el-card__body) {
  padding: 16px;
}
.detail-card-header { padding: 16px; }
.detail-order-no {
  font-size: 16px;
  font-weight: 600;
  color: var(--text-primary, #303133);
  margin-bottom: 8px;
}
.detail-tags { display: flex; gap: 8px; margin-bottom: 8px; }
.detail-remark {
  font-size: 13px;
  color: var(--el-text-color-secondary);
}
.detail-remark-label { color: var(--el-text-color-regular); }
.detail-two-cols {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 24px;
}
@media (max-width: 560px) {
  .detail-two-cols { grid-template-columns: 1fr; }
}
.detail-col-title {
  font-weight: 600;
  font-size: 14px;
  margin-bottom: 10px;
  color: var(--text-primary, #303133);
}
.detail-dl {
  margin: 0;
  font-size: 13px;
}
.detail-dl dt {
  margin: 8px 0 2px;
  color: var(--el-text-color-secondary);
  font-weight: 400;
}
.detail-dl dd {
  margin: 0;
  color: var(--el-text-color-regular);
}
.detail-product-table { margin-top: 8px; }
.product-cell {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 4px 0;
}
.product-cell-img {
  flex-shrink: 0;
  width: 56px;
  height: 56px;
  border-radius: 6px;
  overflow: hidden;
}
.product-img {
  width: 100%;
  height: 100%;
  display: block;
}
.product-img-placeholder {
  width: 100%;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  background: var(--el-fill-color-light);
  color: var(--el-text-color-placeholder);
}
.product-cell-info { min-width: 0; }
.product-cell-name {
  font-size: 13px;
  font-weight: 500;
  color: var(--el-text-color-regular);
  margin-bottom: 4px;
}
.product-cell-meta {
  font-size: 12px;
  color: var(--el-text-color-secondary);
}
.detail-footer {
  text-align: right;
  font-size: 14px;
  padding: 12px 0;
  border-top: 1px solid var(--el-border-color-lighter);
}
.detail-footer-amount {
  font-weight: 600;
  font-size: 16px;
  color: var(--el-color-primary);
}

.refund-dialog-info {
  margin-bottom: 16px;
  font-size: 13px;
}
.refund-dialog-info p { margin: 6px 0; }
.refund-dialog-info .label { color: var(--el-text-color-secondary); margin-right: 4px; }
</style>
