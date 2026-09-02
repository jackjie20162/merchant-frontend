<template>
  <div class="page">
    <div class="page-head">
      <div><h2>Reconciliation 列表</h2></div>
      <el-breadcrumb separator="/">
        <el-breadcrumb-item :to="{ path: '/dashboard' }">主页</el-breadcrumb-item>
        <el-breadcrumb-item>Merchant</el-breadcrumb-item>
        <el-breadcrumb-item>Reconciliation</el-breadcrumb-item>
      </el-breadcrumb>
    </div>

    <el-card shadow="never" class="filter-card">
      <el-form :inline="true" :model="filters">
        <el-form-item label="对账日期">
          <el-date-picker v-model="filters.date" type="date" value-format="YYYY-MM-DD" />
        </el-form-item>
        <el-form-item label="结果类型">
          <el-select v-model="filters.resultType" clearable style="width: 140px">
            <el-option label="一致" value="matched" />
            <el-option label="差异" value="diff" />
            <el-option label="已纠错" value="fixed" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="search">搜索</el-button>
          <el-button @click="reset">重置</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <el-card shadow="never">
      <template #header>
        <div class="card-header">
          <span>对账差异</span>
          <el-button :icon="Refresh" :loading="loading" @click="load">刷新</el-button>
        </div>
      </template>
      <el-table v-loading="loading" :data="list" border>
        <el-table-column type="selection" width="50" />
        <el-table-column prop="id" label="ID" width="90" />
        <el-table-column prop="reconcileDate" label="对账日期" min-width="150" />
        <el-table-column label="结果类型" width="110">
          <template #default="{ row }">
            <el-tag :type="resultType(row.resultType)" size="small">{{ resultText(row.resultType) }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="diffDetail" label="差异明细" min-width="260" show-overflow-tooltip />
        <el-table-column prop="handleNote" label="异常/纠错说明" min-width="220" show-overflow-tooltip />
        <el-table-column prop="handleTime" label="处理时间" min-width="160" />
        <el-table-column label="操作" width="90" fixed="right">
          <template #default="{ row }">
            <el-button link type="danger" @click="remove(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
      <div class="pager">
        <el-pagination
          v-model:current-page="page"
          v-model:page-size="pageSize"
          :total="total"
          :page-sizes="[10, 20, 30, 50, 100, 200]"
          layout="total, sizes, prev, pager, next"
          @size-change="load"
          @current-change="load"
        />
      </div>
    </el-card>
  </div>
</template>

<script setup>
import { onMounted, reactive, ref } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Refresh } from '@element-plus/icons-vue'
import { gatewayReconciliationDelete, gatewayReconciliationList } from '../api'

const loading = ref(false)
const list = ref([])
const total = ref(0)
const page = ref(1)
const pageSize = ref(20)
const filters = reactive({ date: '', resultType: '' })

function normalizePage(resp) {
  const rows = resp?.data || resp?.list || resp?.rows || []
  return { rows: Array.isArray(rows) ? rows : [], total: Number(resp?.total || resp?.count || 0) }
}

function normalize(row = {}) {
  return {
    id: row.id,
    reconcileDate: row.reconcileDate || row.reconcile_date || row.date || '-',
    resultType: row.resultType || row.result_type || row.type || 'diff',
    diffDetail: row.diffDetail || row.diff_detail || row.detail || '-',
    handleNote: row.handleNote || row.handle_note || row.note || '-',
    handleTime: row.handleTime || row.handle_time || row.updatedAt || row.updated_at || '-',
  }
}

async function load() {
  loading.value = true
  try {
    const data = normalizePage(await gatewayReconciliationList({
      page: page.value,
      page_size: pageSize.value,
      date: filters.date,
      result_type: filters.resultType,
    }))
    list.value = data.rows.map(normalize)
    total.value = data.total
  } catch {
    list.value = []
    total.value = 0
  } finally {
    loading.value = false
  }
}

function search() { page.value = 1; load() }
function reset() { Object.assign(filters, { date: '', resultType: '' }); search() }

async function remove(row) {
  try {
    await ElMessageBox.confirm('确定删除该对账记录吗？', '提示', { type: 'warning' })
    await gatewayReconciliationDelete([row.id])
    ElMessage.success('已删除')
    load()
  } catch (e) {
    if (e?.message) ElMessage.error(e.message)
  }
}

function resultText(type) {
  return { matched: '一致', diff: '差异', fixed: '已纠错' }[type] || type || '-'
}
function resultType(type) {
  return { matched: 'success', diff: 'danger', fixed: 'primary' }[type] || 'info'
}
onMounted(load)
</script>

<style scoped>
.page { padding: 24px 34px; }
.page-head, .card-header { display: flex; justify-content: space-between; align-items: center; }
.page-head { margin-bottom: 18px; }
.page-head h2 { margin: 0; font-size: 24px; font-weight: 500; }
.filter-card { margin-bottom: 12px; border: none; }
.pager { display: flex; justify-content: flex-end; margin-top: 12px; }
</style>
