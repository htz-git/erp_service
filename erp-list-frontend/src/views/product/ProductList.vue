<template>
  <div class="page product-list-page">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>商品管理</span>
        </div>
      </template>

      <!-- 筛选区 -->
      <div class="filter-section">
        <el-form :model="filterForm" inline class="filter-form">
          <el-form-item label="zid">
            <el-input v-model="filterForm.zid" placeholder="zid" clearable style="width: 100px" />
          </el-form-item>
          <el-form-item label="sid">
            <el-input v-model.number="filterForm.sid" placeholder="sid" clearable style="width: 100px" />
          </el-form-item>
          <el-form-item label="商品名称">
            <el-input v-model="filterForm.productName" placeholder="商品名称" clearable style="width: 160px" />
          </el-form-item>
          <el-form-item label="商品编码">
            <el-input v-model="filterForm.productCode" placeholder="商品编码" clearable style="width: 140px" />
          </el-form-item>
          <el-form-item>
            <el-button type="primary" :loading="loading" @click="handleSearch">查询</el-button>
            <el-button @click="handleReset">重置</el-button>
            <el-button type="primary" @click="openDialog()">新建</el-button>
          </el-form-item>
        </el-form>
      </div>

      <!-- 表格 -->
      <div class="table-section">
        <el-table
          v-loading="loading"
          :data="list"
          stripe
          border
          style="width: 100%"
        >
          <el-table-column prop="id" label="ID" width="80" />
          <el-table-column prop="zid" label="zid" width="80" />
          <el-table-column prop="sid" label="sid" width="80" />
          <el-table-column prop="productName" label="商品名称" min-width="140" show-overflow-tooltip />
          <el-table-column prop="productCode" label="商品编码" width="120" show-overflow-tooltip />
          <el-table-column prop="skuCode" label="SKU编码" width="100" show-overflow-tooltip />
          <el-table-column prop="platformSku" label="平台SKU" width="100" show-overflow-tooltip />
          <el-table-column prop="imageUrl" label="图片" width="80">
            <template #default="{ row }">
              <el-image
                v-if="row.imageUrl"
                :src="row.imageUrl"
                style="width: 36px; height: 36px"
                fit="cover"
                :preview-src-list="[row.imageUrl]"
              />
              <span v-else>-</span>
            </template>
          </el-table-column>
          <el-table-column prop="remark" label="备注" min-width="100" show-overflow-tooltip />
          <el-table-column prop="createTime" label="创建时间" width="170" />
          <el-table-column label="操作" width="140" fixed="right">
            <template #default="{ row }">
              <el-button type="primary" link size="small" @click="openDialog(row)">编辑</el-button>
              <el-button type="danger" link size="small" @click="handleDelete(row)">删除</el-button>
            </template>
          </el-table-column>
        </el-table>
      </div>

      <!-- 分页 -->
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

    <!-- 新建/编辑对话框 -->
    <el-dialog
      v-model="dialogVisible"
      :title="editId ? '编辑商品' : '新建商品'"
      width="500px"
      destroy-on-close
      @close="resetForm"
    >
      <el-form ref="formRef" :model="form" :rules="rules" label-width="100px">
        <el-form-item label="zid" prop="zid">
          <el-input v-model="form.zid" placeholder="公司ID，不填则用当前用户" clearable />
        </el-form-item>
        <el-form-item label="sid" prop="sid">
          <el-input v-model.number="form.sid" placeholder="店铺ID" clearable />
        </el-form-item>
        <el-form-item label="商品名称" prop="productName">
          <el-input v-model="form.productName" placeholder="商品名称" />
        </el-form-item>
        <el-form-item label="商品编码" prop="productCode">
          <el-input v-model="form.productCode" placeholder="商品编码" clearable />
        </el-form-item>
        <el-form-item label="SKU编码" prop="skuCode">
          <el-input v-model="form.skuCode" placeholder="SKU编码" clearable />
        </el-form-item>
        <el-form-item label="平台SKU" prop="platformSku">
          <el-input v-model="form.platformSku" placeholder="平台SKU" clearable />
        </el-form-item>
        <el-form-item label="图片URL" prop="imageUrl">
          <el-input v-model="form.imageUrl" placeholder="图片URL" clearable />
        </el-form-item>
        <el-form-item label="备注" prop="remark">
          <el-input v-model="form.remark" type="textarea" placeholder="备注" :rows="2" />
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
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { productApi } from '@/api/product'

const loading = ref(false)
const list = ref([])
const filterForm = ref({
  zid: '',
  sid: null,
  productName: '',
  productCode: ''
})
const pagination = reactive({
  pageNum: 1,
  pageSize: 10,
  total: 0
})

function buildParams() {
  const p = {
    pageNum: pagination.pageNum,
    pageSize: pagination.pageSize
  }
  if (filterForm.value.zid) p.zid = filterForm.value.zid
  if (filterForm.value.sid != null && filterForm.value.sid !== '') p.sid = filterForm.value.sid
  if (filterForm.value.productName) p.productName = filterForm.value.productName
  if (filterForm.value.productCode) p.productCode = filterForm.value.productCode
  return p
}

async function fetchList() {
  loading.value = true
  try {
    const res = await productApi.queryProducts(buildParams())
    list.value = res.data?.records ?? []
    pagination.total = res.data?.total ?? 0
  } catch (e) {
    list.value = []
    ElMessage.error(e.message || '加载失败')
  } finally {
    loading.value = false
  }
}

function handleSearch() {
  pagination.pageNum = 1
  fetchList()
}

function handleReset() {
  filterForm.value = { zid: '', sid: null, productName: '', productCode: '' }
  pagination.pageNum = 1
  fetchList()
}

const dialogVisible = ref(false)
const editId = ref(null)
const submitLoading = ref(false)
const formRef = ref(null)
const form = ref({
  zid: '',
  sid: null,
  productName: '',
  productCode: '',
  skuCode: '',
  platformSku: '',
  imageUrl: '',
  remark: ''
})
const rules = {
  productName: [{ required: true, message: '请输入商品名称', trigger: 'blur' }]
}

function resetForm() {
  editId.value = null
  form.value = {
    zid: '',
    sid: null,
    productName: '',
    productCode: '',
    skuCode: '',
    platformSku: '',
    imageUrl: '',
    remark: ''
  }
  formRef.value?.resetFields()
}

function openDialog(row) {
  editId.value = row ? row.id : null
  if (row) {
    form.value = {
      zid: row.zid ?? '',
      sid: row.sid ?? null,
      productName: row.productName ?? '',
      productCode: row.productCode ?? '',
      skuCode: row.skuCode ?? '',
      platformSku: row.platformSku ?? '',
      imageUrl: row.imageUrl ?? '',
      remark: row.remark ?? ''
    }
  } else {
    resetForm()
  }
  dialogVisible.value = true
}

async function handleSubmit() {
  await formRef.value?.validate().catch(() => {})
  submitLoading.value = true
  try {
    if (editId.value) {
      await productApi.updateProduct(editId.value, form.value)
      ElMessage.success('更新成功')
    } else {
      await productApi.createProduct(form.value)
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

async function handleDelete(row) {
  try {
    await ElMessageBox.confirm('确定删除该商品？', '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
    await productApi.deleteProduct(row.id)
    ElMessage.success('删除成功')
    fetchList()
  } catch (e) {
    if (e !== 'cancel') ElMessage.error(e.message || '删除失败')
  }
}

onMounted(() => {
  fetchList()
})
</script>

<style scoped>
.product-list-page { padding: 20px; }
.card-header { font-size: 18px; font-weight: bold; }
.filter-section { margin-bottom: 16px; }
.filter-form { margin: 0; }
.table-section { margin-top: 12px; }
.pagination-section { margin-top: 16px; display: flex; justify-content: flex-end; }
</style>
