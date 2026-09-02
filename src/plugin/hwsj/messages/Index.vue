<template>
  <div class="messages-page">
    <div class="page-head">
      <div>
        <h2>消息提醒</h2>
        <span>交易异常 / 对账差异 / 预存款余额预警</span>
      </div>
      <el-breadcrumb separator="/">
        <el-breadcrumb-item :to="{ path: '/dashboard' }">主页</el-breadcrumb-item>
        <el-breadcrumb-item>Merchant</el-breadcrumb-item>
        <el-breadcrumb-item>Messages</el-breadcrumb-item>
      </el-breadcrumb>
    </div>

    <div class="summary-grid">
      <div class="summary-card success">
        <strong>{{ summary.tradeRiskCount }}</strong>
        <span>交易异常</span>
      </div>
      <div class="summary-card success">
        <strong>{{ summary.reconcileDiffCount }}</strong>
        <span>对账差异</span>
      </div>
      <div class="summary-card warning">
        <strong>预存款</strong>
        <span>{{ balanceWarningText }}</span>
      </div>
    </div>

    <section class="table-section">
      <div class="section-head">
        <h3>交易异常列表</h3>
        <el-button :icon="Refresh" :loading="riskLoading" @click="loadRiskList">刷新</el-button>
      </div>
      <el-table v-loading="riskLoading" :data="riskList" border>
        <el-table-column type="selection" width="50" />
        <el-table-column prop="riskNo" label="风险单号" min-width="160" show-overflow-tooltip />
        <el-table-column prop="member" label="会员" min-width="130" show-overflow-tooltip />
        <el-table-column prop="riskType" label="风险类型" min-width="130" />
        <el-table-column prop="riskDetail" label="风险详情" min-width="220" show-overflow-tooltip />
        <el-table-column label="状态" width="110" align="center">
          <template #default="{ row }">
            <el-tag :type="statusType(row.status)" size="small">{{ statusText(row.status) }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="time" label="时间" min-width="160" />
      </el-table>
      <div class="pager">
        <span>从 {{ riskList.length ? riskPageStart : 0 }} 到 {{ riskPageEnd }}，总共 {{ riskTotal }} 条</span>
        <el-pagination
          v-model:current-page="riskPage"
          v-model:page-size="riskPageSize"
          :total="riskTotal"
          :page-sizes="[10, 20, 50]"
          layout="sizes, prev, pager, next"
          @size-change="loadRiskList"
          @current-change="loadRiskList"
        />
      </div>
    </section>

    <section class="table-section">
      <div class="section-head">
        <h3>对账差异列表</h3>
        <el-button :icon="Refresh" :loading="diffLoading" @click="loadDiffList">刷新</el-button>
      </div>
      <el-table v-loading="diffLoading" :data="diffList" border>
        <el-table-column type="selection" width="50" />
        <el-table-column prop="reconcileDate" label="对账日期" min-width="160" />
        <el-table-column prop="diffDetail" label="差异明细" min-width="280" show-overflow-tooltip />
        <el-table-column prop="handleNote" label="处理说明" min-width="240" show-overflow-tooltip />
      </el-table>
      <div class="pager">
        <span>从 {{ diffList.length ? diffPageStart : 0 }} 到 {{ diffPageEnd }}，总共 {{ diffTotal }} 条</span>
        <el-pagination
          v-model:current-page="diffPage"
          v-model:page-size="diffPageSize"
          :total="diffTotal"
          :page-sizes="[10, 20, 50]"
          layout="sizes, prev, pager, next"
          @size-change="loadDiffList"
          @current-change="loadDiffList"
        />
      </div>
    </section>
  </div>
</template>

<script setup>
import { computed, onMounted, reactive, ref } from 'vue'
import { Refresh } from '@element-plus/icons-vue'
import {
  gatewayMessageDiffList,
  gatewayMessageRiskList,
  gatewayMessageSummary,
} from '../api'

const summary = reactive({
  tradeRiskCount: 0,
  reconcileDiffCount: 0,
  prepaidBalance: 0,
  prepaidThreshold: 0,
  prepaidWarning: false,
})

const riskLoading = ref(false)
const riskList = ref([])
const riskTotal = ref(0)
const riskPage = ref(1)
const riskPageSize = ref(20)

const diffLoading = ref(false)
const diffList = ref([])
const diffTotal = ref(0)
const diffPage = ref(1)
const diffPageSize = ref(20)

const balanceWarningText = computed(() => {
  if (summary.prepaidWarning) {
    return `余额低于预警线（当前余额 ${formatMoney(summary.prepaidBalance)}）`
  }
  return `未触发余额预警（当前余额 ${formatMoney(summary.prepaidBalance)}）`
})

const riskPageStart = computed(() => (riskPage.value - 1) * riskPageSize.value + 1)
const riskPageEnd = computed(() => Math.min(riskPage.value * riskPageSize.value, riskTotal.value))
const diffPageStart = computed(() => (diffPage.value - 1) * diffPageSize.value + 1)
const diffPageEnd = computed(() => Math.min(diffPage.value * diffPageSize.value, diffTotal.value))

function normalizePage(resp) {
  const list = resp?.data || resp?.list || resp?.rows || []
  return {
    list: Array.isArray(list) ? list : [],
    total: Number(resp?.total || resp?.count || 0),
  }
}

function normalizeRisk(row = {}) {
  return {
    id: row.id,
    riskNo: row.riskNo || row.risk_no || row.no || '-',
    member: row.member || row.memberName || row.member_name || row.mobile || '-',
    riskType: row.riskType || row.risk_type || row.type || '-',
    riskDetail: row.riskDetail || row.risk_detail || row.detail || row.remark || '-',
    status: row.status || 'pending',
    time: row.time || row.createdAt || row.created_at || '-',
  }
}

function normalizeDiff(row = {}) {
  return {
    id: row.id,
    reconcileDate: row.reconcileDate || row.reconcile_date || row.date || '-',
    diffDetail: row.diffDetail || row.diff_detail || row.detail || '-',
    handleNote: row.handleNote || row.handle_note || row.note || '-',
  }
}

async function loadSummary() {
  try {
    const data = await gatewayMessageSummary()
    Object.assign(summary, {
      tradeRiskCount: Number(data?.tradeRiskCount ?? data?.trade_risk_count ?? 0),
      reconcileDiffCount: Number(data?.reconcileDiffCount ?? data?.reconcile_diff_count ?? 0),
      prepaidBalance: Number(data?.prepaidBalance ?? data?.prepaid_balance ?? 0),
      prepaidThreshold: Number(data?.prepaidThreshold ?? data?.prepaid_threshold ?? 0),
      prepaidWarning: Boolean(data?.prepaidWarning ?? data?.prepaid_warning ?? false),
    })
  } catch (e) {
    Object.assign(summary, {
      tradeRiskCount: 0,
      reconcileDiffCount: 0,
      prepaidBalance: 0,
      prepaidThreshold: 0,
      prepaidWarning: false,
    })
  }
}

async function loadRiskList() {
  riskLoading.value = true
  try {
    const resp = await gatewayMessageRiskList({
      page: riskPage.value,
      page_size: riskPageSize.value,
    })
    const page = normalizePage(resp)
    riskList.value = page.list.map(normalizeRisk)
    riskTotal.value = page.total
  } catch (e) {
    riskList.value = []
    riskTotal.value = 0
  } finally {
    riskLoading.value = false
  }
}

async function loadDiffList() {
  diffLoading.value = true
  try {
    const resp = await gatewayMessageDiffList({
      page: diffPage.value,
      page_size: diffPageSize.value,
    })
    const page = normalizePage(resp)
    diffList.value = page.list.map(normalizeDiff)
    diffTotal.value = page.total
  } catch (e) {
    diffList.value = []
    diffTotal.value = 0
  } finally {
    diffLoading.value = false
  }
}

function statusText(status) {
  return {
    pending: '待处理',
    processing: '处理中',
    resolved: '已处理',
    ignored: '已忽略',
  }[status] || status || '-'
}

function statusType(status) {
  return {
    pending: 'warning',
    processing: 'primary',
    resolved: 'success',
    ignored: 'info',
  }[status] || 'info'
}

function formatMoney(value) {
  return Number(value || 0).toFixed(2)
}

onMounted(() => {
  loadSummary()
  loadRiskList()
  loadDiffList()
})
</script>

<style scoped>
.messages-page {
  padding: 24px 34px;
}

.page-head {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 18px;
}

.page-head h2 {
  margin: 0 0 6px;
  color: #111827;
  font-size: 24px;
  font-weight: 500;
}

.page-head span {
  color: #6b7280;
  font-size: 14px;
}

.summary-grid {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 16px;
  margin-bottom: 16px;
}

.summary-card {
  min-height: 78px;
  padding: 14px 16px;
  border-radius: 5px;
  color: #fff;
}

.summary-card strong {
  display: block;
  margin-bottom: 10px;
  font-size: 26px;
  line-height: 1;
}

.summary-card span {
  font-size: 14px;
}

.summary-card.success {
  background: #24b879;
}

.summary-card.warning {
  grid-column: span 1;
  background: #f2c300;
  color: #1f2937;
}

.table-section {
  margin-top: 18px;
}

.section-head {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 10px;
}

.section-head h3 {
  margin: 0;
  color: #111827;
  font-size: 16px;
  font-weight: 500;
}

.pager {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-top: 10px;
  color: #6b7280;
  font-size: 13px;
}

@media (max-width: 768px) {
  .messages-page {
    padding: 16px;
  }

  .page-head {
    align-items: flex-start;
    flex-direction: column;
    gap: 12px;
  }

  .summary-grid {
    grid-template-columns: 1fr;
  }

  .pager {
    align-items: flex-start;
    flex-direction: column;
    gap: 8px;
  }
}
</style>
