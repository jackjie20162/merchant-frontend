<template>
  <div class="page">
    <!-- 余额与提现入口 -->
    <el-card shadow="never" class="balance-card">
      <div class="balance-row">
        <div class="balance-item">
          <div class="balance-label">可提现余额</div>
          <div class="balance-value">￥{{ formatPrice(summary.balance) }}</div>
        </div>
        <div class="balance-item">
          <div class="balance-label">待审核提现</div>
          <div class="balance-value">￥{{ formatPrice(summary.withdraw_pending_total) }}</div>
        </div>
        <div class="balance-item">
          <div class="balance-label">累计提现</div>
          <div class="balance-value">￥{{ formatPrice(summary.withdraw_total) }}</div>
        </div>
        <div class="balance-op">
          <el-button type="primary" @click="openApply">申请提现</el-button>
        </div>
      </div>
    </el-card>

    <el-card shadow="never">
      <el-tabs v-model="activeTab" @tab-change="onTabChange">
        <el-tab-pane label="全部" name="" />
        <el-tab-pane label="申请中" name="created" />
        <el-tab-pane label="成功" name="successed" />
        <el-tab-pane label="已拒绝" name="rejected" />
      </el-tabs>

      <el-table v-loading="loading" :data="list">
        <el-table-column prop="id" label="ID" width="70" />
        <el-table-column label="提现金额" width="110">
          <template #default="{ row }">￥{{ formatPrice(row.money) }}</template>
        </el-table-column>
        <el-table-column label="手续费" width="90">
          <template #default="{ row }">￥{{ formatPrice(row.handingfee) }}</template>
        </el-table-column>
        <el-table-column label="税费" width="90">
          <template #default="{ row }">￥{{ formatPrice(row.taxes) }}</template>
        </el-table-column>
        <el-table-column label="实际到账" width="110">
          <template #default="{ row }">
            ￥{{ formatPrice(Number(row.money || 0) - Number(row.handingfee || 0) - Number(row.taxes || 0)) }}
          </template>
        </el-table-column>
        <el-table-column label="提现方式" width="90">
          <template #default="{ row }">{{ typeName(row.type) }}</template>
        </el-table-column>
        <el-table-column prop="account" label="提现账户" min-width="150" />
        <el-table-column prop="memo" label="备注" min-width="120" show-overflow-tooltip />
        <el-table-column label="状态" width="90">
          <template #default="{ row }">
            <el-tag v-if="row.status === 'created'" type="warning" size="small">申请中</el-tag>
            <el-tag v-else-if="row.status === 'successed'" type="success" size="small">成功</el-tag>
            <el-tag v-else-if="row.status === 'rejected'" type="danger" size="small">已拒绝</el-tag>
            <el-tag v-else type="info" size="small">{{ row.status || '-' }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="申请时间" width="160">
          <template #default="{ row }">{{ formatTime(row.createtime) }}</template>
        </el-table-column>
        <el-table-column label="操作" width="90">
          <template #default="{ row }">
            <el-button
              v-if="row.status === 'created'"
              link
              type="danger"
              @click="onCancel(row)"
            >撤销</el-button>
            <span v-else class="muted">-</span>
          </template>
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

    <!-- 申请提现弹窗 -->
    <el-dialog v-model="dialogVisible" title="申请提现" width="480px">
      <el-form :model="form" label-width="90px">
        <el-form-item label="可提现余额">
          <span class="balance-inline">￥{{ formatPrice(summary.balance) }}</span>
        </el-form-item>
        <el-form-item label="提现金额">
          <el-input-number v-model="form.money" :min="0.01" :max="Number(summary.balance || 0)" :precision="2" :step="100" />
          <span class="hint">元</span>
        </el-form-item>
        <el-form-item label="提现方式">
          <el-select v-model="form.type" style="width: 200px">
            <el-option label="支付宝" value="alipay" />
            <el-option label="微信" value="wechat" />
            <el-option label="银行卡" value="bank" />
          </el-select>
        </el-form-item>
        <el-form-item label="提现账户">
          <el-input v-model="form.account" placeholder="如：支付宝账号 / 银行卡号" maxlength="100" />
        </el-form-item>
        <el-form-item label="备注">
          <el-input v-model="form.memo" type="textarea" :rows="2" maxlength="200" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="applying" @click="onApply">提交申请</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { onMounted, ref } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { billSummary, withdrawApply, withdrawDelete, withdrawList } from '../../api/finance'
import { formatPrice, formatTime } from '../../utils/format'

const loading = ref(false)
const list = ref([])
const total = ref(0)
const page = ref(1)
const pageSize = 20
const activeTab = ref('')
const summary = ref({})

function typeName(t) {
  return { alipay: '支付宝', wechat: '微信', bank: '银行卡' }[t] || t || '-'
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
    }
    if (activeTab.value) body.status = activeTab.value
    const resp = await withdrawList(body)
    list.value = resp?.data || []
    total.value = Number(resp?.total || 0)
  } catch (e) {
    ElMessage.error(e.message)
  } finally {
    loading.value = false
  }
}

function onTabChange() {
  page.value = 1
  load()
}

// ===== 申请提现 =====
const dialogVisible = ref(false)
const applying = ref(false)
const form = ref(emptyForm())

function emptyForm() {
  return {
    money: 0,
    type: 'alipay',
    account: '',
    memo: '',
  }
}

function openApply() {
  form.value = emptyForm()
  dialogVisible.value = true
}

async function onApply() {
  if (!form.value.money || form.value.money <= 0) {
    ElMessage.warning('请输入提现金额')
    return
  }
  if (Number(form.value.money) > Number(summary.value.balance || 0)) {
    ElMessage.warning('提现金额不能超过可提现余额')
    return
  }
  if (!form.value.account?.trim()) {
    ElMessage.warning('请输入提现账户')
    return
  }
  applying.value = true
  try {
    await withdrawApply({
      money: Number(form.value.money),
      type: form.value.type,
      account: form.value.account.trim(),
      handingfee: 0,
      taxes: 0,
      memo: form.value.memo || '',
    })
    ElMessage.success('提现申请已提交')
    dialogVisible.value = false
    await Promise.all([loadSummary(), load()])
  } catch (e) {
    ElMessage.error(e.message)
  } finally {
    applying.value = false
  }
}

// ===== 撤销申请 =====
async function onCancel(row) {
  try {
    await ElMessageBox.confirm('确定撤销该笔提现申请吗？', '提示', { type: 'warning' })
  } catch {
    return
  }
  try {
    await withdrawDelete([row.id])
    ElMessage.success('已撤销')
    await Promise.all([loadSummary(), load()])
  } catch (e) {
    ElMessage.error(e.message)
  }
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
.balance-card {
  margin-bottom: 12px;
}
.balance-row {
  display: flex;
  align-items: center;
  gap: 48px;
}
.balance-label {
  color: #6b7280;
  font-size: 13px;
}
.balance-value {
  margin-top: 6px;
  font-size: 20px;
  font-weight: 600;
}
.balance-op {
  margin-left: auto;
}
.balance-inline {
  font-weight: 600;
  color: #409eff;
}
.pager {
  display: flex;
  justify-content: flex-end;
  margin-top: 12px;
}
.muted {
  color: #9ca3af;
}
.hint {
  margin-left: 8px;
  color: #9ca3af;
  font-size: 12px;
}
</style>
