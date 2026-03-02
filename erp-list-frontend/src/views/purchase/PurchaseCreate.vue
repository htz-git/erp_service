<template>
  <div class="page purchase-create-page">
    <div class="page-header">
      <el-button type="primary" link class="back-btn" @click="goBack">
        <el-icon><ArrowLeft /></el-icon>
        返回采购列表
      </el-button>
      <h1 class="page-title">新增采购单</h1>
      <p class="page-desc">选择供应商与店铺，填写采购明细，提交后进入待审核状态。</p>
    </div>

    <el-card class="form-card" shadow="hover">
      <template #header>
        <span class="card-title">采购单信息</span>
      </template>
      <el-form ref="formRef" :model="form" :rules="rules" label-width="100px" class="create-form">
        <el-row :gutter="24">
          <el-col :xs="24" :sm="24" :md="12">
            <el-form-item label="供应商" prop="supplierId">
              <el-select
                v-model="form.supplierId"
                placeholder="请选择供应商"
                filterable
                style="width: 100%"
                :loading="supplierLoading"
              >
                <el-option
                  v-for="s in supplierOptions"
                  :key="s.id"
                  :label="s.supplierName || s.supplier_name || `供应商 ${s.id}`"
                  :value="s.id"
                />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :xs="24" :sm="24" :md="12">
            <el-form-item label="店铺" prop="sid">
              <el-select
                v-model="form.sid"
                placeholder="请选择店铺"
                clearable
                style="width: 100%"
                :loading="shopLoading"
              >
                <el-option
                  v-for="s in shopOptions"
                  :key="s.id"
                  :label="s.sellerName || s.seller_name || `店铺 ${s.id}`"
                  :value="s.id"
                />
              </el-select>
            </el-form-item>
          </el-col>
        </el-row>
        <el-form-item label="备注" prop="remark">
          <el-input v-model="form.remark" type="textarea" :rows="2" placeholder="选填" maxlength="500" show-word-limit />
        </el-form-item>
      </el-form>
    </el-card>

    <el-card class="form-card items-card" shadow="hover">
      <template #header>
        <span class="card-title">采购明细</span>
        <el-button type="primary" plain size="small" @click="addItemRow">
          <el-icon><Plus /></el-icon>
          添加一行
        </el-button>
      </template>
      <el-table :data="itemRows" border size="small" class="items-table">
        <el-table-column type="index" label="#" width="50" align="center" />
        <el-table-column label="商品名称" min-width="160">
          <template #default="{ row }">
            <el-input v-model="row.productName" placeholder="商品名称" size="small" clearable />
          </template>
        </el-table-column>
        <el-table-column label="SKU编码" width="120">
          <template #default="{ row }">
            <el-input v-model="row.skuCode" placeholder="SKU" size="small" clearable />
          </template>
        </el-table-column>
        <el-table-column label="采购单价" width="120">
          <template #default="{ row }">
            <el-input-number
              v-model="row.purchasePrice"
              :min="0"
              :precision="2"
              controls-position="right"
              size="small"
              style="width: 100%"
            />
          </template>
        </el-table-column>
        <el-table-column label="采购数量" width="120">
          <template #default="{ row }">
            <el-input-number
              v-model="row.purchaseQuantity"
              :min="1"
              :precision="0"
              controls-position="right"
              size="small"
              style="width: 100%"
            />
          </template>
        </el-table-column>
        <el-table-column label="小计" width="100" align="right">
          <template #default="{ row }">
            {{ itemRowTotal(row) }}
          </template>
        </el-table-column>
        <el-table-column label="操作" width="70" align="center" fixed="right">
          <template #default="{ $index }">
            <el-button type="danger" link size="small" @click="removeItemRow($index)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
      <div class="items-footer">
        <span class="total-label">合计金额：</span>
        <span class="total-value">{{ totalAmount }}</span>
      </div>
      <div v-if="itemRows.length === 0" class="items-empty">请点击「添加一行」填写采购明细</div>
    </el-card>

    <div class="form-actions">
      <el-button type="primary" size="large" :loading="submitLoading" @click="handleSubmit">
        提交创建
      </el-button>
      <el-button size="large" @click="goBack">取消</el-button>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { ArrowLeft, Plus } from '@element-plus/icons-vue'
import { useUserStore } from '@/store/user'
import { purchaseApi } from '@/api/purchase'
import { sellerApi } from '@/api/seller'

const router = useRouter()
const userStore = useUserStore()
const currentZid = computed(() => userStore.currentZid())

const formRef = ref(null)
const submitLoading = ref(false)
const supplierLoading = ref(false)
const shopLoading = ref(false)
const supplierOptions = ref([])
const shopOptions = ref([])

const form = reactive({
  supplierId: null,
  sid: null,
  remark: ''
})

const rules = {
  supplierId: [{ required: true, message: '请选择供应商', trigger: 'change' }]
}

function defaultItemRow() {
  return {
    productName: '',
    skuCode: '',
    purchasePrice: 0,
    purchaseQuantity: 1
  }
}

const itemRows = ref([defaultItemRow()])

function addItemRow() {
  itemRows.value.push(defaultItemRow())
}

function removeItemRow(index) {
  itemRows.value.splice(index, 1)
}

function itemRowTotal(row) {
  const p = Number(row.purchasePrice) || 0
  const q = Number(row.purchaseQuantity) || 0
  return (p * q).toFixed(2)
}

const totalAmount = computed(() => {
  let sum = 0
  for (const row of itemRows.value) {
    sum += (Number(row.purchasePrice) || 0) * (Number(row.purchaseQuantity) || 0)
  }
  return sum.toFixed(2)
})

function goBack() {
  router.push('/purchase/list')
}

async function loadSuppliers() {
  supplierLoading.value = true
  try {
    const res = await purchaseApi.querySuppliers({ pageNum: 1, pageSize: 500 })
    supplierOptions.value = res?.data?.records ?? res?.data ?? []
  } catch {
    supplierOptions.value = []
  } finally {
    supplierLoading.value = false
  }
}

async function loadShops() {
  const zid = currentZid.value
  if (zid == null || zid === '') {
    shopOptions.value = []
    return
  }
  shopLoading.value = true
  try {
    const res = await sellerApi.querySellers({ zid, pageNum: 1, pageSize: 500 })
    shopOptions.value = res?.data?.records ?? []
  } catch {
    shopOptions.value = []
  } finally {
    shopLoading.value = false
  }
}

async function handleSubmit() {
  if (!formRef.value) return
  await formRef.value.validate(async (valid) => {
    if (!valid) return
    const rows = itemRows.value.filter(
      (r) => (r.productName && r.productName.trim()) && (Number(r.purchaseQuantity) || 0) > 0
    )
    if (rows.length === 0) {
      ElMessage.warning('请至少添加一条有效采购明细（商品名称 + 数量）')
      return
    }
    const total = Number(totalAmount.value) || 0
    if (total <= 0) {
      ElMessage.warning('合计金额须大于 0')
      return
    }
    submitLoading.value = true
    try {
      const items = rows.map((r) => ({
        productName: r.productName?.trim() || '',
        skuCode: r.skuCode?.trim() || undefined,
        purchasePrice: Number(r.purchasePrice) || 0,
        purchaseQuantity: Number(r.purchaseQuantity) || 1,
        totalPrice: (Number(r.purchasePrice) || 0) * (Number(r.purchaseQuantity) || 1)
      }))
      await purchaseApi.createPurchaseOrder({
        supplierId: form.supplierId,
        sid: form.sid || undefined,
        totalAmount: total,
        purchaseStatus: 0,
        remark: form.remark?.trim() || undefined,
        items
      })
      ElMessage.success('采购单创建成功')
      router.push('/purchase/list')
    } catch (e) {
      ElMessage.error(e?.response?.data?.message || e?.message || '创建失败')
    } finally {
      submitLoading.value = false
    }
  })
}

onMounted(() => {
  loadSuppliers()
  loadShops()
})
</script>

<style scoped>
.purchase-create-page { padding: 20px; }
.page-header { margin-bottom: 20px; }
.back-btn { margin-bottom: 8px; }
.page-title { font-size: 20px; font-weight: bold; margin: 0 0 8px; }
.page-desc { color: var(--el-text-color-secondary); font-size: 14px; margin: 0; }
.form-card { margin-bottom: 20px; }
.form-card .card-title { font-weight: bold; }
.items-card .el-card__header { display: flex; align-items: center; justify-content: space-between; }
.items-table { margin-bottom: 12px; }
.items-footer { text-align: right; font-size: 14px; }
.total-label { margin-right: 8px; color: var(--el-text-color-regular); }
.total-value { font-weight: bold; color: var(--el-color-primary); }
.items-empty { color: var(--el-text-color-placeholder); font-size: 13px; padding: 12px 0; }
.form-actions { margin-top: 24px; display: flex; gap: 12px; }
</style>
