<template>
  <div class="page">
    <!-- 筛选栏 -->
    <el-card v-loading="loading" shadow="never" class="filter-card">
      <el-form :inline="true" :model="filters" class="filter-form">
        <el-form-item label="API Key 名称">
          <el-input
            v-model="filters.name"
            placeholder="请输入 API Key 名称"
            clearable
            style="width: 200px"
            @keyup.enter="handleSearch"
          />
        </el-form-item>
        <el-form-item label="状态">
          <el-select v-model="filters.status" placeholder="请选择状态" clearable style="width: 150px">
            <el-option label="全部" value="" />
            <el-option label="启用" value="1" />
            <el-option label="禁用" value="0" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch">
            <el-icon><Search /></el-icon>
            查询
          </el-button>
          <el-button @click="handleReset">
            <el-icon><Refresh /></el-icon>
            重置
          </el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <!-- 列表表格 -->
    <el-card shadow="never">
      <template #header>
        <div class="card-header">
          <span class="title">API Key 列表</span>
          <el-button type="primary" @click="handleCreate">
            <el-icon><Plus /></el-icon>
            新增 API Key
          </el-button>
        </div>
      </template>

      <el-table
        :data="tableData"
        border
        stripe
        v-loading="tableLoading"
        style="width: 100%"
      >
        <el-table-column type="selection" width="55" />
        <el-table-column label="ID" prop="id" width="120" sortable min-width="80" align="center" />
        <el-table-column label="API Key 名称" prop="name" min-width="180" show-overflow-tooltip />
        <el-table-column label="API Key 值" prop="key" min-width="320" show-overflow-tooltip>
          <template #default="{ row }">
            <span class="api-key-value">{{ row.key }}</span>
            <el-tooltip placement="top">
              <template #content>复制成功</template>
              <el-button link type="primary" size="small" @click="copyToClipboard(row.key)">
                <el-icon><CopyDocument /></el-icon>
              </el-button>
            </el-tooltip>
          </template>
        </el-table-column>
        <el-table-column label="状态" prop="status" width="100" align="center">
          <template #default="{ row }">
            <el-tag :type="row.status === '1' ? 'success' : 'danger'" size="small">
              {{ row.status === '1' ? '启用' : '禁用' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="有效期" prop="expire_days" width="120" align="center">
          <template #default="{ row }">
            <span v-if="row.expire_days">{{ row.expire_days }}天</span>
            <span v-else class="permanent">永久</span>
          </template>
        </el-table-column>
        <el-table-column label="调用次数" prop="call_count" width="120" align="center" />
        <el-table-column label="创建时间" prop="created_at" min-width="180" show-overflow-tooltip />
        <el-table-column label="操作" fixed="right" width="200" align="center">
          <template #default="{ row }">
            <el-button link type="primary" size="small" @click="handleEdit(row)">编辑</el-button>
            <el-button link type="warning" size="small" @click="handleResetKey(row)">重置 Key</el-button>
            <el-button link type="danger" size="small" @click="handleDelete(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>

      <!-- 分页 -->
      <div class="pagination-container">
        <el-pagination
          v-model:current-page="currentPage"
          v-model:page-size="pageSize"
          :page-sizes="[10, 20, 50, 100]"
          :total="total"
          layout="total, sizes, prev, pager, next, jumper"
          @size-change="fetchList"
          @current-change="fetchList"
        />
      </div>
    </el-card>

    <!-- 新增/编辑弹窗 -->
    <el-dialog
      v-model="dialogVisible"
      :title="dialogTitle"
      width="600px"
      destroy-on-close
    >
      <el-form
        ref="formRef"
        :model="form"
        :rules="rules"
        label-width="120px"
        label-position="left"
      >
        <el-form-item label="API Key 名称" prop="name">
          <el-input
            v-model="form.name"
            placeholder="请输入 API Key 名称，如：下游合作方 A"
            maxlength="100"
          />
        </el-form-item>
        <el-form-item label="描述说明" prop="description">
          <el-input
            v-model="form.description"
            type="textarea"
            :rows="3"
            placeholder="可选填，用于备注说明"
            maxlength="500"
            show-word-limit
          />
        </el-form-item>
        <el-form-item label="有效期" prop="expire_days">
          <el-select v-model="form.expire_days" placeholder="请选择有效期" style="width: 100%">
            <el-option label="永久有效" :value="null" />
            <el-option label="30 天" :value="30" />
            <el-option label="90 天" :value="90" />
            <el-option label="180 天" :value="180" />
            <el-option label="365 天" :value="365" />
          </el-select>
        </el-form-item>
        <el-form-item label="状态" prop="status">
          <el-radio-group v-model="form.status">
            <el-radio value="1">启用</el-radio>
            <el-radio value="0">禁用</el-radio>
          </el-radio-group>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="submitting" @click="onSubmit">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Search, Refresh, Plus, CopyDocument } from '@element-plus/icons-vue'
import { apiKeyDelete, apiKeyList, apiKeyReset, apiKeySave } from '../api'

// 加载状态
const loading = ref(false)
const tableLoading = ref(false)

// 筛选条件
const filters = reactive({
  name: '',
  status: '',
})

// 表格数据
const tableData = ref([])

// 分页
const currentPage = ref(1)
const pageSize = ref(10)
const total = ref(0)

// 弹窗相关
const dialogVisible = ref(false)
const dialogTitle = ref('新增 API Key')
const formRef = ref(null)
const submitting = ref(false)
const form = reactive({
  id: null,
  name: '',
  description: '',
  expire_days: null,
  status: '1',
})

// 表单验证规则
const rules = {
  name: [
    { required: true, message: '请输入 API Key 名称', trigger: 'blur' },
    { min: 2, max: 100, message: '长度在 2 到 100 个字符', trigger: 'blur' },
  ],
}

// 获取列表
async function fetchList() {
  tableLoading.value = true
  try {
    const resp = await apiKeyList({
      page: currentPage.value,
      page_size: pageSize.value,
      name: filters.name,
      status: filters.status,
    })
    const rows = resp?.data || resp?.list || resp?.rows || []
    tableData.value = rows.map(normalizeKey)
    total.value = Number(resp?.total || resp?.count || 0)
  } catch (e) {
    tableData.value = []
    total.value = 0
  } finally {
    tableLoading.value = false
  }
}

function normalizeKey(row = {}) {
  return {
    id: row.id,
    name: row.name || '-',
    key: row.key || row.apiKey || row.api_key || '',
    description: row.description || '',
    expire_days: row.expire_days ?? row.expireDays ?? null,
    status: String(row.status ?? '1'),
    call_count: Number(row.call_count ?? row.callCount ?? 0),
    created_at: row.created_at || row.createdAt || '-',
  }
}

// 创建
function handleCreate() {
  dialogTitle.value = '新增 API Key'
  Object.assign(form, {
    id: null,
    name: '',
    description: '',
    expire_days: null,
    status: '1',
  })
  dialogVisible.value = true
}

// 编辑
function handleEdit(row) {
  dialogTitle.value = '编辑 API Key'
  Object.assign(form, {
    id: row.id,
    name: row.name,
    description: row.description || '',
    expire_days: row.expire_days,
    status: row.status,
  })
  dialogVisible.value = true
}

// 提交表单
async function onSubmit() {
  if (!formRef.value) return
  
  await formRef.value.validate((valid) => {
    if (valid) {
      submitting.value = true
      
      apiKeySave({ ...form }).then(() => {
        ElMessage.success('保存成功')
        dialogVisible.value = false
        fetchList()
      }).catch((e) => {
        ElMessage.error(e.message || '保存失败')
      }).finally(() => {
        submitting.value = false
      })
    }
  })
}

// 删除
function handleDelete(row) {
  ElMessageBox.confirm('确认删除该 API Key？', '提示', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning',
  }).then(() => {
    apiKeyDelete([row.id]).then(() => {
      ElMessage.success('删除成功')
      fetchList()
    }).catch((e) => ElMessage.error(e.message || '删除失败'))
  })
}

// 重置 Key
function handleResetKey(row) {
  ElMessageBox.confirm('确认重置该 API Key？重置后将生成新的 Key 值，原有的 Key 将失效！', '提示', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning',
  }).then(() => {
    apiKeyReset(row.id).then(() => {
      ElMessage.success('重置成功，请妥善保管新生成的 API Key')
      fetchList()
    }).catch((e) => ElMessage.error(e.message || '重置失败'))
  })
}

// 搜索
function handleSearch() {
  currentPage.value = 1
  fetchList()
}

// 重置
function handleReset() {
  Object.assign(filters, {
    name: '',
    status: '',
  })
  currentPage.value = 1
  fetchList()
}

// 复制到剪贴板
function copyToClipboard(text) {
  navigator.clipboard.writeText(text).then(() => {
    ElMessage.success('复制成功')
  }).catch(() => {
    ElMessage.error('复制失败')
  })
}

// 初始化
fetchList()
</script>

<style scoped>
.page {
  padding: 16px;
}

.filter-card {
  margin-bottom: 16px;
}

.filter-form {
  max-width: 800px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.title {
  font-size: 16px;
  font-weight: 600;
  color: #303133;
}

.api-key-value {
  font-family: 'Courier New', monospace;
  word-break: break-all;
  color: #409eff;
  font-size: 12px;
}

.permanent {
  color: #67c23a;
}

.pagination-container {
  margin-top: 16px;
  display: flex;
  justify-content: flex-end;
}
</style>
