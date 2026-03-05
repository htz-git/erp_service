<template>
  <div class="settings-page">
    <!-- 顶栏时区显示 -->
    <el-card class="section-card" shadow="hover">
      <template #header>
        <div class="card-header">
          <span>顶栏时区显示</span>
          <el-button type="primary" link @click="resetTimezoneDefault">恢复默认</el-button>
        </div>
      </template>
      <div class="settings-section">
        <p class="section-desc">选择在顶栏第二行显示的时区（至少保留一项）</p>
        <el-checkbox-group v-model="visibleTimezoneIds">
          <el-checkbox
            v-for="opt in TZ_OPTIONS"
            :key="opt.id"
            :label="opt.id"
            :disabled="visibleTimezoneIds.length === 1 && visibleTimezoneIds.includes(opt.id)"
          >
            {{ opt.label }}
          </el-checkbox>
        </el-checkbox-group>
      </div>
    </el-card>

    <!-- 个人资料 -->
    <el-card class="section-card" shadow="hover">
      <template #header>
        <div class="card-header">
          <span>个人资料</span>
        </div>
      </template>
      <el-form
        ref="profileFormRef"
        :model="profileForm"
        :rules="profileRules"
        label-width="90px"
        class="settings-form"
      >
        <el-form-item label="姓名" prop="realName">
          <el-input v-model="profileForm.realName" placeholder="请输入姓名" clearable maxlength="50" show-word-limit />
        </el-form-item>
        <el-form-item label="手机号" prop="phone">
          <el-input v-model="profileForm.phone" placeholder="请输入手机号" clearable maxlength="11" />
        </el-form-item>
        <el-form-item label="邮箱" prop="email">
          <el-input v-model="profileForm.email" placeholder="请输入邮箱" clearable maxlength="100" />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" :loading="profileLoading" @click="submitProfile">保存</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <!-- 修改密码 -->
    <el-card class="section-card" shadow="hover">
      <template #header>
        <div class="card-header">
          <span>修改密码</span>
        </div>
      </template>
      <el-form
        ref="passwordFormRef"
        :model="passwordForm"
        :rules="passwordRules"
        label-width="90px"
        class="settings-form"
      >
        <el-form-item label="原密码" prop="oldPassword">
          <el-input
            v-model="passwordForm.oldPassword"
            type="password"
            placeholder="请输入原密码"
            show-password
            autocomplete="off"
          />
        </el-form-item>
        <el-form-item label="新密码" prop="newPassword">
          <el-input
            v-model="passwordForm.newPassword"
            type="password"
            placeholder="请输入新密码"
            show-password
            autocomplete="off"
          />
        </el-form-item>
        <el-form-item label="确认新密码" prop="confirmPassword">
          <el-input
            v-model="passwordForm.confirmPassword"
            type="password"
            placeholder="请再次输入新密码"
            show-password
            autocomplete="off"
          />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" :loading="passwordLoading" @click="submitPassword">修改密码</el-button>
        </el-form-item>
      </el-form>
    </el-card>
  </div>
</template>

<script setup>
import { ref, reactive, watch, onMounted } from 'vue'
import { useUserStore } from '@/store/user'
import { userApi } from '@/api/user'
import { ElMessage } from 'element-plus'

const TZ_STORAGE_KEY = 'erp_timezone_visible'
const DEFAULT_TZ_IDS = ['Asia/Shanghai', 'Europe/London', 'America/New_York', 'America/Los_Angeles']

const TZ_OPTIONS = [
  { id: 'Asia/Shanghai', label: '北京' },
  { id: 'Europe/London', label: '英国' },
  { id: 'America/New_York', label: '美东' },
  { id: 'America/Los_Angeles', label: '太平洋' }
]

function getStoredTimezoneIds() {
  try {
    const s = localStorage.getItem(TZ_STORAGE_KEY)
    if (!s) return [...DEFAULT_TZ_IDS]
    const arr = JSON.parse(s)
    return Array.isArray(arr) && arr.length ? arr : [...DEFAULT_TZ_IDS]
  } catch {
    return [...DEFAULT_TZ_IDS]
  }
}

const visibleTimezoneIds = ref(getStoredTimezoneIds())

watch(
  visibleTimezoneIds,
  (val) => {
    if (!val || val.length === 0) {
      visibleTimezoneIds.value = [...DEFAULT_TZ_IDS]
      return
    }
    localStorage.setItem(TZ_STORAGE_KEY, JSON.stringify(val))
  },
  { deep: true }
)

function resetTimezoneDefault() {
  visibleTimezoneIds.value = [...DEFAULT_TZ_IDS]
  ElMessage.success('已恢复默认时区显示')
}

const userStore = useUserStore()

const profileFormRef = ref(null)
const profileForm = reactive({
  realName: '',
  phone: '',
  email: ''
})
const profileRules = {
  phone: [
    { pattern: /^$|^1[3-9]\d{9}$/, message: '手机号格式不正确', trigger: 'blur' }
  ],
  email: [
    { pattern: /^$|^[A-Za-z0-9+_.-]+@.+$/, message: '邮箱格式不正确', trigger: 'blur' }
  ]
}
const profileLoading = ref(false)

function loadProfile() {
  const user = userStore.currentUser()
  if (user) {
    profileForm.realName = user.realName || user.real_name || ''
    profileForm.phone = user.phone || ''
    profileForm.email = user.email || ''
  }
}

async function submitProfile() {
  if (!profileFormRef.value) return
  await profileFormRef.value.validate(async (valid) => {
    if (!valid) return
    const user = userStore.currentUser()
    if (!user || user.id == null) {
      ElMessage.warning('请先登录')
      return
    }
    profileLoading.value = true
    try {
      const res = await userApi.updateUser(user.id, {
        realName: profileForm.realName,
        phone: profileForm.phone,
        email: profileForm.email
      })
      if (res?.data) {
        userStore.setUser(res.data)
        ElMessage.success('保存成功')
      }
    } catch (e) {
      ElMessage.error(e?.response?.data?.message || e?.message || '保存失败')
    } finally {
      profileLoading.value = false
    }
  })
}

const passwordFormRef = ref(null)
const passwordForm = reactive({
  oldPassword: '',
  newPassword: '',
  confirmPassword: ''
})
const validateConfirm = (rule, value, callback) => {
  if (value !== passwordForm.newPassword) {
    callback(new Error('两次输入的新密码不一致'))
  } else {
    callback()
  }
}
const passwordRules = {
  oldPassword: [{ required: true, message: '请输入原密码', trigger: 'blur' }],
  newPassword: [{ required: true, message: '请输入新密码', trigger: 'blur' }],
  confirmPassword: [
    { required: true, message: '请再次输入新密码', trigger: 'blur' },
    { validator: validateConfirm, trigger: 'blur' }
  ]
}
const passwordLoading = ref(false)

async function submitPassword() {
  if (!passwordFormRef.value) return
  await passwordFormRef.value.validate(async (valid) => {
    if (!valid) return
    passwordLoading.value = true
    try {
      await userApi.changePassword({
        oldPassword: passwordForm.oldPassword,
        newPassword: passwordForm.newPassword
      })
      ElMessage.success('密码修改成功，请使用新密码重新登录')
      userStore.logout()
      window.location.href = '/login'
    } catch (e) {
      ElMessage.error(e?.response?.data?.message || e?.message || '修改失败')
    } finally {
      passwordLoading.value = false
    }
  })
}

onMounted(() => {
  loadProfile()
})
</script>

<style scoped>
.settings-page {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.section-card {
  border-radius: 8px;
}

.section-card :deep(.el-card__header) {
  padding: 14px 20px;
  border-bottom: 1px solid var(--header-border);
}

.card-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  font-size: 18px;
  font-weight: bold;
}

.settings-section {
  padding: 4px 0;
}

.section-desc {
  color: var(--text-secondary);
  font-size: 13px;
  margin-bottom: 12px;
}

.settings-section .el-checkbox-group {
  display: flex;
  flex-wrap: wrap;
  gap: 16px 24px;
}

.settings-form {
  max-width: 400px;
}
</style>
