<template>
  <div class="page">
    <div class="page-head">
      <div><h2>Order 列表</h2></div>
      <el-breadcrumb separator="/">
        <el-breadcrumb-item :to="{ path: '/dashboard' }">主页</el-breadcrumb-item>
        <el-breadcrumb-item>Merchant</el-breadcrumb-item>
        <el-breadcrumb-item>Orders</el-breadcrumb-item>
      </el-breadcrumb>
    </div>

    <el-card shadow="never" class="filter-card">
      <el-form :inline="true" :model="filters">
        <el-form-item label="流水号">
          <el-input v-model="filters.flowNo" clearable style="width: 190px" @keyup.enter="search" />
        </el-form-item>
        <el-form-item label="会员ID">
          <el-input v-model="filters.memberId" clearable style="width: 140px" @keyup.enter="search" />
        </el-form-item>
        <el-form-item label="类型">
          <el-select v-model="filters.type" clearable style="width: 160px">
            <el-option label="积分转入" value="points_in" />
            <el-option label="跨商户兑换" value="exchange" />
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
          <span>订单与对账</span>
          <el-button :icon="Refresh" :loading="loading" @click="load">刷新</el-button>
        </div>
      </template>
      <el-table v-loading="loading" :data="list" border>
        <el-table-column type="selection" width="50" />
        <el-table-column prop="id" label="ID" width="90" />
        <el-table-column prop="flowNo" label="流水号" min-width="180" show-overflow-tooltip />
        <el-table-column prop="member" label="会员" min-width="150" show-overflow-tooltip />
        <el-table-column prop="typeText" label="类型" min-width="130" />
        <el-table-column label="积分数量" min-width="120">
          <template #default="{ row }">{{ formatMoney(row.points) }}</template>
        </el-table-column>
        <el-table-column label="手续费" min-width="110">
          <template #default="{ row }">{{ formatMoney(row.fee) }}</template>
        </el-table-column>
        <el-table-column label="状态" min-width="100">
          <template #default="{ row }">
            <el-tag :type="statusType(row.status)" size="small">{{ statusText(row.status) }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="createdAt" label="创建时间" min-width="170" />
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
import { gatewayOrderDelete, gatewayOrderList } from '../api'

const loading = ref(false)
const list = ref([])
const total = ref(0)
const page = ref(1)
const pageSize = ref(20)
const filters = reactive({ flowNo: '', memberId: '', type: '', dateRange: [] })

function pageBody() {
  return {
    page: page.value,
    page_size: pageSize.value,
    flow_no: filters.flowNo,
    member_id: filters.memberId,
    type: filters.type,
    start_date: filters.dateRange?.[0] || '',
    end_date: filters.dateRange?.[1] || '',
  }
}

function normalizePage(resp) {
  const rows = resp?.data || resp?.list || resp?.rows || []
  return { rows: Array.isArray(rows) ? rows : [], total: Number(resp?.total || resp?.count || 0) }
}

function normalize(row = {}) {
  return {
    id: row.id,
    flowNo: row.flowNo || row.flow_no || row.no || '-',
    member: row.member || row.memberName || row.member_id || '-',
    typeText: row.typeText || row.type_text || typeText(row.type),
    points: Number(row.points ?? row.point ?? row.amount ?? 0),
    fee: Number(row.fee ?? row.handlingFee ?? row.handling_fee ?? 0),
    status: row.status || 'created',
    createdAt: row.createdAt || row.created_at || row.time || '-',
  }
}

async function load() {
  loading.value = true
  try {
    const data = normalizePage(await gatewayOrderList(pageBody()))
    list.value = data.rows.map(normalize)
    total.value = data.total
  } catch {
    list.value = []
    total.value = 0
  } finally {
    loading.value = false
  }
}

function search() {
  page.value = 1
  load()
}

function reset() {
  Object.assign(filters, { flowNo: '', memberId: '', type: '', dateRange: [] })
  search()
}

async function remove(row) {
  try {
    await ElMessageBox.confirm('确定删除该订单记录吗？', '提示', { type: 'warning' })
    await gatewayOrderDelete([row.id])
    ElMessage.success('已删除')
    load()
  } catch (e) {
    if (e?.message) ElMessage.error(e.message)
  }
}

function typeText(type) {
  return { points_in: '积分转入', exchange: '跨商户兑换' }[type] || type || '-'
}
function statusText(status) {
  return { created: '已创建', success: '成功', failed: '失败', pending: '待处理' }[status] || status || '-'
}
function statusType(status) {
  return { success: 'success', failed: 'danger', pending: 'warning', created: 'info' }[status] || 'info'
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
