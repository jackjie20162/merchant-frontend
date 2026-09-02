<template>
  <div class="hwsj-page">
    <div class="page-head">
      <div>
        <h2>积分数据统计</h2>
        <span>本店积分流入/流出、手续费与预存款统计（{{ query.date }}）</span>
      </div>
      <el-breadcrumb separator="/">
        <el-breadcrumb-item :to="{ path: '/dashboard' }">主页</el-breadcrumb-item>
        <el-breadcrumb-item>Merchant</el-breadcrumb-item>
        <el-breadcrumb-item>Dashboard</el-breadcrumb-item>
      </el-breadcrumb>
    </div>

    <el-card shadow="never" class="panel">
      <el-form :inline="true" :model="query">
        <el-form-item>
          <el-radio-group v-model="query.period">
            <el-radio-button label="day">按日</el-radio-button>
            <el-radio-button label="month">按月</el-radio-button>
          </el-radio-group>
        </el-form-item>
        <el-form-item>
          <el-date-picker
            v-model="query.date"
            :type="query.period === 'month' ? 'month' : 'date'"
            :value-format="query.period === 'month' ? 'YYYY-MM' : 'YYYY-MM-DD'"
            style="width: 180px"
          />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" :loading="loading" @click="loadAll">查询</el-button>
        </el-form-item>
      </el-form>

      <div class="stats-grid">
        <div v-for="item in statItems" :key="item.label" class="stat-card">
          <strong>{{ item.value }}</strong>
          <span>{{ item.label }}</span>
        </div>
      </div>

      <h3>积分流水明细（{{ query.date }}）</h3>
      <el-table v-loading="loading" :data="pointRows" border>
        <el-table-column prop="date" label="日期" min-width="160" />
        <el-table-column label="积分流入中台" min-width="160">
          <template #default="{ row }">{{ formatMoney(row.pointsIn) }}</template>
        </el-table-column>
        <el-table-column label="积分流出中台" min-width="160">
          <template #default="{ row }">{{ formatMoney(row.pointsOut) }}</template>
        </el-table-column>
        <el-table-column label="手续费" min-width="140">
          <template #default="{ row }">{{ formatMoney(row.fee) }}</template>
        </el-table-column>
      </el-table>

      <h3>预存款明细（{{ query.date }}，最近 50 条）</h3>
      <el-table v-loading="loading" :data="balanceRows" border>
        <el-table-column prop="time" label="时间" min-width="160" />
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
      </el-table>
    </el-card>
  </div>
</template>

<script setup>
import { computed, onMounted, reactive, ref } from 'vue'
import {
  gatewayDashboardBalanceList,
  gatewayDashboardPointList,
  gatewayDashboardStats,
} from '../api'

const today = new Date().toISOString().slice(0, 10)
const loading = ref(false)
const query = reactive({ period: 'day', date: today })
const stats = reactive({
  prepaidBalance: 0,
  pointsIn: 0,
  pointsOut: 0,
  feeTotal: 0,
  orderCount: 0,
})
const pointRows = ref([])
const balanceRows = ref([])

const statItems = computed(() => [
  { label: '预存余额（本店）', value: formatMoney(stats.prepaidBalance) },
  { label: '积分流入中台（本店→中台）', value: formatMoney(stats.pointsIn) },
  { label: '积分流出中台（中台→本店）', value: formatMoney(stats.pointsOut) },
  { label: '手续费汇总', value: formatMoney(stats.feeTotal) },
  { label: '兑换订单笔数', value: Number(stats.orderCount || 0) },
])

function body() {
  return { period: query.period, date: query.date }
}

function rows(resp) {
  const list = resp?.data || resp?.list || resp?.rows || resp || []
  return Array.isArray(list) ? list : []
}

function normalizePoint(row = {}) {
  return {
    date: row.date || row.day || row.month || '-',
    pointsIn: Number(row.pointsIn ?? row.points_in ?? row.in ?? 0),
    pointsOut: Number(row.pointsOut ?? row.points_out ?? row.out ?? 0),
    fee: Number(row.fee ?? row.fee_total ?? 0),
  }
}

function normalizeBalance(row = {}) {
  return {
    time: row.time || row.createdAt || row.created_at || '-',
    typeText: row.typeText || row.type_text || typeText(row.type),
    amount: Number(row.amount ?? row.money ?? 0),
    beforeBalance: Number(row.beforeBalance ?? row.before_balance ?? 0),
    afterBalance: Number(row.afterBalance ?? row.after_balance ?? 0),
    remark: row.remark || row.memo || '-',
  }
}

async function loadAll() {
  loading.value = true
  try {
    const [statResp, pointResp, balanceResp] = await Promise.all([
      gatewayDashboardStats(body()).catch(() => ({})),
      gatewayDashboardPointList(body()).catch(() => []),
      gatewayDashboardBalanceList({ ...body(), page_size: 50 }).catch(() => []),
    ])
    Object.assign(stats, {
      prepaidBalance: Number(statResp?.prepaidBalance ?? statResp?.prepaid_balance ?? 0),
      pointsIn: Number(statResp?.pointsIn ?? statResp?.points_in ?? 0),
      pointsOut: Number(statResp?.pointsOut ?? statResp?.points_out ?? 0),
      feeTotal: Number(statResp?.feeTotal ?? statResp?.fee_total ?? 0),
      orderCount: Number(statResp?.orderCount ?? statResp?.order_count ?? 0),
    })
    pointRows.value = rows(pointResp).map(normalizePoint)
    balanceRows.value = rows(balanceResp).map(normalizeBalance)
  } finally {
    loading.value = false
  }
}

function typeText(type) {
  return { recharge: '充值', deduct: '扣减', settle: '结算' }[type] || type || '-'
}

function formatMoney(value) {
  return Number(value || 0).toFixed(2)
}

onMounted(loadAll)
</script>

<style scoped>
.hwsj-page {
  padding: 24px 34px;
}
.page-head {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 18px;
}
.page-head h2 {
  margin: 0 0 6px;
  font-size: 24px;
  font-weight: 500;
}
.page-head span {
  color: #6b7280;
}
.panel {
  border: none;
}
.stats-grid {
  display: grid;
  grid-template-columns: repeat(5, minmax(0, 1fr));
  gap: 12px;
  margin: 12px 0 22px;
}
.stat-card {
  padding: 18px 16px;
  border: 1px solid #ebeef5;
  border-radius: 5px;
  background: #fff;
}
.stat-card strong {
  display: block;
  margin-bottom: 8px;
  font-size: 24px;
}
.stat-card span {
  color: #6b7280;
  font-size: 13px;
}
h3 {
  margin: 22px 0 10px;
  font-size: 16px;
  font-weight: 500;
}
@media (max-width: 900px) {
  .stats-grid {
    grid-template-columns: repeat(2, minmax(0, 1fr));
  }
}
</style>
