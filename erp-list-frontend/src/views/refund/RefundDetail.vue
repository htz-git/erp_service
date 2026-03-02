<template>
  <div class="page refund-detail-page">
    <el-card v-loading="loading">
      <template #header>
        <div class="card-header">
          <el-button link type="primary" @click="goBack">
            <el-icon><ArrowLeft /></el-icon> 返回列表
          </el-button>
          <span class="title">退款详情</span>
        </div>
      </template>
      <template v-if="detail.id">
        <el-descriptions :column="2" border>
          <el-descriptions-item label="退款单号">{{ detail.refundNo }}</el-descriptions-item>
          <el-descriptions-item label="退款状态">{{ refundStatusText(detail.refundStatus) }}</el-descriptions-item>
          <el-descriptions-item label="关联订单号">{{ detail.orderNo ?? '-' }}</el-descriptions-item>
          <el-descriptions-item label="退款金额">{{ detail.refundAmount ?? '-' }}</el-descriptions-item>
          <el-descriptions-item label="退款原因">{{ detail.refundReason ?? detail.refund_reason ?? '-' }}</el-descriptions-item>
          <el-descriptions-item label="申请时间">{{ detail.applyTime ?? detail.createTime }}</el-descriptions-item>
          <el-descriptions-item v-if="detail.orderItemId != null" label="退款商品">
            <div class="refund-product-block">
              <el-image
                v-if="refundProductImage"
                :src="refundProductImage"
                fit="cover"
                class="refund-product-img"
                :preview-src-list="[refundProductImage]"
              />
              <div v-else class="refund-product-placeholder">
                <el-icon :size="32"><Picture /></el-icon>
                <span>商品图</span>
              </div>
            </div>
          </el-descriptions-item>
          <el-descriptions-item label="备注" :span="2">{{ detail.remark ?? '-' }}</el-descriptions-item>
        </el-descriptions>
      </template>
      <el-empty v-else-if="!loading" description="未找到退款记录" />
    </el-card>
  </div>
</template>

<script setup>
import { ref, onMounted, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ArrowLeft, Picture } from '@element-plus/icons-vue'
import { ElMessage } from 'element-plus'
import { refundApi } from '@/api/refund'
import { orderApi } from '@/api/order'

const route = useRoute()
const router = useRouter()
const loading = ref(false)
const detail = ref({})
const refundProductImage = ref('')

const refundStatusMap = { 0: '待审核', 1: '审核通过', 2: '审核拒绝', 3: '退款中', 4: '退款成功', 5: '退款失败' }
function refundStatusText(v) { return v != null ? (refundStatusMap[v] ?? String(v)) : '-' }

function goBack() {
  router.push('/refund/list')
}

async function fetchDetail() {
  const id = route.params.id
  if (!id) return
  loading.value = true
  refundProductImage.value = ''
  try {
    const res = await refundApi.getRefundApplicationById(id)
    detail.value = res?.data ?? res ?? {}
    const orderItemId = detail.value.orderItemId
    if (orderItemId != null) {
      try {
        const imgRes = await orderApi.getOrderItemProductImages([orderItemId])
        const list = imgRes?.data ?? imgRes ?? []
        const item = Array.isArray(list) ? list.find(i => i.orderItemId === orderItemId) : null
        refundProductImage.value = item?.productImage ?? (list[0]?.productImage) ?? ''
      } catch {
        refundProductImage.value = ''
      }
    }
  } catch (e) {
    ElMessage.error(e.message || '加载失败')
    detail.value = {}
  } finally {
    loading.value = false
  }
}

onMounted(fetchDetail)
watch(() => route.params.id, fetchDetail)
</script>

<style scoped>
.refund-detail-page { padding: 20px; }
.card-header { display: flex; align-items: center; gap: 12px; }
.card-header .title { font-size: 18px; font-weight: bold; }
.refund-product-block { display: flex; align-items: center; }
.refund-product-img { width: 72px; height: 72px; border-radius: 6px; display: block; object-fit: cover; }
.refund-product-placeholder { width: 72px; height: 72px; background: var(--el-fill-color-light); border-radius: 6px; display: flex; flex-direction: column; align-items: center; justify-content: center; color: var(--el-text-color-placeholder); font-size: 12px; }
.refund-product-placeholder .el-icon { margin-bottom: 4px; }
</style>
