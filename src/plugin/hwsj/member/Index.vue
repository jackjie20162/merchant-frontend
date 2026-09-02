<template>
  <div class="page">
    <!-- 筛选栏 -->
    <el-card v-loading="loading" shadow="never" class="filter-card">
      <el-form :inline="true" :model="filters" class="filter-form">
        <el-form-item label="手机号">
          <el-input
            v-model="filters.mobile"
            placeholder="请输入手机号"
            clearable
            style="width: 200px"
            @keyup.enter="handleSearch"
          />
        </el-form-item>
        <el-form-item label="状态">
          <el-select v-model="filters.status" placeholder="请选择状态" clearable style="width: 150px">
            <el-option label="全部" value="" />
            <el-option label="正常" value="normal" />
            <el-option label="禁用" value="disabled" />
            <el-option label="冻结" value="frozen" />
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
          <span class="title">Member 列表</span>
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
        <el-table-column label="会员 ID" prop="id" width="120" sortable min-width="80" align="center" />
        <el-table-column label="手机号" prop="mobile" min-width="140" show-overflow-tooltip />
        <el-table-column label="昵称" prop="nickname" min-width="120" show-overflow-tooltip />
        <el-table-column label="本店积分" prop="pointsInStore" width="120" align="right">
          <template #default="{ row }">
            <span class="points">{{ row.pointsInStore }}</span>
          </template>
        </el-table-column>
        <el-table-column label="中台可用积分" prop="pointsAvailableInPlatform" width="130" align="right">
          <template #default="{ row }">
            <span class="points available">{{ row.pointsAvailableInPlatform }}</span>
          </template>
        </el-table-column>
        <el-table-column label="中台总积分" prop="pointsTotalInPlatform" width="130" align="right">
          <template #default="{ row }">
            <span class="points total">{{ row.pointsTotalInPlatform }}</span>
          </template>
        </el-table-column>
        <el-table-column label="状态" prop="status" width="100" align="center">
          <template #default="{ row }">
            <el-tag :type="getStatusType(row.status)" size="small">{{ row.status }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="创建时间" prop="createdAt" min-width="180" show-overflow-tooltip />
        <el-table-column label="操作" width="150" fixed="right" align="center">
          <template #default="{ row }">
            <el-button link type="primary" size="small" @click="handleViewDetail(row)">查看详情</el-button>
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

    <!-- 详情弹窗 -->
    <el-dialog
      v-model="detailVisible"
      title="会员详情"
      width="600px"
      destroy-on-close
    >
      <el-descriptions v-if="currentMember" :column="2" border>
        <el-descriptions-item label="会员 ID">{{ currentMember.id }}</el-descriptions-item>
        <el-descriptions-item label="手机号">{{ currentMember.mobile }}</el-descriptions-item>
        <el-descriptions-item label="昵称">{{ currentMember.nickname }}</el-descriptions-item>
        <el-descriptions-item label="状态">
          <el-tag :type="getStatusType(currentMember.status)">{{ currentMember.status }}</el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="本店积分">{{ currentMember.pointsInStore }}</el-descriptions-item>
        <el-descriptions-item label="中台可用积分">{{ currentMember.pointsAvailableInPlatform }}</el-descriptions-item>
        <el-descriptions-item label="中台总积分">{{ currentMember.pointsTotalInPlatform }}</el-descriptions-item>
        <el-descriptions-item label="创建时间" :span="2">{{ currentMember.createdAt }}</el-descriptions-item>
      </el-descriptions>
      <template #footer>
        <el-button @click="detailVisible = false">关闭</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Search, Refresh } from '@element-plus/icons-vue'
import { gatewayMemberDelete, gatewayMemberDetail, gatewayMemberList } from '../api'

// 加载状态
const loading = ref(false)
const tableLoading = ref(false)

// 筛选条件
const filters = reactive({
  mobile: '',
  status: '',
  keyword: '',
})

// 表格数据
const tableData = ref([])

// 分页
const currentPage = ref(1)
const pageSize = ref(10)
const total = ref(0)

// 详情弹窗
const detailVisible = ref(false)
const currentMember = ref(null)

// 获取状态样式
function getStatusType(status) {
  const types = {
    '正常': 'success',
    '禁用': 'danger',
    '冻结': 'warning',
    '注销': 'info',
  }
  return types[status] || ''
}

// 获取列表
async function fetchList() {
  tableLoading.value = true
  try {
    const resp = await gatewayMemberList({
      page: currentPage.value,
      page_size: pageSize.value,
      mobile: filters.mobile,
      status: filters.status,
    })
    const rows = resp?.data || resp?.list || resp?.rows || []
    tableData.value = rows.map(normalizeMember)
    total.value = Number(resp?.total || resp?.count || 0)
  } catch (e) {
    tableData.value = []
    total.value = 0
  } finally {
    tableLoading.value = false
  }
}

function normalizeMember(row = {}) {
  return {
    id: row.id,
    mobile: row.mobile || '-',
    nickname: row.nickname || row.name || '',
    pointsInStore: Number(row.pointsInStore ?? row.points_in_store ?? row.store_points ?? 0).toFixed(2),
    pointsAvailableInPlatform: Number(row.pointsAvailableInPlatform ?? row.points_available_in_platform ?? row.available_points ?? 0).toFixed(2),
    pointsTotalInPlatform: Number(row.pointsTotalInPlatform ?? row.points_total_in_platform ?? row.total_points ?? 0).toFixed(2),
    status: statusText(row.status),
    createdAt: row.createdAt || row.created_at || '-',
  }
}

function statusText(status) {
  return {
    normal: '正常',
    disabled: '禁用',
    frozen: '冻结',
    canceled: '注销',
  }[status] || status || '-'
}

// 搜索
function handleSearch() {
  currentPage.value = 1
  fetchList()
}

// 重置
function handleReset() {
  Object.assign(filters, {
    mobile: '',
    status: '',
    keyword: '',
  })
  currentPage.value = 1
  fetchList()
}

// 查看详情
async function handleViewDetail(row) {
  try {
    currentMember.value = normalizeMember(await gatewayMemberDetail(row.id))
    detailVisible.value = true
  } catch (e) {
    ElMessage.error(e.message || '获取详情失败')
  }
}

async function handleDelete(row) {
  try {
    await ElMessageBox.confirm('确定删除该会员吗？', '提示', { type: 'warning' })
    await gatewayMemberDelete([row.id])
    ElMessage.success('已删除')
    fetchList()
  } catch (e) {
    if (e?.message) ElMessage.error(e.message)
  }
}

onMounted(() => {
  fetchList()
})
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

.points {
  font-weight: 600;
  font-family: 'Courier New', monospace;
}

.points.available {
  color: #67c23a;
}

.points.total {
  color: #409eff;
}

.pagination-container {
  margin-top: 16px;
  display: flex;
  justify-content: flex-end;
}
</style>
