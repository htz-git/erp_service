<template>
  <div class="page">
    <el-card v-loading="loading">
      <template #header>
        <div class="card-header">
          <span>公司详情 / 编辑</span>
          <el-button @click="router.push('/admin/companies')">返回列表</el-button>
        </div>
      </template>

      <el-form
        v-if="company"
        ref="formRef"
        :model="form"
        label-width="120px"
        style="max-width: 560px"
      >
        <el-form-item label="zid">
          <el-input v-model="company.id" disabled />
        </el-form-item>
        <el-form-item label="公司名称">
          <el-input v-model="form.companyName" placeholder="公司名称" clearable />
        </el-form-item>
        <el-form-item label="联系人">
          <el-input v-model="form.contactName" placeholder="联系人" clearable />
        </el-form-item>
        <el-form-item label="联系人电话">
          <el-input v-model="form.contactPhone" placeholder="电话" clearable />
        </el-form-item>
        <el-form-item label="联系人邮箱">
          <el-input v-model="form.contactEmail" placeholder="邮箱" clearable />
        </el-form-item>
        <el-form-item label="公司地址">
          <el-input v-model="form.address" type="textarea" placeholder="选填" :rows="2" />
        </el-form-item>
        <el-form-item label="状态">
          <el-select v-model="form.status" placeholder="状态" style="width: 120px">
            <el-option label="启用" :value="1" />
            <el-option label="禁用" :value="0" />
          </el-select>
        </el-form-item>
        <el-form-item label="备注">
          <el-input v-model="form.remark" type="textarea" placeholder="选填" :rows="2" />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" :loading="saving" @click="save">保存</el-button>
          <el-button @click="router.push('/admin/companies')">取消</el-button>
        </el-form-item>
      </el-form>
    </el-card>
  </div>
</template>

<script setup>
import { ref, reactive, watch, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { adminApi } from '@/api/admin'

const route = useRoute()
const router = useRouter()
const zid = route.params.zid

const loading = ref(false)
const saving = ref(false)
const company = ref(null)
const formRef = ref(null)

const form = reactive({
  companyName: '',
  contactName: '',
  contactPhone: '',
  contactEmail: '',
  address: '',
  status: 1,
  remark: ''
})

function fillForm() {
  if (!company.value) return
  form.companyName = company.value.companyName ?? ''
  form.contactName = company.value.contactName ?? ''
  form.contactPhone = company.value.contactPhone ?? ''
  form.contactEmail = company.value.contactEmail ?? ''
  form.address = company.value.address ?? ''
  form.status = company.value.status ?? 1
  form.remark = company.value.remark ?? ''
}

async function fetchDetail() {
  loading.value = true
  try {
    company.value = await adminApi.getCompany(zid)
    fillForm()
  } catch (e) {
    ElMessage.error(e.message || '加载失败')
  } finally {
    loading.value = false
  }
}

async function save() {
  saving.value = true
  try {
    await adminApi.updateCompany(zid, form)
    ElMessage.success('保存成功')
    fetchDetail()
  } catch (e) {
    ElMessage.error(e.message || '保存失败')
  } finally {
    saving.value = false
  }
}

onMounted(() => fetchDetail())
</script>

<style scoped>
.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}
</style>
