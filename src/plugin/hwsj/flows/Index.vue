<template>
  <div class="page">
    <div class="page-head">
      <div><h2>Flow 列表</h2></div>
      <el-breadcrumb separator="/">
        <el-breadcrumb-item :to="{ path: '/dashboard' }">主页</el-breadcrumb-item>
        <el-breadcrumb-item>Merchant</el-breadcrumb-item>
        <el-breadcrumb-item>Flows</el-breadcrumb-item>
      </el-breadcrumb>
    </div>

    <el-card shadow="never" class="filter-card">
      <template #header>预存款变动流水</template>
      <el-form :inline="true" :model="filters">
        <el-form-item label="类型">
          <el-select v-model="filters.type" clearable style="width: 140px">
            <el-option label="充值" value="recharge" />
            <el-option label="扣减" value="deduct" />
            <el-option label="结算" value="settle" />
          </el-select>
        </el-form-item>
        <el-form-item label="时间范围">
          <el-date-picker
            v-model="filters.dateRange"
            type="daterange"
            value-format="YYYY-MM-DD"
            range-separator="To"
            start-placeholder="开始日期"
            end-placeholder="结束日期"
          />
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
          <span>资金流水</span>
          <el-button :icon="Refresh" :loading="loading" @click="load">刷新</el-button>
        </div>
      </template>
      <el-table v-loading="loading" :data="list" border>
        <el-table-column type="selection" width="50" />
        <el-table-column prop="id" label="ID" width="90" />
        <el-table-column prop="typeText" label="类型" width="110" />
        <el-table-column label="变动金额" min-width="130">
          <template #default="{ row }">{{ formatMoney(row.amount) }}</template>
        </el-table-column>
        <el-table-column label="变动前余额" min-width="130">
          <template #default="{ row }">{{ formatMoney(row.beforeBalance) }}</template>
        </el-table-column>
        <el-table-column label="变动后余额" min-width="130">
          <template #default="{ row }">{{ formatMoney(row.afterBalance) }}</template>
        </el-table-column>
        <el-table-column prop="remark" label="备注" min-width="220" show-overflow-tooltip />
        <el-table-column prop="time" label="时间" min-width="160" />
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
import { gatewayFlowDelete, gatewayFlowList } from '../api'

const loading = ref(false)
const list = ref([])
const total = ref(0)
const page = ref(1)
const pageSize = ref(20)
const filters = reactive({ type: '', dateRange: [] })

function normalizePage(resp) {
  const rows = resp?.data || resp?.list || resp?.rows || []
  return { rows: Array.isArray(rows) ? rows : [], total: Number(resp?.total || resp?.count || 0) }
}

function normalize(row = {}) {
  return {
    id: row.id,
    typeText: row.typeText || row.type_text || typeText(row.type),
    amount: Number(row.amount ?? row.money ?? 0),
    beforeBalance: Number(row.beforeBalance ?? row.before_balance ?? 0),
    afterBalance: Number(row.afterBalance ?? row.after_balance ?? 0),
    remark: row.remark || row.memo || '-',
    time: row.time || row.createdAt || row.created_at || '-',
  }
}

async function load() {
  loading.value = true
  try {
    const data = normalizePage(await gatewayFlowList({
      page: page.value,
      page_size: pageSize.value,
      type: filters.type,
      start_date: filters.dateRange?.[0] || '',
      end_date: filters.dateRange?.[1] || '',
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
function reset() { Object.assign(filters, { type: '', dateRange: [] }); search() }

async function remove(row) {
  try {
    await ElMessageBox.confirm('确定删除该流水记录吗？', '提示', { type: 'warning' })
    await gatewayFlowDelete([row.id])
    ElMessage.success('已删除')
    load()
  } catch (e) {
    if (e?.message) ElMessage.error(e.message)
  }
}

function typeText(type) {
  return { recharge: '充值', deduct: '扣减', settle: '结算' }[type] || type || '-'
}
function formatMoney(value) {
  return Number(value || 0).toFixed(2)
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
