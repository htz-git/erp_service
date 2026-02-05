<template>
  <div class="page user-create-page">
    <div class="page-header">
      <el-button type="primary" link class="back-btn" @click="goBack">
        <el-icon><ArrowLeft /></el-icon>
        返回用户列表
      </el-button>
      <h1 class="page-title">新增用户</h1>
      <p class="page-desc">填写基本信息并可选配置初始权限，创建后可在用户列表中继续编辑。</p>
    </div>

    <el-card class="form-card" shadow="hover">
      <template #header>
        <span class="card-title">基本信息</span>
      </template>
      <el-form
        ref="formRef"
        :model="form"
        :rules="rules"
        label-width="100px"
        class="create-form"
        @submit.prevent="handleSubmit"
      >
        <el-row :gutter="24">
          <el-col :xs="24" :sm="24" :md="12">
            <el-form-item label="用户名" prop="username">
              <el-input
                v-model="form.username"
                placeholder="登录用，2～32 个字符"
                clearable
                maxlength="32"
                show-word-limit
              />
            </el-form-item>
          </el-col>
          <el-col :xs="24" :sm="24" :md="12">
            <el-form-item label="姓名" prop="realName">
              <el-input v-model="form.realName" placeholder="真实姓名或昵称" clearable maxlength="50" show-word-limit />
            </el-form-item>
          </el-col>
        </el-row>
        <el-row :gutter="24">
          <el-col :xs="24" :sm="24" :md="12">
            <el-form-item label="密码" prop="password">
              <el-input
                v-model="form.password"
                type="password"
                placeholder="至少 6 位"
                show-password
                clearable
              />
            </el-form-item>
          </el-col>
          <el-col :xs="24" :sm="24" :md="12">
            <el-form-item label="确认密码" prop="confirmPassword">
              <el-input
                v-model="form.confirmPassword"
                type="password"
                placeholder="再次输入密码"
                show-password
                clearable
              />
            </el-form-item>
          </el-col>
        </el-row>
        <el-row :gutter="24">
          <el-col :xs="24" :sm="24" :md="12">
            <el-form-item label="手机号" prop="phone">
              <el-input v-model="form.phone" placeholder="选填" clearable maxlength="20" />
            </el-form-item>
          </el-col>
          <el-col :xs="24" :sm="24" :md="12">
            <el-form-item label="邮箱" prop="email">
              <el-input v-model="form.email" placeholder="选填" clearable maxlength="100" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-row :gutter="24">
          <el-col :xs="24" :sm="24" :md="12">
            <el-form-item label="状态" prop="status">
              <el-select v-model="form.status" placeholder="请选择" style="width: 100%">
                <el-option label="启用" :value="1" />
                <el-option label="禁用" :value="0" />
              </el-select>
            </el-form-item>
          </el-col>
        </el-row>
      </el-form>
    </el-card>

    <el-card class="form-card permission-card" shadow="hover">
      <template #header>
        <span class="card-title">初始化权限</span>
        <span class="card-extra">创建后将为该用户赋予下方选中的权限，也可在用户列表中后续修改</span>
      </template>
      <div v-loading="permissionsLoading" class="permission-area">
        <el-select
          v-model="selectedPermissionIds"
          multiple
          filterable
          placeholder="选择要赋予的权限（可多选、可搜索）"
          style="width: 100%"
          :max-collapse-tags="3"
          collapse-tags-tooltip
        >
          <el-option
            v-for="p in allPermissions"
            :key="p.id"
            :label="permissionLabel(p)"
            :value="p.id"
          />
        </el-select>
        <div v-if="selectedPermissionIds.length > 0" class="selected-summary">
          已选 <strong>{{ selectedPermissionIds.length }}</strong> 项权限
        </div>
      </div>
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
import { ref, reactive, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { ArrowLeft } from '@element-plus/icons-vue'
import { userApi } from '@/api/user'

const router = useRouter()
const formRef = ref(null)
const submitLoading = ref(false)
const permissionsLoading = ref(false)
const allPermissions = ref([])
const selectedPermissionIds = ref([])

const form = reactive({
  username: '',
  password: '',
  confirmPassword: '',
  realName: '',
  phone: '',
  email: '',
  status: 1
})

function permissionLabel(p) {
  const name = p.permissionName || p.permission_name || ''
  const code = p.permissionCode || p.permission_code || ''
  return code ? `${name} (${code})` : name || `权限 #${p.id}`
}

const phoneValidator = (rule, value, callback) => {
  if (!value || !String(value).trim()) return callback()
  const trimmed = String(value).trim()
  if (/^1\d{10}$/.test(trimmed)) return callback()
  if (/^[\d\s\-+]{7,20}$/.test(trimmed)) return callback()
  callback(new Error('请输入正确的手机号'))
}

const emailValidator = (rule, value, callback) => {
  if (!value || !String(value).trim()) return callback()
  const emailRegex = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/
  if (emailRegex.test(String(value).trim())) return callback()
  callback(new Error('请输入正确的邮箱地址'))
}

const rules = {
  username: [
    { required: true, message: '请输入用户名', trigger: 'blur' },
    { min: 2, max: 32, message: '用户名长度为 2～32 个字符', trigger: 'blur' }
  ],
  password: [
    { required: true, message: '请输入密码', trigger: 'blur' },
    { min: 6, message: '密码至少 6 位', trigger: 'blur' }
  ],
  confirmPassword: [
    { required: true, message: '请再次输入密码', trigger: 'blur' },
    {
      validator: (rule, value, callback) => {
        if (value !== form.password) callback(new Error('两次输入的密码不一致'))
        else callback()
      },
      trigger: 'blur'
    }
  ],
  realName: [{ max: 50, message: '姓名最多 50 个字符', trigger: 'blur' }],
  phone: [{ validator: phoneValidator, trigger: 'blur' }],
  email: [{ validator: emailValidator, trigger: 'blur' }],
  status: [{ required: true, message: '请选择状态', trigger: 'change' }]
}

async function loadPermissions() {
  permissionsLoading.value = true
  try {
    const res = await userApi.listAllPermissions()
    allPermissions.value = res.data ?? []
  } catch {
    allPermissions.value = []
  } finally {
    permissionsLoading.value = false
  }
}

function goBack() {
  router.push('/user/list')
}

async function handleSubmit() {
  if (!formRef.value) return
  await formRef.value.validate(async (valid) => {
    if (!valid) return
    submitLoading.value = true
    try {
      const payload = {
        username: form.username.trim(),
        password: form.password,
        realName: form.realName?.trim() || '',
        phone: form.phone?.trim() || '',
        email: form.email?.trim() || '',
        status: form.status
      }
      const createRes = await userApi.createUser(payload)
      const newUser = createRes.data
      const newUserId = newUser?.id ?? newUser?.userId
      if (newUserId != null && selectedPermissionIds.value.length > 0) {
        await userApi.addUserPermissions(newUserId, selectedPermissionIds.value)
      }
      ElMessage.success('创建成功' + (selectedPermissionIds.value.length ? '，已配置初始权限' : ''))
      router.push('/user/list')
    } catch (e) {
      ElMessage.error(e.message || '创建失败')
    } finally {
      submitLoading.value = false
    }
  })
}

onMounted(() => {
  loadPermissions()
})
</script>

<style scoped>
.user-create-page {
  padding: 24px;
  max-width: 900px;
  margin: 0 auto;
}

.page-header {
  margin-bottom: 24px;
}

.back-btn {
  display: inline-flex;
  align-items: center;
  gap: 4px;
  margin-bottom: 12px;
  padding: 0;
  font-size: 14px;
}

.page-title {
  font-size: 22px;
  font-weight: 600;
  color: var(--el-text-color-primary);
  margin: 0 0 8px 0;
}

.page-desc {
  font-size: 14px;
  color: var(--el-text-color-secondary);
  margin: 0;
  line-height: 1.5;
}

.form-card {
  margin-bottom: 20px;
}

.form-card :deep(.el-card__header) {
  display: flex;
  align-items: center;
  justify-content: space-between;
  flex-wrap: wrap;
  gap: 8px;
}

.card-title {
  font-size: 16px;
  font-weight: 600;
  color: var(--el-text-color-primary);
}

.card-extra {
  font-size: 12px;
  color: var(--el-text-color-secondary);
  font-weight: normal;
}

.permission-card .card-extra {
  margin-left: auto;
}

.create-form {
  padding: 0;
}

.permission-area {
  min-height: 80px;
}

.selected-summary {
  margin-top: 12px;
  font-size: 13px;
  color: var(--el-text-color-secondary);
}

.selected-summary strong {
  color: var(--el-color-primary);
}

.form-actions {
  margin-top: 24px;
  padding-top: 16px;
  border-top: 1px solid var(--el-border-color-lighter);
  display: flex;
  gap: 12px;
}
</style>
