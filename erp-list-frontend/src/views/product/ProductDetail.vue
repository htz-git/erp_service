<template>
  <div class="page product-detail-page">
    <el-card v-loading="loading">
      <template #header>
        <div class="card-header">
          <el-button link type="primary" @click="goBack">
            <el-icon><ArrowLeft /></el-icon> 返回列表
          </el-button>
          <span class="title">商品详情</span>
        </div>
      </template>
      <template v-if="detail.id">
        <div v-if="detail.imageUrl || detail.image_url" class="product-image-wrap">
          <el-image
            :src="detail.imageUrl || detail.image_url"
            fit="contain"
            class="product-detail-img"
            :preview-src-list="[detail.imageUrl || detail.image_url]"
          />
        </div>
        <el-descriptions :column="2" border>
          <el-descriptions-item label="商品名称">{{ detail.productName ?? '-' }}</el-descriptions-item>
          <el-descriptions-item label="商品编码">{{ detail.productCode ?? '-' }}</el-descriptions-item>
          <el-descriptions-item label="创建时间">{{ detail.createTime }}</el-descriptions-item>
          <el-descriptions-item label="更新时间">{{ detail.updateTime }}</el-descriptions-item>
          <el-descriptions-item label="备注" :span="2">{{ detail.remark ?? '-' }}</el-descriptions-item>
        </el-descriptions>
      </template>
      <el-empty v-else-if="!loading" description="未找到商品" />
    </el-card>
  </div>
</template>

<script setup>
import { ref, onMounted, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ArrowLeft } from '@element-plus/icons-vue'
import { ElMessage } from 'element-plus'
import { productApi } from '@/api/product'

const route = useRoute()
const router = useRouter()
const loading = ref(false)
const detail = ref({})

function goBack() {
  router.push('/product/list')
}

async function fetchDetail() {
  const id = route.params.id
  if (!id) return
  loading.value = true
  try {
    const res = await productApi.getProductById(id)
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
.product-detail-page { padding: 20px; }
.card-header { display: flex; align-items: center; gap: 12px; }
.card-header .title { font-size: 18px; font-weight: bold; }
.product-image-wrap { margin-bottom: 16px; }
.product-detail-img { max-width: 200px; max-height: 200px; border-radius: 8px; border: 1px solid var(--el-border-color); }
</style>
