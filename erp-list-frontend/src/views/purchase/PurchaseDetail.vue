<template>
  <div class="page purchase-detail-page">
    <el-card v-loading="loading">
      <template #header>
        <div class="card-header">
          <el-button link type="primary" @click="goBack">
            <el-icon><ArrowLeft /></el-icon> 返回列表
          </el-button>
          <span class="title">采购单详情</span>
        </div>
      </template>
      <template v-if="detail.order">
        <el-descriptions :column="2" border>
          <el-descriptions-item label="采购单号">{{ detail.order.purchaseNo }}</el-descriptions-item>
          <el-descriptions-item label="采购状态">{{ purchaseStatusText(detail.order.purchaseStatus) }}</el-descriptions-item>
          <el-descriptions-item label="供应商">{{ detail.order.supplierName ?? '-' }}</el-descriptions-item>
          <el-descriptions-item label="总金额">{{ detail.order.totalAmount ?? '-' }}</el-descriptions-item>
          <el-descriptions-item label="预计到货">{{ detail.order.expectedArrivalTime ?? '-' }}</el-descriptions-item>
          <el-descriptions-item label="创建时间">{{ detail.order.createTime }}</el-descriptions-item>
        </el-descriptions>
        <div class="sub-title">采购明细</div>
        <el-table :data="detail.items || []" border size="small">
          <el-table-column prop="productName" label="商品名称" min-width="140" show-overflow-tooltip />
          <el-table-column prop="skuCode" label="SKU" width="100" />
          <el-table-column prop="purchasePrice" label="单价" width="100" align="right" />
          <el-table-column prop="purchaseQuantity" label="数量" width="80" align="right" />
          <el-table-column prop="totalPrice" label="小计" width="100" align="right" />
          <el-table-column prop="arrivalQuantity" label="到货数" width="80" align="right" />
        </el-table>
        <div v-if="(detail.statusLogs || []).length > 0" class="sub-title">状态时间线</div>
        <el-timeline v-if="(detail.statusLogs || []).length > 0">
          <el-timeline-item
            v-for="log in detail.statusLogs"
            :key="log.id"
            :timestamp="log.createTime"
            placement="top"
          >
            {{ log.remark ?? '状态变更' }}
            <span v-if="log.oldStatus != null"> {{ purchaseStatusText(log.oldStatus) }} → </span>
            <span>{{ purchaseStatusText(log.newStatus) }}</span>
            <span v-if="log.operatorName">（{{ log.operatorName }}）</span>
          </el-timeline-item>
        </el-timeline>
      </template>
      <el-empty v-else-if="!loading" description="未找到采购单" />
    </el-card>
  </div>
</template>

<script setup>
import { ref, onMounted, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ArrowLeft } from '@element-plus/icons-vue'
import { ElMessage } from 'element-plus'
import { purchaseApi } from '@/api/purchase'

const route = useRoute()
const router = useRouter()
const loading = ref(false)
const detail = ref({ order: null, items: [], statusLogs: [] })

const purchaseStatusMap = { 0: '待审核', 1: '已审核', 2: '采购中', 3: '部分到货', 4: '已完成', 5: '已取消' }
function purchaseStatusText(v) { return v != null ? (purchaseStatusMap[v] ?? String(v)) : '-' }

function goBack() {
  router.push('/purchase/list')
}

async function fetchDetail() {
  const id = route.params.id
  if (!id) return
  loading.value = true
  try {
    const res = await purchaseApi.getPurchaseOrderDetail(id)
    const data = res?.data ?? res
    detail.value = {
      order: data.order ?? data,
      items: data.items ?? [],
      statusLogs: data.statusLogs ?? []
    }
  } catch (e) {
    ElMessage.error(e.message || '加载失败')
    detail.value = { order: null, items: [], statusLogs: [] }
  } finally {
    loading.value = false
  }
}

onMounted(fetchDetail)
watch(() => route.params.id, fetchDetail)
</script>

<style scoped>
.purchase-detail-page { padding: 20px; }
.card-header { display: flex; align-items: center; gap: 12px; }
.card-header .title { font-size: 18px; font-weight: bold; }
.sub-title { margin: 20px 0 8px; font-weight: bold; }
</style>
