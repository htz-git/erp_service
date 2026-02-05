<template>
  <div class="page seller-create-page">
    <div class="page-header">
      <el-button type="primary" link class="back-btn" @click="goBack">
        <el-icon><ArrowLeft /></el-icon>
        返回店铺列表
      </el-button>
      <h1 class="page-title">新增店铺</h1>
      <p class="page-desc">填写店铺信息并可选上传商品，创建后可在店铺列表中继续管理。</p>
    </div>

    <el-card class="form-card" shadow="hover">
      <template #header>
        <span class="card-title">店铺基本信息</span>
      </template>
      <el-form
        ref="formRef"
        :model="form"
        :rules="rules"
        label-width="100px"
        class="create-form"
      >
        <el-row :gutter="24">
          <el-col :xs="24" :sm="24" :md="12">
            <el-form-item label="店铺名称" prop="sellerName">
              <el-input
                v-model="form.sellerName"
                placeholder="请输入店铺名称"
                clearable
                maxlength="100"
                show-word-limit
              />
            </el-form-item>
          </el-col>
          <el-col :xs="24" :sm="24" :md="12">
            <el-form-item label="平台" prop="platform">
              <el-select v-model="form.platform" placeholder="请选择平台" style="width: 100%">
                <el-option label="亚马逊" value="amazon" />
                <el-option label="eBay" value="ebay" />
                <el-option label="速卖通" value="aliexpress" />
              </el-select>
            </el-form-item>
          </el-col>
        </el-row>
        <el-row :gutter="24">
          <el-col :xs="24" :sm="24" :md="12">
            <el-form-item label="平台账号" prop="platformAccount">
              <el-input
                v-model="form.platformAccount"
                placeholder="平台登录账号，选填"
                clearable
                maxlength="120"
              />
            </el-form-item>
          </el-col>
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

    <el-card class="form-card product-card" shadow="hover">
      <template #header>
        <span class="card-title">产品上传</span>
        <span class="card-extra">可选：在此添加商品，创建店铺后将一并提交；也可创建后在商品管理中维护</span>
      </template>
      <div class="product-toolbar">
        <el-button type="primary" plain size="small" @click="addProductRow">
          <el-icon><Plus /></el-icon>
          添加一行商品
        </el-button>
      </div>
      <el-table :data="productRows" border size="small" class="product-table">
        <el-table-column type="index" label="#" width="50" align="center" />
        <el-table-column label="商品名称" min-width="140">
          <template #default="{ row }">
            <el-input v-model="row.productName" placeholder="商品名称" size="small" clearable />
          </template>
        </el-table-column>
        <el-table-column label="商品编码" width="120">
          <template #default="{ row }">
            <el-input v-model="row.productCode" placeholder="编码" size="small" clearable />
          </template>
        </el-table-column>
        <el-table-column label="SKU" width="100">
          <template #default="{ row }">
            <el-input v-model="row.skuCode" placeholder="SKU" size="small" clearable />
          </template>
        </el-table-column>
        <el-table-column label="平台SKU" width="100">
          <template #default="{ row }">
            <el-input v-model="row.platformSku" placeholder="平台SKU" size="small" clearable />
          </template>
        </el-table-column>
        <el-table-column label="图片URL" min-width="120">
          <template #default="{ row }">
            <el-input v-model="row.imageUrl" placeholder="选填" size="small" clearable />
          </template>
        </el-table-column>
        <el-table-column label="备注" width="100">
          <template #default="{ row }">
            <el-input v-model="row.remark" placeholder="备注" size="small" clearable />
          </template>
        </el-table-column>
        <el-table-column label="操作" width="70" align="center" fixed="right">
          <template #default="{ $index }">
            <el-button type="danger" link size="small" @click="removeProductRow($index)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
      <div v-if="productRows.length === 0" class="product-empty">暂无商品行，可点击「添加一行商品」</div>
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
import { ref, reactive, computed } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { ArrowLeft, Plus } from '@element-plus/icons-vue'
import { useUserStore } from '@/store/user'
import { sellerApi } from '@/api/seller'
import { productApi } from '@/api/product'

const router = useRouter()
const userStore = useUserStore()
const currentZid = computed(() => userStore.currentZid())

const formRef = ref(null)
const submitLoading = ref(false)

const form = reactive({
  sellerName: '',
  platform: '',
  platformAccount: '',
  status: 1
})

const rules = {
  sellerName: [
    { required: true, message: '请输入店铺名称', trigger: 'blur' },
    { max: 100, message: '店铺名称最多 100 个字符', trigger: 'blur' }
  ],
  platform: [{ required: true, message: '请选择平台', trigger: 'change' }],
  status: [{ required: true, message: '请选择状态', trigger: 'change' }]
}

function defaultProductRow() {
  return {
    productName: '',
    productCode: '',
    skuCode: '',
    platformSku: '',
    imageUrl: '',
    remark: ''
  }
}

const productRows = ref([])

function addProductRow() {
  productRows.value.push(defaultProductRow())
}

function removeProductRow(index) {
  productRows.value.splice(index, 1)
}

function goBack() {
  router.push('/seller/list')
}

async function handleSubmit() {
  if (!formRef.value) return
  await formRef.value.validate(async (valid) => {
    if (!valid) return
    const zid = currentZid.value
    if (zid == null || zid === '') {
      ElMessage.error('未获取到当前公司信息，无法创建店铺')
      return
    }
    submitLoading.value = true
    try {
      const sellerPayload = {
        sellerName: form.sellerName.trim(),
        platform: form.platform,
        platformAccount: form.platformAccount?.trim() || '',
        status: form.status,
        zid
      }
      const createRes = await sellerApi.createSeller(sellerPayload)
      const newSeller = createRes.data
      const newSid = newSeller?.id ?? newSeller?.sid
      const rowsToCreate = productRows.value.filter(
        (r) => (r.productName && r.productName.trim()) || (r.productCode && r.productCode.trim())
      )
      if (newSid != null && rowsToCreate.length > 0) {
        for (const row of rowsToCreate) {
          await productApi.createProduct({
            zid,
            sid: newSid,
            productName: row.productName?.trim() || '',
            productCode: row.productCode?.trim() || '',
            skuCode: row.skuCode?.trim() || '',
            platformSku: row.platformSku?.trim() || '',
            imageUrl: row.imageUrl?.trim() || '',
            remark: row.remark?.trim() || ''
          })
        }
      }
      ElMessage.success(
        '店铺创建成功' + (rowsToCreate.length ? `，已上传 ${rowsToCreate.length} 个商品` : '')
      )
      router.push('/seller/list')
    } catch (e) {
      ElMessage.error(e.message || '创建失败')
    } finally {
      submitLoading.value = false
    }
  })
}

</script>

<style scoped>
.seller-create-page {
  padding: 24px;
  max-width: 1100px;
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

.product-card .card-extra {
  margin-left: auto;
}

.create-form {
  padding: 0;
}

.product-toolbar {
  margin-bottom: 12px;
}

.product-table {
  margin-bottom: 8px;
}

.product-empty {
  font-size: 13px;
  color: var(--el-text-color-secondary);
  padding: 16px 0;
  text-align: center;
}

.form-actions {
  margin-top: 24px;
  padding-top: 16px;
  border-top: 1px solid var(--el-border-color-lighter);
  display: flex;
  gap: 12px;
}
</style>
