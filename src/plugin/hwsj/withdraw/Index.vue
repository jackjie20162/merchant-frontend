<template>
  <div class="withdraw-page">
    <div class="page-head">
      <div>
        <h2>提现管理</h2>
      </div>
      <el-breadcrumb separator="/">
        <el-breadcrumb-item :to="{ path: '/dashboard' }">主页</el-breadcrumb-item>
        <el-breadcrumb-item>Merchant</el-breadcrumb-item>
        <el-breadcrumb-item>Withdraws</el-breadcrumb-item>
      </el-breadcrumb>
    </div>

    <el-card shadow="never" class="withdraw-card">
      <template #header>
        <span>提现管理（自动出金）</span>
      </template>

      <div class="balance-line">
        <span>可提现余额：</span>
        <el-tag type="success" size="large">￥{{ formatMoney(summary.availableBalance) }}</el-tag>
      </div>

      <div class="apply-line">
        <el-input-number
          v-model="applyAmount"
          :min="0.01"
          :precision="2"
          :step="100"
          controls-position="right"
          placeholder="提现金额"
          style="width: 210px"
        />
        <el-button type="primary" :loading="applying" @click="applyWithdraw">
          申请提现
        </el-button>
      </div>

      <el-divider />

      <div class="section-head">
        <h3>提现记录</h3>
        <el-button :icon="Refresh" :loading="loading" @click="loadAll">刷新</el-button>
      </div>

      <el-table v-loading="loading" :data="list" border>
        <el-table-column label="金额" width="140">
          <template #default="{ row }">￥{{ formatMoney(row.amount) }}</template>
        </el-table-column>
        <el-table-column label="状态" width="120">
          <template #default="{ row }">
            <el-tag :type="statusType(row.status)" size="small">{{ statusText(row.status) }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="flowNo" label="流水号" min-width="180" show-overflow-tooltip />
        <el-table-column prop="time" label="时间" min-width="160" />
        <el-table-column label="操作" width="120" fixed="right">
          <template #default="{ row }">
            <el-button
              v-if="canCancel(row.status)"
              link
              type="danger"
              @click="cancelWithdraw(row)"
            >
              撤销
            </el-button>
            <span v-else class="muted">-</span>
          </template>
        </el-table-column>
      </el-table>

      <div class="pager">
        <el-pagination
          v-model:current-page="page"
          v-model:page-size="pageSize"
          :total="total"
          :page-sizes="[10, 20, 50]"
          layout="total, sizes, prev, pager, next"
          @size-change="loadList"
          @current-change="loadList"
        />
      </div>
    </el-card>
  </div>
</template>

<script setup>
import { onMounted, reactive, ref } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Refresh } from '@element-plus/icons-vue'
import {
  gatewayWithdrawApply,
  gatewayWithdrawCancel,
  gatewayWithdrawList,
  gatewayWithdrawSummary,
} from '../api'

const summary = reactive({
  availableBalance: 0,
})

const loading = ref(false)
const applying = ref(false)
const list = ref([])
const total = ref(0)
const page = ref(1)
const pageSize = ref(20)
const applyAmount = ref(undefined)

function normalizePage(resp) {
  const rows = resp?.data || resp?.list || resp?.rows || []
  return {
    list: Array.isArray(rows) ? rows : [],
    total: Number(resp?.total || resp?.count || 0),
  }
}

function normalizeRow(row = {}) {
  return {
    id: row.id,
    amount: Number(row.amount ?? row.money ?? 0),
    status: row.status || row.state || 'created',
    flowNo: row.flowNo || row.flow_no || row.payNo || row.pay_no || row.no || '-',
    time: row.time || row.createdAt || row.created_at || '-',
  }
}

async function loadSummary() {
  try {
    const data = await gatewayWithdrawSummary()
    summary.availableBalance = Number(
      data?.availableBalance ?? data?.available_balance ?? data?.balance ?? 0,
    )
  } catch (e) {
    summary.availableBalance = 0
  }
}

async function loadList() {
  loading.value = true
  try {
    const resp = await gatewayWithdrawList({
      page: page.value,
      page_size: pageSize.value,
    })
    const data = normalizePage(resp)
    list.value = data.list.map(normalizeRow)
    total.value = data.total
  } catch (e) {
    list.value = []
    total.value = 0
  } finally {
    loading.value = false
  }
}

async function loadAll() {
  await Promise.all([loadSummary(), loadList()])
}

async function applyWithdraw() {
  const amount = Number(applyAmount.value || 0)
  if (amount <= 0) {
    ElMessage.warning('请输入提现金额')
    return
  }
  if (amount > Number(summary.availableBalance || 0)) {
    ElMessage.warning('提现金额不能超过可提现余额')
    return
  }

  applying.value = true
  try {
    await gatewayWithdrawApply({ amount })
    ElMessage.success('提现申请已提交')
    applyAmount.value = undefined
    await loadAll()
  } catch (e) {
    ElMessage.error(e.message || '申请提现失败')
  } finally {
    applying.value = false
  }
}

async function cancelWithdraw(row) {
  try {
    await ElMessageBox.confirm('确定撤销该笔提现申请吗？', '提示', { type: 'warning' })
  } catch {
    return
  }

  try {
    await gatewayWithdrawCancel(row.id)
    ElMessage.success('已撤销')
    await loadAll()
  } catch (e) {
    ElMessage.error(e.message || '撤销失败')
  }
}

function canCancel(status) {
  return ['created', 'pending', 'processing'].includes(status)
}

function statusText(status) {
  return {
    created: '申请中',
    pending: '待处理',
    processing: '处理中',
    success: '成功',
    successed: '成功',
    failed: '失败',
    rejected: '已拒绝',
    canceled: '已撤销',
  }[status] || status || '-'
}

function statusType(status) {
  return {
    created: 'warning',
    pending: 'warning',
    processing: 'primary',
    success: 'success',
    successed: 'success',
    failed: 'danger',
    rejected: 'danger',
    canceled: 'info',
  }[status] || 'info'
}

function formatMoney(value) {
  return Number(value || 0).toFixed(2)
}

onMounted(loadAll)
</script>

<style scoped>
.withdraw-page {
  padding: 24px 34px;
}

.page-head {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 18px;
}

.page-head h2 {
  margin: 0;
  color: #111827;
  font-size: 24px;
  font-weight: 500;
}

.withdraw-card {
  border: none;
}

.balance-line {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 18px;
  font-size: 14px;
}

.apply-line {
  display: flex;
  align-items: center;
  gap: 8px;
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
  justify-content: flex-end;
  margin-top: 12px;
}

.muted {
  color: #9ca3af;
}

@media (max-width: 768px) {
  .withdraw-page {
    padding: 16px;
  }

  .page-head {
    align-items: flex-start;
    flex-direction: column;
    gap: 12px;
  }

  .apply-line {
    align-items: stretch;
    flex-direction: column;
  }
}
</style>
