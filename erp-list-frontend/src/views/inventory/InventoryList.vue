<template>
  <div class="page inventory-page">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>库存管理</span>
        </div>
      </template>

      <div class="filter-section">
        <el-form :model="filterForm" inline class="filter-form">
          <el-form-item label="店铺">
            <el-select
              v-model="filterForm.sid"
              placeholder="全部店铺"
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
          <el-form-item label="SKU编码">
            <el-input v-model="filterForm.skuCode" placeholder="SKU编码" clearable style="width: 140px" />
          </el-form-item>
          <el-form-item label="关键词">
            <el-input v-model="filterForm.keyword" placeholder="SKU/商品名称" clearable style="width: 160px" />
          </el-form-item>
          <el-form-item>
            <el-button type="primary" :loading="loading" @click="fetchList">查询</el-button>
            <el-button @click="handleReset">重置</el-button>
            <el-button type="primary" @click="openDialog()">新增库存</el-button>
          </el-form-item>
        </el-form>
      </div>

      <div class="table-section">
        <el-table v-loading="loading" :data="list" stripe border style="width: 100%">
          <el-table-column label="商品图" width="80" align="center">
            <template #default="{ row }">
              <el-image
                v-if="row.productImageUrl"
                :src="row.productImageUrl"
                fit="cover"
                class="inventory-list-product-img"
                :preview-src-list="[row.productImageUrl]"
              />
              <div v-else class="inventory-list-img-placeholder">
                <el-icon :size="20"><Picture /></el-icon>
              </div>
            </template>
          </el-table-column>
          <el-table-column label="所属店铺" width="120">
            <template #default="{ row }">
              {{ sellerNameBySid(row.sid) }}
            </template>
          </el-table-column>
          <el-table-column prop="skuCode" label="SKU编码" width="120" show-overflow-tooltip />
          <el-table-column prop="productName" label="商品名称" min-width="160" show-overflow-tooltip />
          <el-table-column prop="currentStock" label="当前库存" width="100" align="right">
            <template #default="{ row }">{{ row.currentStock ?? 0 }}</template>
          </el-table-column>
          <el-table-column prop="minStock" label="最低库存" width="100" align="right">
            <template #default="{ row }">{{ row.minStock ?? 0 }}</template>
          </el-table-column>
          <el-table-column prop="updateTime" label="更新时间" width="170" />
          <el-table-column label="操作" width="260" fixed="right">
            <template #default="{ row }">
              <el-button type="primary" link size="small" @click="$router.push('/inventory/detail/' + row.id)">详情</el-button>
              <el-button type="primary" link size="small" @click="openDialog(row)">编辑</el-button>
              <el-button type="success" link size="small" @click="openStockInDialog(row)">入库</el-button>
              <el-button type="warning" link size="small" @click="openStockOutDialog(row)">出库</el-button>
            </template>
          </el-table-column>
        </el-table>
      </div>

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

    <el-dialog
      v-model="dialogVisible"
      :title="editId ? '编辑库存' : '新增库存'"
      width="500px"
      destroy-on-close
      @close="resetForm"
    >
      <el-form ref="formRef" :model="form" :rules="rules" label-width="100px">
        <el-form-item v-if="!editId" label="所属店铺" prop="sid">
          <el-select
            v-model="form.sid"
            placeholder="请选择店铺（必选）"
            style="width: 100%"
            :loading="sellerOptionsLoading"
          >
            <el-option
              v-for="s in sellerOptions"
              :key="s.id"
              :label="s.sellerName || s.seller_name || `店铺 ${s.id}`"
              :value="s.id"
            />
          </el-select>
        </el-form-item>
        <el-form-item v-if="!editId" label="选择商品" prop="productId">
          <el-select
            v-model="form.productId"
            placeholder="请选择商品（必选）"
            filterable
            style="width: 100%"
            :loading="productOptionsLoading"
            @change="onProductSelect"
          >
            <el-option
              v-for="p in productOptions"
              :key="p.id"
              :label="`${p.skuCode || p.id} - ${p.productName || ''}`"
              :value="p.id"
            />
          </el-select>
        </el-form-item>
        <template v-if="editId">
          <el-form-item label="所属店铺">{{ sellerNameBySid(form.sid) }}</el-form-item>
          <el-form-item label="SKU编码">{{ form.skuCode || '-' }}</el-form-item>
          <el-form-item label="商品名称">{{ form.productName || '-' }}</el-form-item>
        </template>
        <el-form-item label="当前库存" prop="currentStock">
          <el-input-number v-model="form.currentStock" :min="0" controls-position="right" style="width: 100%" />
        </el-form-item>
        <el-form-item label="最低库存" prop="minStock">
          <el-input-number v-model="form.minStock" :min="0" controls-position="right" style="width: 100%" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="submitLoading" @click="handleSubmit">确定</el-button>
      </template>
    </el-dialog>

    <!-- 入库 -->
    <el-dialog v-model="stockInVisible" title="入库" width="400px" destroy-on-close @close="stockInRow = null">
      <template v-if="stockInRow">
        <p class="stock-dialog-desc">商品：{{ stockInRow.productName }}（{{ stockInRow.skuCode || '-' }}）</p>
        <el-form ref="stockInFormRef" :model="stockInForm" :rules="stockInRules" label-width="90px">
          <el-form-item label="入库数量" prop="quantity">
            <el-input-number v-model="stockInForm.quantity" :min="1" :precision="0" controls-position="right" style="width: 100%" />
          </el-form-item>
          <el-form-item label="关联采购单">
            <el-input v-model.number="stockInForm.purchaseId" placeholder="选填，采购单 ID" clearable style="width: 100%" />
          </el-form-item>
        </el-form>
      </template>
      <template #footer>
        <el-button @click="stockInVisible = false">取消</el-button>
        <el-button type="primary" :loading="stockInSubmitting" @click="submitStockIn">确定入库</el-button>
      </template>
    </el-dialog>

    <!-- 出库 -->
    <el-dialog v-model="stockOutVisible" title="出库" width="400px" destroy-on-close @close="stockOutRow = null">
      <template v-if="stockOutRow">
        <p class="stock-dialog-desc">商品：{{ stockOutRow.productName }}（{{ stockOutRow.skuCode || '-' }}），当前库存 {{ stockOutRow.currentStock ?? 0 }}</p>
        <el-form ref="stockOutFormRef" :model="stockOutForm" :rules="stockOutRules" label-width="90px">
          <el-form-item label="出库数量" prop="quantity">
            <el-input-number v-model="stockOutForm.quantity" :min="1" :max="(stockOutRow && (stockOutRow.currentStock ?? 0)) || 99999" :precision="0" controls-position="right" style="width: 100%" />
          </el-form-item>
        </el-form>
      </template>
      <template #footer>
        <el-button @click="stockOutVisible = false">取消</el-button>
        <el-button type="primary" :loading="stockOutSubmitting" @click="submitStockOut">确定出库</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, computed } from 'vue'
import { ElMessage } from 'element-plus'
import { Picture } from '@element-plus/icons-vue'
import { useUserStore } from '@/store/user'
import { getInventoryList, getInventoryById, createInventory, updateInventory, stockIn, stockOut } from '@/api/inventory'
import { productApi } from '@/api/product'
import { sellerApi } from '@/api/seller'

const userStore = useUserStore()
const currentZid = computed(() => userStore.currentZid())

const loading = ref(false)
const list = ref([])
const productOptions = ref([])
const productOptionsLoading = ref(false)
const sellerOptions = ref([])
const sellerOptionsLoading = ref(false)

const filterForm = ref({ sid: null, skuCode: '', keyword: '' })
const pagination = reactive({ pageNum: 1, pageSize: 10, total: 0 })

const stockInVisible = ref(false)
const stockInRow = ref(null)
const stockInForm = ref({ quantity: 1, purchaseId: null })
const stockInFormRef = ref(null)
const stockInSubmitting = ref(false)
const stockInRules = { quantity: [{ required: true, message: '请输入入库数量', trigger: 'blur' }, { type: 'number', min: 1, message: '至少 1', trigger: 'blur' }] }

const stockOutVisible = ref(false)
const stockOutRow = ref(null)
const stockOutForm = ref({ quantity: 1 })
const stockOutFormRef = ref(null)
const stockOutSubmitting = ref(false)
const stockOutRules = { quantity: [{ required: true, message: '请输入出库数量', trigger: 'blur' }, { type: 'number', min: 1, message: '至少 1', trigger: 'blur' }] }

function sellerNameBySid(sid) {
  if (sid == null) return '-'
  const s = sellerOptions.value.find((x) => x.id === sid)
  return s ? (s.sellerName || s.seller_name || `店铺 ${sid}`) : `店铺 ${sid}`
}

function buildParams() {
  const p = { pageNum: pagination.pageNum, pageSize: pagination.pageSize }
  if (filterForm.value.sid != null && filterForm.value.sid !== '') p.sid = filterForm.value.sid
  if (filterForm.value.skuCode) p.skuCode = filterForm.value.skuCode
  if (filterForm.value.keyword) p.keyword = filterForm.value.keyword
  return p
}

async function fetchList() {
  loading.value = true
  try {
    const res = await getInventoryList(buildParams())
    const data = res?.data
    list.value = data?.records ?? []
    pagination.total = data?.total ?? 0
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

function handleReset() {
  filterForm.value = { sid: null, skuCode: '', keyword: '' }
  pagination.pageNum = 1
  fetchList()
}

async function loadSellerOptions() {
  const zid = currentZid.value
  if (!zid) {
    sellerOptions.value = []
    return
  }
  sellerOptionsLoading.value = true
  try {
    const res = await sellerApi.querySellers({ zid, pageNum: 1, pageSize: 500 })
    sellerOptions.value = res?.data?.records ?? []
  } catch {
    sellerOptions.value = []
  } finally {
    sellerOptionsLoading.value = false
  }
}

const dialogVisible = ref(false)
const editId = ref(null)
const submitLoading = ref(false)
const formRef = ref(null)
const form = ref({
  sid: null,
  productId: null,
  productName: '',
  skuId: null,
  skuCode: '',
  currentStock: 0,
  minStock: 0
})
const rules = {
  currentStock: [{ required: true, message: '请输入当前库存', trigger: 'blur' }]
}

function resetForm() {
  editId.value = null
  form.value = {
    sid: null,
    productId: null,
    productName: '',
    skuId: null,
    skuCode: '',
    currentStock: 0,
    minStock: 0
  }
  formRef.value?.resetFields()
}

async function loadProductOptions() {
  const zid = currentZid.value
  if (!zid) {
    productOptions.value = []
    return
  }
  productOptionsLoading.value = true
  try {
    const res = await productApi.queryProducts({ zid, pageNum: 1, pageSize: 500 })
    productOptions.value = res.data?.records ?? []
  } catch {
    productOptions.value = []
  } finally {
    productOptionsLoading.value = false
  }
}

function onProductSelect(id) {
  const p = productOptions.value.find((x) => x.id === id)
  if (p) {
    form.value.productName = p.productName ?? ''
    form.value.skuCode = p.skuCode ?? ''
    form.value.skuId = p.id
  }
}

function openDialog(row) {
  editId.value = row ? row.id : null
  if (row) {
    form.value = {
      sid: row.sid,
      productId: row.productId,
      productName: row.productName ?? '',
      skuId: row.skuId,
      skuCode: row.skuCode ?? '',
      currentStock: row.currentStock ?? 0,
      minStock: row.minStock ?? 0
    }
  } else {
    resetForm()
    loadSellerOptions()
    loadProductOptions()
  }
  dialogVisible.value = true
}

async function handleSubmit() {
  await formRef.value?.validate().catch(() => {})
  submitLoading.value = true
  try {
    if (editId.value) {
      await updateInventory(editId.value, {
        currentStock: form.value.currentStock,
        minStock: form.value.minStock,
        productName: form.value.productName,
        skuCode: form.value.skuCode
      })
      ElMessage.success('更新成功')
    } else {
      if (form.value.sid == null) {
        ElMessage.warning('请选择所属店铺')
        return
      }
      if (form.value.productId == null) {
        ElMessage.warning('请选择商品')
        return
      }
      await createInventory({
        sid: form.value.sid,
        productId: form.value.productId,
        productName: form.value.productName,
        skuId: form.value.skuId ?? form.value.productId,
        skuCode: form.value.skuCode,
        currentStock: form.value.currentStock ?? 0,
        minStock: form.value.minStock ?? 0
      })
      ElMessage.success('创建成功')
    }
    dialogVisible.value = false
    fetchList()
  } catch (e) {
    ElMessage.error(e?.response?.data?.message ?? e?.message ?? '操作失败')
  } finally {
    submitLoading.value = false
  }
}

function openStockInDialog(row) {
  stockInRow.value = row
  stockInForm.value = { quantity: 1, purchaseId: null }
  stockInVisible.value = true
}

function openStockOutDialog(row) {
  stockOutRow.value = row
  stockOutForm.value = { quantity: 1 }
  stockOutVisible.value = true
}

async function submitStockIn() {
  await stockInFormRef.value?.validate().catch(() => {})
  const id = stockInRow.value?.id
  if (!id) return
  stockInSubmitting.value = true
  try {
    await stockIn(id, {
      quantity: stockInForm.value.quantity,
      purchaseId: stockInForm.value.purchaseId || undefined
    })
    ElMessage.success('入库成功')
    stockInVisible.value = false
    fetchList()
  } catch (e) {
    ElMessage.error(e?.response?.data?.message ?? e?.message ?? '入库失败')
  } finally {
    stockInSubmitting.value = false
  }
}

async function submitStockOut() {
  await stockOutFormRef.value?.validate().catch(() => {})
  const id = stockOutRow.value?.id
  if (!id) return
  const q = stockOutForm.value.quantity
  const cur = stockOutRow.value?.currentStock ?? 0
  if (q > cur) {
    ElMessage.warning('出库数量不能大于当前库存')
    return
  }
  stockOutSubmitting.value = true
  try {
    await stockOut(id, { quantity: q })
    ElMessage.success('出库成功')
    stockOutVisible.value = false
    fetchList()
  } catch (e) {
    ElMessage.error(e?.response?.data?.message ?? e?.message ?? '出库失败')
  } finally {
    stockOutSubmitting.value = false
  }
}

onMounted(() => {
  loadSellerOptions()
  fetchList()
})
</script>

<style scoped>
.inventory-page { padding: 20px; }
.card-header { font-size: 18px; font-weight: bold; }
.filter-section { margin-bottom: 16px; }
.filter-form { margin: 0; }
.table-section { margin-top: 12px; }
.pagination-section { margin-top: 16px; display: flex; justify-content: flex-end; }
.inventory-list-product-img { width: 48px; height: 48px; border-radius: 4px; object-fit: cover; }
.inventory-list-img-placeholder { width: 48px; height: 48px; border-radius: 4px; background: var(--el-fill-color-light); display: flex; align-items: center; justify-content: center; color: var(--el-text-color-placeholder); }
.stock-dialog-desc { margin-bottom: 16px; color: var(--el-text-color-regular); font-size: 14px; }
</style>
