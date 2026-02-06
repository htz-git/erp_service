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
          <el-table-column prop="skuCode" label="SKU编码" width="120" show-overflow-tooltip />
          <el-table-column prop="productName" label="商品名称" min-width="160" show-overflow-tooltip />
          <el-table-column prop="currentStock" label="当前库存" width="100" align="right">
            <template #default="{ row }">{{ row.currentStock ?? 0 }}</template>
          </el-table-column>
          <el-table-column prop="minStock" label="最低库存" width="100" align="right">
            <template #default="{ row }">{{ row.minStock ?? 0 }}</template>
          </el-table-column>
          <el-table-column prop="updateTime" label="更新时间" width="170" />
          <el-table-column label="操作" width="100" fixed="right">
            <template #default="{ row }">
              <el-button type="primary" link size="small" @click="openDialog(row)">编辑</el-button>
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
          @size-change="fetchList"
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
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, computed } from 'vue'
import { ElMessage } from 'element-plus'
import { useUserStore } from '@/store/user'
import { getInventoryList, getInventoryById, createInventory, updateInventory } from '@/api/inventory'
import { productApi } from '@/api/product'

const userStore = useUserStore()
const currentZid = computed(() => userStore.currentZid())

const loading = ref(false)
const list = ref([])
const productOptions = ref([])
const productOptionsLoading = ref(false)

const filterForm = ref({ skuCode: '', keyword: '' })
const pagination = reactive({ pageNum: 1, pageSize: 10, total: 0 })

function buildParams() {
  const p = { pageNum: pagination.pageNum, pageSize: pagination.pageSize }
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

function handleReset() {
  filterForm.value = { skuCode: '', keyword: '' }
  pagination.pageNum = 1
  fetchList()
}

const dialogVisible = ref(false)
const editId = ref(null)
const submitLoading = ref(false)
const formRef = ref(null)
const form = ref({
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
      productId: row.productId,
      productName: row.productName ?? '',
      skuId: row.skuId,
      skuCode: row.skuCode ?? '',
      currentStock: row.currentStock ?? 0,
      minStock: row.minStock ?? 0
    }
  } else {
    resetForm()
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
      if (form.value.productId == null) {
        ElMessage.warning('请选择商品')
        return
      }
      await createInventory({
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
    ElMessage.error(e.message || '操作失败')
  } finally {
    submitLoading.value = false
  }
}

onMounted(() => {
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
</style>
