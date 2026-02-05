<template>
  <div class="page">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>开通公司</span>
          <el-button @click="router.push('/admin/companies')">返回列表</el-button>
        </div>
      </template>

      <el-form
        ref="formRef"
        :model="form"
        :rules="rules"
        label-width="120px"
        style="max-width: 560px"
      >
        <el-divider content-position="left">公司信息</el-divider>
        <el-form-item label="公司名称" prop="companyName">
          <el-input v-model="form.companyName" placeholder="必填" clearable />
        </el-form-item>
        <el-form-item label="联系人" prop="contactName">
          <el-input v-model="form.contactName" placeholder="选填" clearable />
        </el-form-item>
        <el-form-item label="联系人电话" prop="contactPhone">
          <el-input v-model="form.contactPhone" placeholder="选填" clearable />
        </el-form-item>
        <el-form-item label="联系人邮箱" prop="contactEmail">
          <el-input v-model="form.contactEmail" placeholder="选填" clearable />
        </el-form-item>
        <el-form-item label="公司地址" prop="address">
          <el-input v-model="form.address" type="textarea" placeholder="选填" :rows="2" />
        </el-form-item>
        <el-form-item label="备注" prop="remark">
          <el-input v-model="form.remark" type="textarea" placeholder="选填" :rows="2" />
        </el-form-item>

        <el-divider content-position="left">超管账号</el-divider>
        <el-form-item label="用户名" prop="adminUsername">
          <el-input v-model="form.adminUsername" placeholder="必填" clearable />
        </el-form-item>
        <el-form-item label="密码" prop="adminPassword">
          <el-input v-model="form.adminPassword" type="password" placeholder="必填" show-password clearable />
        </el-form-item>
        <el-form-item label="姓名" prop="adminRealName">
          <el-input v-model="form.adminRealName" placeholder="选填" clearable />
        </el-form-item>
        <el-form-item label="手机" prop="adminPhone">
          <el-input v-model="form.adminPhone" placeholder="选填" clearable />
        </el-form-item>
        <el-form-item label="邮箱" prop="adminEmail">
          <el-input v-model="form.adminEmail" placeholder="选填" clearable />
        </el-form-item>

        <el-form-item>
          <el-button type="primary" :loading="loading" @click="submit">提交开通</el-button>
          <el-button @click="router.push('/admin/companies')">取消</el-button>
        </el-form-item>
      </el-form>

      <!-- 开通成功结果 -->
      <el-card v-if="result" class="result-card" shadow="never">
        <template #header>
          <span>开通成功，请妥善保存以下信息</span>
        </template>
        <el-descriptions :column="1" border>
          <el-descriptions-item label="公司 zid">{{ result.company?.id }}</el-descriptions-item>
          <el-descriptions-item label="公司名称">{{ result.company?.companyName }}</el-descriptions-item>
          <el-descriptions-item label="超管用户名">{{ result.adminUser?.username }}</el-descriptions-item>
          <el-descriptions-item label="初始密码">
            <strong>{{ result.initialPassword }}</strong>
            <el-alert type="warning" :closable="false" show-icon style="margin-top: 8px">
              仅显示一次，请告知客户并建议尽快修改
            </el-alert>
          </el-descriptions-item>
        </el-descriptions>
      </el-card>
    </el-card>
  </div>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { adminApi } from '@/api/admin'

const router = useRouter()
const formRef = ref(null)
const loading = ref(false)
const result = ref(null)

const form = reactive({
  companyName: '',
  contactName: '',
  contactPhone: '',
  contactEmail: '',
  address: '',
  remark: '',
  adminUsername: '',
  adminPassword: '',
  adminRealName: '',
  adminPhone: '',
  adminEmail: ''
})

const rules = {
  companyName: [{ required: true, message: '请输入公司名称', trigger: 'blur' }],
  adminUsername: [{ required: true, message: '请输入超管用户名', trigger: 'blur' }],
  adminPassword: [{ required: true, message: '请输入超管密码', trigger: 'blur' }]
}

async function submit() {
  if (!formRef.value) return
  await formRef.value.validate(async (valid) => {
    if (!valid) return
    loading.value = true
    result.value = null
    try {
      const data = await adminApi.onboardCompany(form)
      result.value = data
      ElMessage.success('开通成功')
    } catch (e) {
      ElMessage.error(e.message || '开通失败')
    } finally {
      loading.value = false
    }
  })
}
</script>

<style scoped>
.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}
.result-card {
  margin-top: 24px;
  max-width: 560px;
}
</style>
