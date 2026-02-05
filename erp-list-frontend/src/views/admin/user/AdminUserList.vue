<template>
  <div class="page">
    <el-card>
      <template #header>
        <span>全平台用户管理</span>
      </template>

      <div class="filter-section">
        <el-form :model="filterForm" inline class="filter-form">
          <el-form-item label="zid">
            <el-input v-model="filterForm.zid" placeholder="公司ID" clearable style="width: 100px" />
          </el-form-item>
          <el-form-item label="用户名">
            <el-input v-model="filterForm.username" placeholder="用户名" clearable style="width: 140px" />
          </el-form-item>
          <el-form-item label="状态">
            <el-select v-model="filterForm.status" placeholder="全部" clearable style="width: 100px">
              <el-option label="启用" :value="1" />
              <el-option label="禁用" :value="0" />
            </el-select>
          </el-form-item>
          <el-form-item>
            <el-button type="primary" :loading="loading" @click="fetchList">查询</el-button>
            <el-button @click="handleReset">重置</el-button>
          </el-form-item>
        </el-form>
      </div>

      <el-table v-loading="loading" :data="list" stripe border style="width: 100%">
        <el-table-column prop="id" label="ID" width="80" />
        <el-table-column prop="zid" label="zid" width="80" />
        <el-table-column prop="username" label="用户名" width="120" />
        <el-table-column label="姓名" width="100">
          <template #default="{ row }">
            {{ row.realName || row.real_name || '-' }}
          </template>
        </el-table-column>
        <el-table-column prop="phone" label="手机" width="120" />
        <el-table-column prop="email" label="邮箱" min-width="160" show-overflow-tooltip />
        <el-table-column prop="status" label="状态" width="80" align="center">
          <template #default="{ row }">
            <el-tag :type="row.status === 1 ? 'success' : 'info'">
              {{ row.status === 1 ? '启用' : '禁用' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="createTime" label="创建时间" width="170" />
        <el-table-column label="操作" width="200" fixed="right">
          <template #default="{ row }">
            <el-button
              v-if="row.status === 0"
              type="success"
              link
              size="small"
              @click="handleStatus(row, 1)"
            >
              启用
            </el-button>
            <el-button v-else type="warning" link size="small" @click="handleStatus(row, 0)">
              禁用
            </el-button>
            <el-button type="primary" link size="small" @click="openResetPassword(row)">
              重置密码
            </el-button>
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
          @size-change="fetchList"
          @current-change="fetchList"
        />
      </div>
    </el-card>

    <!-- 重置密码弹窗 -->
    <el-dialog
      v-model="resetDialogVisible"
      title="重置密码"
      width="400px"
      destroy-on-close
      @close="resetForm.newPassword = ''"
    >
      <el-form :model="resetForm" label-width="80px">
        <el-form-item label="用户">
          <span>{{ resetTargetUser?.username }} (ID: {{ resetTargetUser?.id }})</span>
        </el-form-item>
        <el-form-item label="新密码" required>
          <el-input
            v-model="resetForm.newPassword"
            type="password"
            placeholder="请输入新密码"
            show-password
            clearable
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="resetDialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="resetLoading" @click="confirmResetPassword">
          确定
        </el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { adminApi } from '@/api/admin'

const loading = ref(false)
const list = ref([])

const filterForm = reactive({
  zid: '',
  username: '',
  status: null
})

const pagination = reactive({
  pageNum: 1,
  pageSize: 10,
  total: 0
})

async function fetchList() {
  loading.value = true
  try {
    const params = {
      pageNum: pagination.pageNum,
      pageSize: pagination.pageSize,
      zid: filterForm.zid || undefined,
      username: filterForm.username || undefined,
      status: filterForm.status ?? undefined
    }
    const data = await adminApi.listAllUsers(params)
    list.value = data.records || []
    pagination.total = data.total || 0
  } catch (e) {
    ElMessage.error(e.message || '加载失败')
  } finally {
    loading.value = false
  }
}

function handleReset() {
  filterForm.zid = ''
  filterForm.username = ''
  filterForm.status = null
  pagination.pageNum = 1
  fetchList()
}

async function handleStatus(row, status) {
  try {
    await adminApi.updateUserStatus(row.id, status)
    ElMessage.success(status === 1 ? '已启用' : '已禁用')
    fetchList()
  } catch (e) {
    ElMessage.error(e.message || '操作失败')
  }
}

const resetDialogVisible = ref(false)
const resetTargetUser = ref(null)
const resetForm = reactive({ newPassword: '' })
const resetLoading = ref(false)

function openResetPassword(row) {
  resetTargetUser.value = row
  resetForm.newPassword = ''
  resetDialogVisible.value = true
}

async function confirmResetPassword() {
  if (!resetForm.newPassword?.trim()) {
    ElMessage.warning('请输入新密码')
    return
  }
  if (!resetTargetUser.value) return
  resetLoading.value = true
  try {
    await adminApi.resetUserPassword(resetTargetUser.value.id, resetForm.newPassword)
    ElMessage.success('密码已重置')
    resetDialogVisible.value = false
  } catch (e) {
    ElMessage.error(e.message || '重置失败')
  } finally {
    resetLoading.value = false
  }
}

onMounted(() => fetchList())
</script>

<style scoped>
.filter-section {
  margin-bottom: 16px;
}
.pagination-section {
  margin-top: 16px;
  display: flex;
  justify-content: flex-end;
}
</style>
