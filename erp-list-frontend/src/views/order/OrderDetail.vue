<template>
  <div class="page order-detail-page">
    <el-card v-loading="loading">
      <template #header>
        <div class="card-header">
          <el-button link type="primary" @click="goBack">
            <el-icon><ArrowLeft /></el-icon> 返回列表
          </el-button>
          <span class="title">订单详情</span>
        </div>
      </template>
      <template v-if="detail.id">
        <el-descriptions :column="2" border>
          <el-descriptions-item label="订单号">{{ detail.orderNo }}</el-descriptions-item>
          <el-descriptions-item label="订单状态">{{ orderStatusText(detail.orderStatus) }}</el-descriptions-item>
          <el-descriptions-item label="支付状态">{{ payStatusText(detail.payStatus) }}</el-descriptions-item>
          <el-descriptions-item label="总金额">{{ detail.totalAmount ?? '-' }}</el-descriptions-item>
          <el-descriptions-item label="实付金额">{{ detail.payAmount ?? '-' }}</el-descriptions-item>
          <el-descriptions-item label="收货人">{{ detail.receiverName ?? '-' }}</el-descriptions-item>
          <el-descriptions-item label="收货地址" :span="2">{{ detail.receiverAddress ?? '-' }}</el-descriptions-item>
          <el-descriptions-item label="创建时间">{{ detail.createTime }}</el-descriptions-item>
          <el-descriptions-item label="备注">{{ detail.remark ?? '-' }}</el-descriptions-item>
        </el-descriptions>
        <div class="sub-title">订单明细</div>
        <el-table :data="detail.items || []" border size="small">
          <el-table-column label="商品图" width="80" align="center">
            <template #default="{ row }">
              <el-image
                v-if="row.productImage"
                :src="row.productImage"
                fit="cover"
                class="order-detail-item-img"
                :preview-src-list="[row.productImage]"
              />
              <div v-else class="order-detail-img-placeholder">
                <el-icon :size="24"><Picture /></el-icon>
              </div>
            </template>
          </el-table-column>
          <el-table-column prop="productName" label="商品名称" min-width="140" show-overflow-tooltip />
          <el-table-column prop="skuCode" label="SKU" width="100" />
          <el-table-column prop="price" label="单价" width="100" align="right" />
          <el-table-column prop="quantity" label="数量" width="80" align="right" />
          <el-table-column prop="totalPrice" label="小计" width="100" align="right" />
          <el-table-column label="操作" width="110" align="center" fixed="right">
            <template #default="{ row }">
              <el-button
                type="primary"
                link
                size="small"
                :disabled="isItemRefunded(row.id)"
                @click="goRefundCreate(row)"
              >
                申请退款
              </el-button>
              <span v-if="isItemRefunded(row.id)" class="item-refunded-tip">已退款</span>
            </template>
          </el-table-column>
        </el-table>
        <div class="sub-title">关联退款申请</div>
        <div class="refund-section">
          <el-table :data="refundList" border size="small" class="refund-table">
            <el-table-column label="商品图" width="80" align="center">
              <template #default="{ row }">
                <el-image
                  v-if="refundItemImages[row.orderItemId]"
                  :src="refundItemImages[row.orderItemId]"
                  fit="cover"
                  class="refund-item-img"
                  :preview-src-list="[refundItemImages[row.orderItemId]]"
                />
                <div v-else class="refund-item-img-placeholder">
                  <el-icon :size="22"><Picture /></el-icon>
                </div>
              </template>
            </el-table-column>
            <el-table-column prop="refundNo" label="退款单号" width="160" show-overflow-tooltip />
            <el-table-column prop="refundAmount" label="退款金额" width="100" align="right" />
            <el-table-column prop="refundStatus" label="状态" width="100" align="center">
              <template #default="{ row }">{{ refundStatusText(row.refundStatus) }}</template>
            </el-table-column>
            <el-table-column prop="refundReason" label="退款原因" min-width="120" show-overflow-tooltip />
            <el-table-column prop="applyTime" label="申请时间" width="170" />
            <el-table-column label="操作" width="90">
              <template #default="{ row }">
                <el-button type="primary" link size="small" @click="$router.push('/refund/detail/' + row.id)">详情</el-button>
              </template>
            </el-table-column>
          </el-table>
          <el-empty v-if="refundList.length === 0 && !refundLoading" description="暂无退款申请" :image-size="60" />
        </div>
      </template>
      <el-empty v-else-if="!loading" description="未找到订单" />
    </el-card>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ArrowLeft, Picture } from '@element-plus/icons-vue'
import { ElMessage } from 'element-plus'
import { orderApi } from '@/api/order'
import { refundApi } from '@/api/refund'

const route = useRoute()
const router = useRouter()
const loading = ref(false)
const refundLoading = ref(false)
const detail = ref({})
const refundList = ref([])
/** orderItemId -> productImage，供关联退款表格展示商品图 */
const refundItemImages = ref({})

const orderStatusMap = { 0: '待支付', 1: '已支付', 2: '已发货', 3: '已完成', 4: '已取消' }
const payStatusMap = { 0: '未支付', 1: '已支付' }
const refundStatusMap = { 0: '待审核', 1: '审核通过', 2: '审核拒绝', 3: '退款中', 4: '退款成功', 5: '退款失败' }
function orderStatusText(v) { return v != null ? (orderStatusMap[v] ?? String(v)) : '-' }
function payStatusText(v) { return v != null ? (payStatusMap[v] ?? String(v)) : '-' }
function refundStatusText(v) { return v != null ? (refundStatusMap[v] ?? String(v)) : '-' }

/** 该订单项是否已退款成功（存在针对该 orderItemId 且状态为退款成功的记录则不可再申请） */
function isItemRefunded(orderItemId) {
  if (orderItemId == null) return false
  return refundList.value.some(
    r => r.orderItemId === orderItemId && r.refundStatus === 4
  )
}

function goBack() {
  router.push('/order/list')
}

async function fetchDetail() {
  const id = route.params.id
  if (!id) return
  loading.value = true
  try {
    const res = await orderApi.getOrderById(id)
    detail.value = res?.data ?? res ?? {}
    if (detail.value.id) await fetchRefundList()
  } catch (e) {
    ElMessage.error(e.message || '加载失败')
    detail.value = {}
  } finally {
    loading.value = false
  }
}

async function fetchRefundList() {
  const orderId = detail.value.id
  if (!orderId) return
  refundLoading.value = true
  refundItemImages.value = {}
  try {
    const res = await refundApi.queryRefundApplications({ orderId, pageNum: 1, pageSize: 50 })
    const data = res?.data ?? res
    refundList.value = data?.records ?? data?.list ?? []
    const orderItemIds = [...new Set(refundList.value.map(r => r.orderItemId).filter(id => id != null))]
    if (orderItemIds.length) {
      const imgRes = await orderApi.getOrderItemProductImages(orderItemIds)
      const list = imgRes?.data ?? imgRes ?? []
      const map = {}
      ;(Array.isArray(list) ? list : []).forEach(item => {
        const id = item.orderItemId ?? item.id
        if (id != null && item.productImage) map[id] = item.productImage
      })
      refundItemImages.value = map
    }
  } catch {
    refundList.value = []
  } finally {
    refundLoading.value = false
  }
}

function goRefundCreate(item) {
  const query = { orderId: detail.value.id, orderNo: detail.value.orderNo }
  if (item && item.id) query.orderItemId = item.id
  router.push({ path: '/refund/list', query })
}

onMounted(fetchDetail)
watch(() => route.params.id, fetchDetail)
</script>

<style scoped>
.order-detail-page { padding: 20px; }
.card-header { display: flex; align-items: center; gap: 12px; }
.card-header .title { font-size: 18px; font-weight: bold; }
.sub-title { margin: 20px 0 8px; font-weight: bold; }
.refund-section { margin-top: 16px; }
.refund-section .el-button { margin-bottom: 8px; }
.item-refunded-tip { margin-left: 4px; color: var(--el-text-color-secondary); font-size: 12px; }
.refund-table { margin-top: 8px; }
.order-detail-item-img { width: 56px; height: 56px; border-radius: 4px; display: block; }
.order-detail-img-placeholder { width: 56px; height: 56px; background: var(--el-fill-color-light); border-radius: 4px; display: flex; align-items: center; justify-content: center; color: var(--el-text-color-placeholder); }
.refund-item-img { width: 52px; height: 52px; border-radius: 4px; display: block; }
.refund-item-img-placeholder { width: 52px; height: 52px; background: var(--el-fill-color-light); border-radius: 4px; display: flex; align-items: center; justify-content: center; color: var(--el-text-color-placeholder); }
</style>
