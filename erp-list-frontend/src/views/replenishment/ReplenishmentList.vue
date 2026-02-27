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
          <el-form-item label="店铺">
            <el-select
              v-model="filterForm.sid"
              placeholder="默认当前店铺"
              clearable
              style="width: 180px"
            >
              <el-option
                v-for="s in sellerOptions"
                :key="s.id"
                :label="s.sellerName || s.seller_name || `店铺 ${s.id}`"
                :value="s.id"
              />
            </el-select>
          </el-form-item>
          <el-form-item>
            <el-button type="primary" :loading="loading" @click="fetchSuggestions">
              生成补货建议
            </el-button>
            <el-button @click="resetFilter">重置</el-button>
            <el-button
              type="success"
              :disabled="!selectedSuggestions.length || !selectedSuggestions.some(r => (r.suggestedQuantity ?? 0) > 0)"
              @click="openBatchCreateDialog"
            >
              批量生成采购单
            </el-button>
          </el-form-item>
        </el-form>
      </div>

      <!-- 补货建议列表 -->
      <div class="table-section">
        <el-table
          ref="tableRef"
          v-loading="loading"
          :data="suggestions"
          stripe
          border
          style="width: 100%"
          :empty-text="emptyText"
          @selection-change="onSelectionChange"
        >
          <el-table-column type="selection" width="50" :selectable="row => (row.suggestedQuantity ?? 0) > 0" />
          <el-table-column label="所属店铺" width="120">
            <template #default="{ row }">
              {{ sellerNameBySid(row.sid) }}
            </template>
          </el-table-column>
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
          <el-table-column label="操作" width="120" fixed="right">
            <template #default="{ row }">
              <el-button
                type="primary"
                link
                :disabled="(row.suggestedQuantity ?? 0) <= 0"
                @click="openSingleCreateDialog(row)"
              >
                生成采购单
              </el-button>
            </template>
          </el-table-column>
        </el-table>
      </div>
    </el-card>

    <!-- 生成采购单：选择供应商 -->
    <el-dialog
      v-model="createDialogVisible"
      title="生成采购单"
      width="400px"
      :close-on-click-modal="false"
      @closed="createDialogClosed"
    >
      <el-form :model="createForm" label-width="80px">
        <el-form-item label="供应商" required>
          <el-select
            v-model="createForm.supplierId"
            placeholder="请选择供应商"
            filterable
            style="width: 100%"
            :loading="suppliersLoading"
          >
            <el-option
              v-for="s in supplierOptions"
              :key="s.id"
              :label="s.supplierName || s.supplier_name || `供应商 ${s.id}`"
              :value="s.id"
            />
          </el-select>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="createDialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="createSubmitting" @click="submitCreatePurchase">
          确定
        </el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { useUserStore } from '@/store/user'
import { getReplenishmentSuggestions } from '@/api/replenishment'
import { sellerApi } from '@/api/seller'
import { purchaseApi } from '@/api/purchase'

const router = useRouter()
const userStore = useUserStore()
const currentZid = computed(() => userStore.currentZid())

const loading = ref(false)
const suggestions = ref([])
const sellerOptions = ref([])
const tableRef = ref(null)
const selectedSuggestions = ref([])
const createDialogVisible = ref(false)
const createSubmitting = ref(false)
const suppliersLoading = ref(false)
const supplierOptions = ref([])
const createForm = ref({ supplierId: null })
/** 待生成采购单的建议行（单行或批量） */
const pendingSuggestions = ref([])

const filterForm = ref({
  startDate: '',
  endDate: '',
  forecastDays: 7,
  sid: null
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

function sellerNameBySid(sid) {
  if (sid == null) return '-'
  const s = sellerOptions.value.find((x) => x.id === sid)
  return s ? (s.sellerName || s.seller_name || `店铺 ${sid}`) : `店铺 ${sid}`
}

function buildParams() {
  const p = {}
  if (filterForm.value.startDate) p.startDate = filterForm.value.startDate
  if (filterForm.value.endDate) p.endDate = filterForm.value.endDate
  if (filterForm.value.forecastDays != null) p.forecastDays = filterForm.value.forecastDays
  if (filterForm.value.sid != null && filterForm.value.sid !== '') p.sid = filterForm.value.sid
  return p
}

async function loadSellerOptions() {
  const zid = currentZid.value
  if (!zid) {
    sellerOptions.value = []
    return
  }
  try {
    const res = await sellerApi.querySellers({ zid, pageNum: 1, pageSize: 500 })
    sellerOptions.value = res?.data?.records ?? []
  } catch {
    sellerOptions.value = []
  }
}

function resetFilter() {
  filterForm.value = {
    startDate: '',
    endDate: '',
    forecastDays: 7,
    sid: null
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

function onSelectionChange(rows) {
  selectedSuggestions.value = rows
}

// 兼容接口返回 camelCase 或 snake_case
function rowToSuggestion(row) {
  return {
    sid: row.sid,
    productId: row.productId ?? row.product_id,
    productName: row.productName ?? row.product_name ?? '',
    skuId: row.skuId ?? row.sku_id,
    skuCode: row.skuCode ?? row.sku_code ?? '',
    suggestedQuantity: row.suggestedQuantity ?? row.suggested_quantity ?? 0
  }
}

function openSingleCreateDialog(row) {
  if ((row.suggestedQuantity ?? 0) <= 0) return
  pendingSuggestions.value = [row]
  createForm.value = { supplierId: null }
  loadSuppliers()
  createDialogVisible.value = true
}

function openBatchCreateDialog() {
  const valid = selectedSuggestions.value.filter((r) => (r.suggestedQuantity ?? 0) > 0)
  if (!valid.length) {
    ElMessage.warning('请勾选建议补货量大于 0 的建议')
    return
  }
  pendingSuggestions.value = valid
  createForm.value = { supplierId: null }
  loadSuppliers()
  createDialogVisible.value = true
}

async function loadSuppliers() {
  suppliersLoading.value = true
  try {
    const zid = currentZid.value
    const res = await purchaseApi.querySuppliers({ zid, pageNum: 1, pageSize: 500 })
    const list = res?.data?.records ?? res?.data ?? []
    supplierOptions.value = Array.isArray(list) ? list : []
  } catch {
    supplierOptions.value = []
  } finally {
    suppliersLoading.value = false
  }
}

function createDialogClosed() {
  pendingSuggestions.value = []
  createForm.value = { supplierId: null }
}

async function submitCreatePurchase() {
  const supplierId = createForm.value.supplierId
  if (supplierId == null || supplierId === '') {
    ElMessage.warning('请选择供应商')
    return
  }
  const list = pendingSuggestions.value.filter((r) => (r.suggestedQuantity ?? 0) > 0)
  if (!list.length) {
    ElMessage.warning('没有有效的补货建议')
    return
  }
  createSubmitting.value = true
  try {
    const body = {
      supplierId,
      suggestions: list.map(rowToSuggestion)
    }
    // 确保每条建议都有 productId，否则后端会报错
    const invalid = body.suggestions.filter(s => s.productId == null || s.suggestedQuantity <= 0)
    if (invalid.length) {
      ElMessage.warning('部分建议缺少商品ID或补货量为0，已自动排除。若仍失败请检查补货建议接口返回字段。')
    }
    await purchaseApi.createPurchaseFromSuggestions(body)
    createDialogVisible.value = false
    const n = list.length
    ElMessage.success(n > 1 ? `已生成 1 张采购单，共 ${n} 个商品` : '已生成采购单')
    router.push({ name: 'PurchaseList' }).catch(() => {})
  } catch (e) {
    const msg = e.response?.data?.message ?? e.response?.data?.msg ?? e.message
    ElMessage.error(msg || '生成采购单失败')
  } finally {
    createSubmitting.value = false
  }
}

onMounted(() => {
  loadSellerOptions()
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
