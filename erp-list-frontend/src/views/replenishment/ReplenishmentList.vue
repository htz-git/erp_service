<template>
  <div class="page replenishment-page">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>补货管理</span>
        </div>
      </template>

      <!-- 补货建议筛选区 -->
      <div class="filter-section">
        <el-form :model="filterForm" inline class="filter-form">
          <el-form-item label="历史开始日期">
            <el-date-picker
              v-model="filterForm.startDate"
              type="date"
              value-format="YYYY-MM-DD"
              placeholder="默认 30 天前"
              clearable
              style="width: 160px"
            />
          </el-form-item>
          <el-form-item label="历史结束日期">
            <el-date-picker
              v-model="filterForm.endDate"
              type="date"
              value-format="YYYY-MM-DD"
              placeholder="默认昨天"
              clearable
              style="width: 160px"
            />
          </el-form-item>
          <el-form-item label="预测天数">
            <el-input-number
              v-model="filterForm.forecastDays"
              :min="1"
              :max="30"
              controls-position="right"
              style="width: 120px"
            />
          </el-form-item>
          <el-form-item>
            <el-button type="primary" :loading="loading" @click="fetchSuggestions">
              生成补货建议
            </el-button>
            <el-button @click="resetFilter">重置</el-button>
          </el-form-item>
        </el-form>
      </div>

      <!-- 补货建议列表 -->
      <div class="table-section">
        <el-table
          v-loading="loading"
          :data="suggestions"
          stripe
          border
          style="width: 100%"
          :empty-text="emptyText"
        >
          <el-table-column prop="skuCode" label="SKU 编码" width="120" />
          <el-table-column prop="productName" label="商品名称" min-width="160" show-overflow-tooltip />
          <el-table-column prop="forecastTotal" label="预测总需求" width="110" align="right">
            <template #default="{ row }">
              {{ row.forecastTotal ?? 0 }}
            </template>
          </el-table-column>
          <el-table-column prop="currentStock" label="当前库存" width="100" align="right">
            <template #default="{ row }">
              {{ row.currentStock ?? 0 }}
            </template>
          </el-table-column>
          <el-table-column prop="suggestedQuantity" label="建议补货量" width="110" align="right">
            <template #default="{ row }">
              {{ row.suggestedQuantity ?? 0 }}
            </template>
          </el-table-column>
          <el-table-column label="每日预测" width="140" align="center">
            <template #default="{ row }">
              <span v-if="row.forecastDaily && row.forecastDaily.length" class="forecast-daily">
                {{ formatForecastDaily(row.forecastDaily) }}
              </span>
              <span v-else>-</span>
            </template>
          </el-table-column>
        </el-table>
      </div>
    </el-card>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { getReplenishmentSuggestions } from '@/api/replenishment'

const loading = ref(false)
const suggestions = ref([])

const filterForm = ref({
  startDate: '',
  endDate: '',
  forecastDays: 7
})

const emptyText = computed(() =>
  loading.value ? '加载中...' : '请设置筛选条件后点击「生成补货建议」'
)

function formatForecastDaily(daily) {
  if (!Array.isArray(daily) || daily.length === 0) return '-'
  const sum = daily.reduce((a, b) => a + (Number(b) || 0), 0)
  const avg = daily.length ? (sum / daily.length).toFixed(1) : 0
  return `共 ${daily.length} 天，日均 ${avg}`
}

function buildParams() {
  const p = {}
  if (filterForm.value.startDate) p.startDate = filterForm.value.startDate
  if (filterForm.value.endDate) p.endDate = filterForm.value.endDate
  if (filterForm.value.forecastDays != null) p.forecastDays = filterForm.value.forecastDays
  return p
}

function resetFilter() {
  filterForm.value = {
    startDate: '',
    endDate: '',
    forecastDays: 7
  }
  suggestions.value = []
}

async function fetchSuggestions() {
  loading.value = true
  try {
    const res = await getReplenishmentSuggestions(buildParams())
    suggestions.value = (res && res.data) ? res.data : []
    if (suggestions.value.length === 0) {
      ElMessage.info('暂无补货建议数据，请确认历史日期范围内有销售数据')
    }
  } catch (e) {
    ElMessage.error(e.message || '获取补货建议失败')
    suggestions.value = []
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  // 不自动拉取，由用户点击「生成补货建议」触发
})
</script>

<style scoped>
.replenishment-page { padding: 20px; }
.card-header { font-size: 18px; font-weight: bold; }
.filter-section { margin-bottom: 16px; }
.filter-form { margin: 0; }
.table-section { margin-top: 12px; }
.forecast-daily { font-size: 12px; color: #606266; }
</style>
