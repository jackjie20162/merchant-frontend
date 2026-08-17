<template>
  <div class="page">
    <!-- 财务汇总 -->
    <div class="summary">
      <el-card shadow="never" class="summary-card">
        <div class="summary-label">收入总额（已支付）</div>
        <div class="summary-value">￥{{ formatPrice(summary.income_total) }}</div>
        <div class="summary-sub">{{ summary.income_count || 0 }} 笔订单</div>
      </el-card>
      <el-card shadow="never" class="summary-card">
        <div class="summary-label">退款总额</div>
        <div class="summary-value danger">￥{{ formatPrice(summary.refund_total) }}</div>
        <div class="summary-sub">{{ summary.refund_count || 0 }} 笔退款</div>
      </el-card>
      <el-card shadow="never" class="summary-card">
        <div class="summary-label">提现总额（含待审核）</div>
        <div class="summary-value">￥{{ formatPrice(summary.withdraw_total) }}</div>
        <div class="summary-sub">待审核 ￥{{ formatPrice(summary.withdraw_pending_total) }}</div>
      </el-card>
      <el-card shadow="never" class="summary-card">
        <div class="summary-label">可提现余额</div>
        <div class="summary-value primary">￥{{ formatPrice(summary.balance) }}</div>
        <div class="summary-sub">收入 - 退款 - 已提现</div>
      </el-card>
    </div>

    <el-card shadow="never">
      <div class="toolbar">
        <el-input
          v-model="keyword"
          placeholder="订单号"
          clearable
          style="width: 200px"
          @keyup.enter="onSearch"
        />
        <el-button type="primary" @click="onSearch">搜索</el-button>
      </div>

      <el-tabs v-model="activeTab" @tab-change="onTabChange">
        <el-tab-pane label="全部" name="" />
        <el-tab-pane label="收入" name="income" />
        <el-tab-pane label="退款支出" name="refund" />
      </el-tabs>

      <el-table v-loading="loading" :data="list">
        <el-table-column prop="pay_no" label="支付单号" min-width="170" />
        <el-table-column prop="order_no" label="订单号" min-width="170" />
        <el-table-column label="支付方式" width="90">
          <template #default="{ row }">{{ payTypeName(row.pay_type) }}</template>
        </el-table-column>
        <el-table-column label="方向" width="90">
          <template #default="{ row }">
            <el-tag v-if="row.pay_state === '1'" type="success" size="small">收入</el-tag>
            <el-tag v-else-if="row.pay_state === '2'" type="danger" size="small">退款</el-tag>
            <el-tag v-else type="info" size="small">未支付</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="订单总价" width="110">
          <template #default="{ row }">￥{{ formatPrice(row.price) }}</template>
        </el-table-column>
        <el-table-column label="实收金额" width="110">
          <template #default="{ row }">￥{{ formatPrice(row.actual_payment) }}</template>
        </el-table-column>
        <el-table-column label="退款金额" width="110">
          <template #default="{ row }">
            <span v-if="Number(row.refund_price) > 0">￥{{ formatPrice(row.refund_price) }}</span>
            <span v-else class="muted">-</span>
          </template>
        </el-table-column>
        <el-table-column label="时间" width="160">
          <template #default="{ row }">{{ formatTime(row.createtime) }}</template>
        </el-table-column>
      </el-table>

      <div class="pager">
        <el-pagination
          v-model:current-page="page"
          :page-size="pageSize"
          :total="total"
          layout="total, prev, pager, next"
          @current-change="load"
        />
      </div>
    </el-card>
  </div>
</template>

<script setup>
import { onMounted, ref } from 'vue'
import { ElMessage } from 'element-plus'
import { billList, billSummary } from '../../api/finance'
import { formatPrice, formatTime } from '../../utils/format'

const loading = ref(false)
const list = ref([])
const total = ref(0)
const page = ref(1)
const pageSize = 20
const keyword = ref('')
const activeTab = ref('')
const summary = ref({})

function payTypeName(t) {
  return { 0: '余额', 1: '微信', 2: '支付宝' }[t] || '-'
}

async function loadSummary() {
  try {
    summary.value = (await billSummary()) || {}
  } catch (e) {
    ElMessage.error(e.message)
  }
}

async function load() {
  loading.value = true
  try {
    const body = {
      page: page.value,
      page_size: pageSize,
      order_no: keyword.value || undefined,
    }
    if (activeTab.value) body.direction = activeTab.value
    const resp = await billList(body)
    list.value = resp?.data || []
    total.value = Number(resp?.total || 0)
  } catch (e) {
    ElMessage.error(e.message)
  } finally {
    loading.value = false
  }
}

function onSearch() {
  page.value = 1
  load()
}

function onTabChange() {
  page.value = 1
  load()
}

onMounted(() => {
  loadSummary()
  load()
})
</script>

<style scoped>
.page {
  padding: 16px;
}
.summary {
  display: flex;
  gap: 12px;
  margin-bottom: 12px;
}
.summary-card {
  flex: 1;
}
.summary-label {
  color: #6b7280;
  font-size: 13px;
}
.summary-value {
  margin-top: 6px;
  font-size: 20px;
  font-weight: 600;
}
.summary-value.danger {
  color: #f56c6c;
}
.summary-value.primary {
  color: #409eff;
}
.summary-sub {
  margin-top: 4px;
  color: #9ca3af;
  font-size: 12px;
}
.toolbar {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 8px;
}
.pager {
  display: flex;
  justify-content: flex-end;
  margin-top: 12px;
}
.muted {
  color: #9ca3af;
}
</style>
