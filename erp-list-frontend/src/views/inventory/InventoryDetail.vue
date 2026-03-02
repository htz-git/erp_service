<template>
  <div class="page inventory-detail-page">
    <el-card v-loading="loading">
      <template #header>
        <div class="card-header">
          <el-button link type="primary" @click="goBack">
            <el-icon><ArrowLeft /></el-icon> 返回列表
          </el-button>
          <span class="title">库存详情</span>
        </div>
      </template>
      <template v-if="detail.id">
        <el-descriptions :column="2" border>
          <el-descriptions-item label="商品名称">{{ detail.productName ?? '-' }}</el-descriptions-item>
          <el-descriptions-item label="SKU编码">{{ detail.skuCode ?? '-' }}</el-descriptions-item>
          <el-descriptions-item label="当前库存">{{ detail.currentStock ?? 0 }}</el-descriptions-item>
          <el-descriptions-item label="最低库存">{{ detail.minStock ?? 0 }}</el-descriptions-item>
          <el-descriptions-item label="店铺ID">{{ detail.sid ?? '-' }}</el-descriptions-item>
          <el-descriptions-item label="更新时间">{{ detail.updateTime ?? '-' }}</el-descriptions-item>
        </el-descriptions>
      </template>
      <el-empty v-else-if="!loading" description="未找到库存记录" />
    </el-card>
  </div>
</template>

<script setup>
import { ref, onMounted, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ArrowLeft } from '@element-plus/icons-vue'
import { ElMessage } from 'element-plus'
import { getInventoryById } from '@/api/inventory'

const route = useRoute()
const router = useRouter()
const loading = ref(false)
const detail = ref({})

function goBack() {
  router.push('/inventory/list')
}

async function fetchDetail() {
  const id = route.params.id
  if (!id) return
  loading.value = true
  try {
    const res = await getInventoryById(id)
    detail.value = res?.data ?? res ?? {}
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
.inventory-detail-page { padding: 20px; }
.card-header { display: flex; align-items: center; gap: 12px; }
.card-header .title { font-size: 18px; font-weight: bold; }
</style>
