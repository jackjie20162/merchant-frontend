<template>
  <div class="recharge-page">
    <div class="page-head">
      <div>
        <h2>预存款充值</h2>
        <span>通过汇付扫码支付为预存款充值</span>
      </div>
      <el-breadcrumb separator="/">
        <el-breadcrumb-item :to="{ path: '/dashboard' }">主页</el-breadcrumb-item>
        <el-breadcrumb-item>Merchant</el-breadcrumb-item>
        <el-breadcrumb-item>Recharge</el-breadcrumb-item>
      </el-breadcrumb>
    </div>

    <el-card shadow="never" class="recharge-card">
      <template #header>
        <span>预存款充值（汇付扫码支付）</span>
      </template>

      <el-form :inline="true" :model="form" class="recharge-form">
        <el-form-item label="充值金额（元）">
          <el-input-number
            v-model="form.amount"
            :min="0.01"
            :precision="2"
            :step="10"
            controls-position="right"
            style="width: 200px"
          />
        </el-form-item>
        <el-form-item label="支付渠道">
          <el-select v-model="form.payChannel" style="width: 140px">
            <el-option label="支付宝" value="alipay" />
            <el-option label="微信支付" value="wechat" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" :loading="creating" @click="createRecharge">
            生成支付二维码
          </el-button>
        </el-form-item>
      </el-form>

      <div v-if="payOrder" class="pay-panel">
        <div class="qr-box">
          <img v-if="payOrder.qrCodeUrl" :src="payOrder.qrCodeUrl" alt="支付二维码" />
          <div v-else class="mock-qr" aria-label="支付二维码预览">
            <span
              v-for="cell in qrCells"
              :key="cell.index"
              :class="{ dark: cell.dark }"
            />
          </div>
        </div>

        <div class="pay-info">
          <div>充值金额：￥{{ formatAmount(payOrder.amount) }}</div>
          <div>请使用{{ channelName(payOrder.payChannel) }}扫码支付</div>
        </div>

        <div v-if="payOrder.payUrl" class="pay-link">
          <el-input :model-value="payOrder.payUrl" readonly />
          <el-button @click="copyPayUrl">复制链接</el-button>
        </div>

        <el-alert
          :title="statusText"
          :type="statusType"
          show-icon
          :closable="false"
          class="status-alert"
        />

        <div class="hint">
          支付成功后预存款将自动到账，可在资金流水查看。
        </div>
      </div>

      <el-empty
        v-else
        description="输入充值金额后生成支付二维码"
        :image-size="120"
        class="empty"
      />
    </el-card>
  </div>
</template>

<script setup>
import { computed, onBeforeUnmount, reactive, ref } from 'vue'
import { ElMessage } from 'element-plus'
import { gatewayRechargeCreate, gatewayRechargeStatus } from '../api'

const creating = ref(false)
const payOrder = ref(null)
const payStatus = ref('created')
const pollTimer = ref(null)

const form = reactive({
  amount: 10,
  payChannel: 'alipay',
})

const statusText = computed(() => {
  const textMap = {
    created: '待支付，请完成扫码付款',
    paying: '支付处理中，请稍候',
    success: '充值成功，预存款已到账',
    failed: '支付失败，请重新生成二维码',
    expired: '二维码已过期，请重新生成',
  }
  return textMap[payStatus.value] || payStatus.value || '待支付，请完成扫码付款'
})

const statusType = computed(() => {
  if (payStatus.value === 'success') return 'success'
  if (['failed', 'expired'].includes(payStatus.value)) return 'error'
  return 'info'
})

const qrCells = computed(() => buildQrPreview(payOrder.value?.qrContent || payOrder.value?.payUrl || ''))

function normalizeOrder(data = {}) {
  const amount = Number(data.amount ?? data.money ?? form.amount)
  const payChannel = data.payChannel || data.pay_channel || form.payChannel
  const payUrl = data.payUrl || data.pay_url || data.codeUrl || data.code_url || data.qrContent || ''
  return {
    orderNo: data.orderNo || data.order_no || data.rechargeNo || data.recharge_no || data.payNo || '',
    amount,
    payChannel,
    payUrl,
    qrContent: data.qrContent || data.qr_content || payUrl,
    qrCodeUrl: data.qrCodeUrl || data.qr_code_url || data.qrcode || data.qrCode || '',
  }
}

async function createRecharge() {
  if (!form.amount || Number(form.amount) <= 0) {
    ElMessage.warning('请输入充值金额')
    return
  }

  stopPolling()
  creating.value = true
  try {
    const data = await gatewayRechargeCreate({
      amount: Number(form.amount),
      payChannel: form.payChannel,
    })
    payOrder.value = normalizeOrder(data)
    payStatus.value = data?.status || 'created'
    startPolling()
  } catch (e) {
    payOrder.value = normalizeOrder({
      orderNo: `preview-${Date.now()}`,
      amount: Number(form.amount),
      payChannel: form.payChannel,
      qrContent: `hwsj-recharge:${form.payChannel}:${Number(form.amount).toFixed(2)}:${Date.now()}`,
    })
    payStatus.value = 'created'
    ElMessage.warning('充值接口暂未联通，已生成前端预览二维码')
  } finally {
    creating.value = false
  }
}

function startPolling() {
  if (!payOrder.value?.orderNo) return
  pollTimer.value = window.setInterval(refreshStatus, 5000)
}

function stopPolling() {
  if (!pollTimer.value) return
  window.clearInterval(pollTimer.value)
  pollTimer.value = null
}

async function refreshStatus() {
  if (!payOrder.value?.orderNo) return
  try {
    const data = await gatewayRechargeStatus(payOrder.value.orderNo)
    payStatus.value = data?.status || data?.payStatus || payStatus.value
    if (['success', 'failed', 'expired'].includes(payStatus.value)) {
      stopPolling()
    }
  } catch (e) {
    stopPolling()
  }
}

async function copyPayUrl() {
  if (!payOrder.value?.payUrl) return
  try {
    await navigator.clipboard.writeText(payOrder.value.payUrl)
    ElMessage.success('复制成功')
  } catch {
    ElMessage.error('复制失败')
  }
}

function channelName(value) {
  return { alipay: '支付宝', wechat: '微信支付' }[value] || value || '-'
}

function formatAmount(value) {
  return Number(value || 0).toFixed(2)
}

function buildQrPreview(content) {
  const size = 21
  let seed = 0
  for (const char of String(content || 'hwsj-recharge')) {
    seed = (seed * 31 + char.charCodeAt(0)) >>> 0
  }

  const isFinder = (row, col, startRow, startCol) => {
    const r = row - startRow
    const c = col - startCol
    if (r < 0 || c < 0 || r > 6 || c > 6) return false
    return r === 0 || r === 6 || c === 0 || c === 6 || (r >= 2 && r <= 4 && c >= 2 && c <= 4)
  }

  return Array.from({ length: size * size }, (_, index) => {
    const row = Math.floor(index / size)
    const col = index % size
    const finder =
      isFinder(row, col, 0, 0) ||
      isFinder(row, col, 0, size - 7) ||
      isFinder(row, col, size - 7, 0)
    seed = (seed * 1664525 + 1013904223) >>> 0
    return {
      index,
      dark: finder || (seed + row * 13 + col * 17) % 5 < 2,
    }
  })
}

onBeforeUnmount(stopPolling)
</script>

<style scoped>
.recharge-page {
  padding: 24px 34px;
}

.page-head {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 22px;
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

.recharge-card {
  min-height: 460px;
  border: none;
}

.recharge-form {
  align-items: center;
}

.pay-panel {
  display: flex;
  align-items: center;
  flex-direction: column;
  margin-top: 18px;
}

.qr-box {
  width: 228px;
  height: 228px;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 10px;
  border: 1px solid #dcdfe6;
  border-radius: 4px;
  background: #fff;
}

.qr-box img {
  width: 208px;
  height: 208px;
  object-fit: contain;
}

.mock-qr {
  width: 208px;
  height: 208px;
  display: grid;
  grid-template-columns: repeat(21, 1fr);
  grid-template-rows: repeat(21, 1fr);
  background: #fff;
}

.mock-qr span {
  background: #fff;
}

.mock-qr span.dark {
  background: #111;
}

.pay-info {
  margin-top: 14px;
  color: #3155b7;
  line-height: 1.8;
  text-align: center;
  font-size: 14px;
}

.pay-link {
  display: flex;
  width: min(520px, 100%);
  gap: 8px;
  margin-top: 12px;
}

.status-alert {
  width: min(520px, 100%);
  margin-top: 14px;
}

.hint {
  margin-top: 14px;
  color: #9ca3af;
  font-size: 14px;
}

.empty {
  margin-top: 44px;
}

@media (max-width: 768px) {
  .recharge-page {
    padding: 16px;
  }

  .page-head {
    align-items: flex-start;
    flex-direction: column;
    gap: 12px;
  }

  .pay-link {
    flex-direction: column;
  }
}
</style>
