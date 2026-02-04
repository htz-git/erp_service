<template>
  <div class="page user-list-page">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>用户管理</span>
        </div>
      </template>

      <!-- 筛选区 -->
      <div class="filter-section">
        <el-form :model="filterForm" inline class="filter-form">
          <el-form-item label="用户名">
            <el-input v-model="filterForm.username" placeholder="用户名" clearable style="width: 140px" />
          </el-form-item>
          <el-form-item label="手机号">
            <el-input v-model="filterForm.phone" placeholder="手机号" clearable style="width: 140px" />
          </el-form-item>
          <el-form-item label="邮箱">
            <el-input v-model="filterForm.email" placeholder="邮箱" clearable style="width: 160px" />
          </el-form-item>
          <el-form-item label="状态">
            <el-select v-model="filterForm.status" placeholder="全部" clearable style="width: 100px">
              <el-option label="启用" :value="1" />
              <el-option label="禁用" :value="0" />
            </el-select>
          </el-form-item>
          <el-form-item>
            <el-button type="primary" :loading="loading" @click="handleSearch">查询</el-button>
            <el-button @click="handleReset">重置</el-button>
            <el-button type="primary" @click="handleAdd">新增用户</el-button>
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
          <el-table-column prop="username" label="用户名" width="120" />
          <el-table-column label="姓名" width="100">
            <template #default="{ row }">
              {{ row.realName || row.real_name || '-' }}
            </template>
          </el-table-column>
          <el-table-column prop="phone" label="手机号" width="120" />
          <el-table-column prop="email" label="邮箱" min-width="160" show-overflow-tooltip />
          <el-table-column prop="status" label="状态" width="80" align="center">
            <template #default="{ row }">
              <el-tag :type="row.status === 1 ? 'success' : 'info'">
                {{ row.status === 1 ? '启用' : '禁用' }}
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column prop="createTime" label="创建时间" width="170" />
          <el-table-column label="操作" width="280" fixed="right">
            <template #default="{ row }">
              <el-button type="primary" link size="small" @click="handleEdit(row)">编辑</el-button>
              <el-button type="primary" link size="small" @click="handleOpenPermission(row)">权限</el-button>
              <el-button
                v-if="row.status === 0"
                type="success"
                link
                size="small"
                @click="handleToggleStatus(row, 1)"
              >
                启用
              </el-button>
              <el-button
                v-else
                type="warning"
                link
                size="small"
                @click="handleToggleStatus(row, 0)"
              >
                禁用
              </el-button>
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

    <!-- 权限弹窗 -->
    <el-dialog
      v-model="permissionDialogVisible"
      :title="'用户权限 - ' + (currentPermissionUser?.username || '')"
      width="560px"
      destroy-on-close
      @close="closePermissionDialog"
    >
      <div v-loading="permissionLoading">
        <div class="permission-section">
          <div class="section-title">当前权限</div>
          <div v-if="userPermissions.length === 0" class="empty-tip">暂无权限，可点击下方「增加权限」添加</div>
          <div v-else class="permission-tags">
            <el-tag
              v-for="p in userPermissions"
              :key="p.id"
              class="permission-tag"
              closable
              @close="handleRemovePermission(p)"
            >
              {{ p.permissionName || p.permission_name }} ({{ p.permissionCode || p.permission_code }})
            </el-tag>
          </div>
        </div>
        <div class="permission-section">
          <div class="section-title">增加权限</div>
          <el-select
            v-model="addPermissionIds"
            multiple
            placeholder="选择要添加的权限"
            style="width: 100%"
            :loading="allPermissionsLoading"
          >
            <el-option
              v-for="p in availablePermissions"
              :key="p.id"
              :label="(p.permissionName || p.permission_name) + ' (' + (p.permissionCode || p.permission_code) + ')'"
              :value="p.id"
            />
          </el-select>
          <el-button
            type="primary"
            :loading="addPermissionLoading"
            style="margin-top: 10px"
            :disabled="!addPermissionIds || addPermissionIds.length === 0"
            @click="handleAddPermissions"
          >
            确定添加
          </el-button>
        </div>
      </div>
    </el-dialog>

    <!-- 新增/编辑弹窗 -->
    <el-dialog
      v-model="dialogVisible"
      :title="dialogTitle"
      width="500px"
      destroy-on-close
      @close="resetForm"
    >
      <el-form ref="formRef" :model="form" :rules="formRules" label-width="80px">
        <el-form-item label="用户名" prop="username">
          <el-input v-model="form.username" placeholder="用户名" :disabled="!!form.id" />
        </el-form-item>
        <el-form-item v-if="!form.id" label="密码" prop="password">
          <el-input v-model="form.password" type="password" placeholder="密码" show-password />
        </el-form-item>
        <el-form-item label="姓名" prop="realName">
          <el-input v-model="form.realName" placeholder="姓名" />
        </el-form-item>
        <el-form-item label="手机号" prop="phone">
          <el-input v-model="form.phone" placeholder="手机号" />
        </el-form-item>
        <el-form-item label="邮箱" prop="email">
          <el-input v-model="form.email" placeholder="邮箱" />
        </el-form-item>
        <el-form-item label="状态" prop="status">
          <el-select v-model="form.status" placeholder="状态" style="width: 100%">
            <el-option label="启用" :value="1" />
            <el-option label="禁用" :value="0" />
          </el-select>
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
import { ref, reactive, computed, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { userApi } from '@/api/user'

const route = useRoute()

const loading = ref(false)
const list = ref([])

// 权限弹窗
const permissionDialogVisible = ref(false)
const currentPermissionUser = ref(null)
const userPermissions = ref([])
const permissionLoading = ref(false)
const allPermissions = ref([])
const allPermissionsLoading = ref(false)
const addPermissionIds = ref([])
const addPermissionLoading = ref(false)
const availablePermissions = computed(() => {
  const haveIds = new Set((userPermissions.value || []).map((p) => p.id))
  return (allPermissions.value || []).filter((p) => !haveIds.has(p.id))
})
const filterForm = ref({
  username: '',
  phone: '',
  email: '',
  status: null
})
const pagination = reactive({
  pageNum: 1,
  pageSize: 10,
  total: 0
})

const dialogVisible = ref(false)
const dialogTitle = ref('新增用户')
const formRef = ref(null)
const submitLoading = ref(false)
const form = ref({
  id: null,
  username: '',
  password: '',
  realName: '',
  phone: '',
  email: '',
  status: 1
})
const formRules = {
  username: [{ required: true, message: '请输入用户名', trigger: 'blur' }],
  password: [
    {
      required: true,
      validator: (rule, value, cb) => {
        if (form.value.id) return cb()
        if (!value) return cb(new Error('请输入密码'))
        if (value.length < 6) return cb(new Error('密码至少6位'))
        cb()
      },
      trigger: 'blur'
    }
  ]
}

function buildParams() {
  const p = {
    pageNum: pagination.pageNum,
    pageSize: pagination.pageSize
  }
  if (filterForm.value.username) p.username = filterForm.value.username
  if (filterForm.value.phone) p.phone = filterForm.value.phone
  if (filterForm.value.email) p.email = filterForm.value.email
  if (filterForm.value.status !== null && filterForm.value.status !== '') p.status = filterForm.value.status
  return p
}

async function fetchList() {
  loading.value = true
  try {
    const res = await userApi.queryUsers(buildParams())
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
  filterForm.value = { username: '', phone: '', email: '', status: null }
  pagination.pageNum = 1
  fetchList()
}

function handleAdd() {
  dialogTitle.value = '新增用户'
  form.value = {
    id: null,
    username: '',
    password: '',
    realName: '',
    phone: '',
    email: '',
    status: 1
  }
  dialogVisible.value = true
}

function handleEdit(row) {
  dialogTitle.value = '编辑用户'
  form.value = {
    id: row.id,
    username: row.username,
    password: '',
    realName: row.realName ?? '',
    phone: row.phone ?? '',
    email: row.email ?? '',
    status: row.status ?? 1
  }
  dialogVisible.value = true
}

function resetForm() {
  formRef.value?.resetFields()
}

async function handleSubmit() {
  if (!formRef.value) return
  await formRef.value.validate(async (valid) => {
    if (!valid) return
    submitLoading.value = true
    try {
      if (form.value.id) {
        const { id, username, realName, phone, email, status } = form.value
        await userApi.updateUser(id, { username, realName, phone, email, status })
        ElMessage.success('更新成功')
      } else {
        await userApi.createUser(form.value)
        ElMessage.success('创建成功')
      }
      dialogVisible.value = false
      fetchList()
    } catch (e) {
      ElMessage.error(e.message || '操作失败')
    } finally {
      submitLoading.value = false
    }
  })
}

async function handleToggleStatus(row, status) {
  try {
    await ElMessageBox.confirm(
      status === 1 ? '确定启用该用户？' : '确定禁用该用户？',
      '提示',
      { confirmButtonText: '确定', cancelButtonText: '取消', type: 'warning' }
    )
    await userApi.updateStatus(row.id, status)
    ElMessage.success('操作成功')
    fetchList()
  } catch (e) {
    if (e !== 'cancel') ElMessage.error(e.message || '操作失败')
  }
}

async function handleDelete(row) {
  try {
    await ElMessageBox.confirm('确定删除该用户？删除后不可恢复。', '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
    await userApi.deleteUser(row.id)
    ElMessage.success('删除成功')
    fetchList()
  } catch (e) {
    if (e !== 'cancel') ElMessage.error(e.message || '删除失败')
  }
}

async function handleOpenPermission(row) {
  currentPermissionUser.value = row
  userPermissions.value = []
  addPermissionIds.value = []
  permissionDialogVisible.value = true
  permissionLoading.value = true
  allPermissionsLoading.value = true
  try {
    const [userRes, allRes] = await Promise.all([
      userApi.getUserPermissions(row.id),
      userApi.listAllPermissions()
    ])
    userPermissions.value = userRes.data ?? []
    allPermissions.value = allRes.data ?? []
  } catch (e) {
    ElMessage.error(e.message || '加载权限失败')
    permissionDialogVisible.value = false
  } finally {
    permissionLoading.value = false
    allPermissionsLoading.value = false
  }
}

function closePermissionDialog() {
  currentPermissionUser.value = null
  userPermissions.value = []
  allPermissions.value = []
  addPermissionIds.value = []
}

async function handleRemovePermission(p) {
  if (!currentPermissionUser.value) return
  try {
    await userApi.removeUserPermission(currentPermissionUser.value.id, p.id)
    ElMessage.success('已移除')
    userPermissions.value = userPermissions.value.filter((x) => x.id !== p.id)
  } catch (e) {
    ElMessage.error(e.message || '移除失败')
  }
}

async function handleAddPermissions() {
  if (!currentPermissionUser.value || !addPermissionIds.value?.length) return
  addPermissionLoading.value = true
  try {
    await userApi.addUserPermissions(currentPermissionUser.value.id, addPermissionIds.value)
    ElMessage.success('添加成功')
    const res = await userApi.getUserPermissions(currentPermissionUser.value.id)
    userPermissions.value = res.data ?? []
    addPermissionIds.value = []
  } catch (e) {
    ElMessage.error(e.message || '添加失败')
  } finally {
    addPermissionLoading.value = false
  }
}

onMounted(() => {
  fetchList()
  if (route.query.open === 'create') {
    handleAdd()
  }
})
</script>

<style scoped>
.user-list-page { padding: 20px; }
.card-header { font-size: 18px; font-weight: bold; }
.filter-section { margin-bottom: 16px; }
.filter-form { margin: 0; }
.table-section { margin-top: 12px; }
.pagination-section { margin-top: 16px; display: flex; justify-content: flex-end; }
.permission-section { margin-bottom: 16px; }
.permission-section .section-title { font-weight: bold; margin-bottom: 8px; }
.permission-section .empty-tip { color: var(--el-text-color-secondary); font-size: 13px; }
.permission-tags { display: flex; flex-wrap: wrap; gap: 8px; }
.permission-tag { margin: 0; }
</style>
