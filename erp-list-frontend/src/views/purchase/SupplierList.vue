<template>
  <div class="page supplier-list-page">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>供应商管理</span>
          <el-button type="primary" link @click="$router.push('/purchase/list')">返回采购列表</el-button>
        </div>
      </template>

      <div class="filter-section">
        <el-form :model="filterForm" inline class="filter-form">
          <el-form-item label="供应商名称">
            <el-input v-model="filterForm.supplierName" placeholder="名称" clearable style="width: 160px" />
          </el-form-item>
          <el-form-item label="供应商编码">
            <el-input v-model="filterForm.supplierCode" placeholder="编码" clearable style="width: 140px" />
          </el-form-item>
          <el-form-item label="状态">
            <el-select v-model="filterForm.status" placeholder="全部" clearable style="width: 110px">
              <el-option label="启用" :value="1" />
              <el-option label="禁用" :value="0" />
            </el-select>
          </el-form-item>
          <el-form-item>
            <el-button type="primary" :loading="loading" @click="handleSearch">查询</el-button>
            <el-button @click="handleReset">重置</el-button>
            <el-button type="primary" @click="openDialog()">新增供应商</el-button>
          </el-form-item>
        </el-form>
      </div>

      <el-table v-loading="loading" :data="list" stripe border style="width: 100%">
        <el-table-column prop="id" label="ID" width="80" />
        <el-table-column prop="supplierName" label="供应商名称" min-width="140" show-overflow-tooltip />
        <el-table-column prop="supplierCode" label="编码" width="120" show-overflow-tooltip />
        <el-table-column prop="contactName" label="联系人" width="100" />
        <el-table-column prop="contactPhone" label="电话" width="120" />
        <el-table-column prop="status" label="状态" width="80" align="center">
          <template #default="{ row }">
            <el-tag :type="row.status === 1 ? 'success' : 'info'" size="small">
              {{ row.status === 1 ? '启用' : '禁用' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="createTime" label="创建时间" min-width="170" />
        <el-table-column label="操作" width="200" fixed="right">
          <template #default="{ row }">
            <el-button type="primary" link size="small" @click="openDialog(row)">编辑</el-button>
            <el-button
              type="warning"
              link
              size="small"
              @click="toggleStatus(row)"
            >{{ row.status === 1 ? '禁用' : '启用' }}</el-button>
            <el-button type="danger" link size="small" @click="handleDelete(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>

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
      :title="editId ? '编辑供应商' : '新增供应商'"
      width="560px"
      destroy-on-close
      @close="resetForm"
    >
      <el-form ref="formRef" :model="form" :rules="rules" label-width="100px">
        <el-form-item label="名称" prop="supplierName">
          <el-input v-model="form.supplierName" placeholder="供应商名称" maxlength="100" />
        </el-form-item>
        <el-form-item label="编码" prop="supplierCode">
          <el-input v-model="form.supplierCode" placeholder="唯一编码" maxlength="50" :disabled="!!editId" />
        </el-form-item>
        <el-form-item label="联系人">
          <el-input v-model="form.contactName" placeholder="选填" />
        </el-form-item>
        <el-form-item label="电话">
          <el-input v-model="form.contactPhone" placeholder="选填" />
        </el-form-item>
        <el-form-item label="邮箱">
          <el-input v-model="form.contactEmail" placeholder="选填" />
        </el-form-item>
        <el-form-item label="地址">
          <el-input v-model="form.address" type="textarea" :rows="2" placeholder="选填" />
        </el-form-item>
        <el-form-item label="备注">
          <el-input v-model="form.remark" type="textarea" :rows="2" placeholder="选填" maxlength="500" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="submitLoading" @click="handleSubmit">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { purchaseApi } from '@/api/purchase'

const loading = ref(false)
const submitLoading = ref(false)
const list = ref([])
const dialogVisible = ref(false)
const editId = ref(null)
const formRef = ref(null)

const filterForm = ref({
  supplierName: '',
  supplierCode: '',
  status: null
})
const pagination = reactive({
  pageNum: 1,
  pageSize: 10,
  total: 0
})

const form = reactive({
  supplierName: '',
  supplierCode: '',
  contactName: '',
  contactPhone: '',
  contactEmail: '',
  address: '',
  remark: ''
})

const rules = {
  supplierName: [{ required: true, message: '请输入供应商名称', trigger: 'blur' }],
  supplierCode: [{ required: true, message: '请输入供应商编码', trigger: 'blur' }]
}

function resetForm() {
  editId.value = null
  Object.assign(form, {
    supplierName: '',
    supplierCode: '',
    contactName: '',
    contactPhone: '',
    contactEmail: '',
    address: '',
    remark: ''
  })
  formRef.value?.resetFields()
}

function openDialog(row) {
  resetForm()
  if (row) {
    editId.value = row.id
    Object.assign(form, {
      supplierName: row.supplierName ?? '',
      supplierCode: row.supplierCode ?? '',
      contactName: row.contactName ?? '',
      contactPhone: row.contactPhone ?? '',
      contactEmail: row.contactEmail ?? '',
      address: row.address ?? '',
      remark: row.remark ?? ''
    })
  }
  dialogVisible.value = true
}

async function fetchList() {
  loading.value = true
  try {
    const p = {
      pageNum: pagination.pageNum,
      pageSize: pagination.pageSize
    }
    if (filterForm.value.supplierName) p.supplierName = filterForm.value.supplierName
    if (filterForm.value.supplierCode) p.supplierCode = filterForm.value.supplierCode
    if (filterForm.value.status !== null && filterForm.value.status !== '') p.status = filterForm.value.status
    const res = await purchaseApi.querySuppliers(p)
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
  filterForm.value = { supplierName: '', supplierCode: '', status: null }
  pagination.pageNum = 1
  fetchList()
}

function handleSizeChange() {
  pagination.pageNum = 1
  fetchList()
}

async function handleSubmit() {
  if (!formRef.value) return
  await formRef.value.validate(async (valid) => {
    if (!valid) return
    submitLoading.value = true
    try {
      const payload = { ...form, status: 1 }
      if (editId.value) {
        await purchaseApi.updateSupplier(editId.value, payload)
        ElMessage.success('已更新')
      } else {
        await purchaseApi.createSupplier(payload)
        ElMessage.success('已创建')
      }
      dialogVisible.value = false
      fetchList()
    } catch (e) {
      ElMessage.error(e?.response?.data?.message || e.message || '保存失败')
    } finally {
      submitLoading.value = false
    }
  })
}

async function toggleStatus(row) {
  const next = row.status === 1 ? 0 : 1
  try {
    await purchaseApi.updateSupplierStatus(row.id, next)
    ElMessage.success(next === 1 ? '已启用' : '已禁用')
    fetchList()
  } catch (e) {
    ElMessage.error(e.message || '操作失败')
  }
}

async function handleDelete(row) {
  try {
    await ElMessageBox.confirm(`确定删除供应商「${row.supplierName}」？`, '提示', { type: 'warning' })
    await purchaseApi.deleteSupplier(row.id)
    ElMessage.success('已删除')
    fetchList()
  } catch (e) {
    if (e !== 'cancel') ElMessage.error(e.message || '删除失败')
  }
}

onMounted(fetchList)
</script>

<style scoped>
.supplier-list-page { padding: 20px; }
.card-header { display: flex; align-items: center; justify-content: space-between; font-size: 18px; font-weight: bold; }
.filter-section { margin-bottom: 16px; }
.pagination-section { margin-top: 16px; display: flex; justify-content: flex-end; }
</style>
