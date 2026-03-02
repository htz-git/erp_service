<template>
  <div class="page replenishment-detail-page">
    <el-card v-loading="loading">
      <template #header>
        <div class="card-header">
          <el-button link type="primary" @click="goBack">
            <el-icon><ArrowLeft /></el-icon> 返回列表
          </el-button>
          <span class="title">补货单详情</span>
        </div>
      </template>
      <template v-if="detail.id">
        <el-descriptions :column="2" border>
          <el-descriptions-item label="补货单号">{{ detail.replenishmentNo }}</el-descriptions-item>
          <el-descriptions-item label="创建时间">{{ detail.createTime }}</el-descriptions-item>
        </el-descriptions>
        <div class="sub-title">补货明细</div>
        <el-table :data="items" border size="small">
          <el-table-column prop="productName" label="商品名称" min-width="140" show-overflow-tooltip />
          <el-table-column prop="skuCode" label="SKU" width="100" />
          <el-table-column prop="replenishmentQuantity" label="补货数量" width="100" align="right" />
          <el-table-column prop="arrivalQuantity" label="到货数量" width="100" align="right" />
          <el-table-column prop="totalPrice" label="小计" width="100" align="right" />
        </el-table>
      </template>
      <el-empty v-else-if="!loading" description="未找到补货单" />
    </el-card>
  </div>
</template>

<script setup>
import { ref, onMounted, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ArrowLeft } from '@element-plus/icons-vue'
import { ElMessage } from 'element-plus'
import { getReplenishmentById, getReplenishmentItems } from '@/api/replenishment'

const route = useRoute()
const router = useRouter()
const loading = ref(false)
const detail = ref({})
const items = ref([])

function goBack() {
  router.push('/replenishment/list')
}

async function fetchDetail() {
  const id = route.params.id
  if (!id) return
  loading.value = true
  try {
    const [resOrder, resItems] = await Promise.all([
      getReplenishmentById(id),
      getReplenishmentItems(id)
    ])
    detail.value = resOrder?.data ?? resOrder ?? {}
    items.value = resItems?.data ?? resItems ?? []
  } catch (e) {
    ElMessage.error(e.message || '加载失败')
    detail.value = {}
    items.value = []
  } finally {
    loading.value = false
  }
}

onMounted(fetchDetail)
watch(() => route.params.id, fetchDetail)
</script>

<style scoped>
.replenishment-detail-page { padding: 20px; }
.card-header { display: flex; align-items: center; gap: 12px; }
.card-header .title { font-size: 18px; font-weight: bold; }
.sub-title { margin: 20px 0 8px; font-weight: bold; }
</style>
