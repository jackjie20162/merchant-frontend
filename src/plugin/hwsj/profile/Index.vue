<template>
  <div class="merchant-profile-page">
    <div class="page-head">
      <div>
        <h2>商户信息</h2>
        <span>本店基础信息与数全宝网关接口状态</span>
      </div>
      <el-breadcrumb separator="/">
        <el-breadcrumb-item :to="{ path: '/dashboard' }">主页</el-breadcrumb-item>
        <el-breadcrumb-item>Merchant</el-breadcrumb-item>
        <el-breadcrumb-item>Profile</el-breadcrumb-item>
      </el-breadcrumb>
    </div>

    <el-card v-loading="loading" shadow="never" class="detail-card">
      <template #header>
        <div class="card-header">
          <span>详细</span>
          <el-button type="primary" @click="openEdit">
            <el-icon><Edit /></el-icon>
            编辑
          </el-button>
        </div>
      </template>

      <el-form label-width="120px" label-position="right" class="detail-form">
        <el-form-item label="商户 ID">
          <el-input :model-value="displayValue(detail.merchantId)" readonly />
        </el-form-item>
        <el-form-item label="商户名称">
          <el-input :model-value="displayValue(detail.merchantName)" readonly />
        </el-form-item>
        <el-form-item label="联系人">
          <el-input :model-value="displayValue(detail.contactName)" readonly />
        </el-form-item>
        <el-form-item label="联系电话">
          <el-input :model-value="displayValue(detail.contactMobile)" readonly />
        </el-form-item>
        <el-form-item label="结算模式">
          <el-input :model-value="displayValue(detail.settlementMode)" readonly />
        </el-form-item>
        <el-form-item label="状态">
          <el-input :model-value="displayValue(detail.statusText)" readonly />
        </el-form-item>
        <el-form-item label="App Key">
          <div class="copy-line">
            <el-input :model-value="displayValue(detail.appKey)" readonly />
            <el-tooltip content="复制 App Key" placement="top">
              <el-button :disabled="!detail.appKey" @click="copyText(detail.appKey)">
                <el-icon><CopyDocument /></el-icon>
              </el-button>
            </el-tooltip>
          </div>
        </el-form-item>
        <el-form-item label="App Secret">
          <div class="copy-line">
            <el-input
              :model-value="secretVisible ? displayValue(detail.appSecret) : maskSecret(detail.appSecret)"
              readonly
            />
            <el-tooltip :content="secretVisible ? '隐藏 App Secret' : '查看 App Secret'" placement="top">
              <el-button :disabled="!detail.appSecret" @click="secretVisible = !secretVisible">
                <el-icon>
                  <View v-if="!secretVisible" />
                  <Hide v-else />
                </el-icon>
              </el-button>
            </el-tooltip>
            <el-tooltip content="复制 App Secret" placement="top">
              <el-button :disabled="!detail.appSecret" @click="copyText(detail.appSecret)">
                <el-icon><CopyDocument /></el-icon>
              </el-button>
            </el-tooltip>
          </div>
        </el-form-item>
        <el-form-item label="预存款余额">
          <el-input :model-value="formatMoney(detail.prepaidBalance)" readonly />
        </el-form-item>
        <el-form-item label="积分规则">
          <el-input :model-value="displayValue(detail.pointsRule)" readonly />
        </el-form-item>
      </el-form>
    </el-card>

    <el-dialog v-model="editVisible" title="编辑商户信息" width="560px" destroy-on-close>
      <el-form ref="formRef" :model="form" :rules="rules" label-width="110px">
        <el-form-item label="商户名称" prop="merchantName">
          <el-input v-model="form.merchantName" maxlength="80" show-word-limit />
        </el-form-item>
        <el-form-item label="联系人" prop="contactName">
          <el-input v-model="form.contactName" maxlength="40" show-word-limit />
        </el-form-item>
        <el-form-item label="联系电话" prop="contactMobile">
          <el-input v-model="form.contactMobile" maxlength="20" />
        </el-form-item>
        <el-form-item label="结算模式" prop="settlementMode">
          <el-select v-model="form.settlementMode" style="width: 100%">
            <el-option label="预存款" value="预存款" />
            <el-option label="后付费" value="后付费" />
            <el-option label="月结" value="月结" />
          </el-select>
        </el-form-item>
        <el-form-item label="状态" prop="status">
          <el-radio-group v-model="form.status">
            <el-radio value="normal">正常</el-radio>
            <el-radio value="disabled">停用</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="积分规则">
          <el-input
            v-model="form.pointsRule"
            type="textarea"
            :rows="3"
            maxlength="200"
            show-word-limit
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="editVisible = false">取消</el-button>
        <el-button type="primary" :loading="saving" @click="submitEdit">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { computed, onMounted, reactive, ref } from 'vue'
import { ElMessage } from 'element-plus'
import { CopyDocument, Edit, Hide, View } from '@element-plus/icons-vue'
import { auth } from '../../../store/auth'
import { gatewayMerchantProfile, gatewayMerchantProfileSave } from '../api'

const loading = ref(false)
const saving = ref(false)
const editVisible = ref(false)
const secretVisible = ref(false)
const formRef = ref(null)

const detail = reactive({
  merchantId: '',
  merchantName: '',
  contactName: '',
  contactMobile: '',
  settlementMode: '预存款',
  status: 'normal',
  statusText: '正常',
  appKey: '',
  appSecret: '',
  prepaidBalance: 0,
  pointsRule: '未配置（使用默认规则）',
})

const form = reactive({
  merchantName: '',
  contactName: '',
  contactMobile: '',
  settlementMode: '预存款',
  status: 'normal',
  pointsRule: '',
})

const rules = {
  merchantName: [{ required: true, message: '请输入商户名称', trigger: 'blur' }],
  contactName: [{ required: true, message: '请输入联系人', trigger: 'blur' }],
  contactMobile: [{ required: true, message: '请输入联系电话', trigger: 'blur' }],
}

const profile = computed(() => auth.profile || {})

function pick(source, keys, fallback = '') {
  for (const key of keys) {
    if (source?.[key] !== undefined && source?.[key] !== null && source?.[key] !== '') {
      return source[key]
    }
  }
  return fallback
}

function normalizeStatus(value) {
  const status = String(value || 'normal')
  if (['1', 'normal', 'enabled', 'active', '正常'].includes(status)) {
    return { status: 'normal', statusText: '正常' }
  }
  if (['0', 'disabled', 'freeze', 'frozen', '停用', '冻结'].includes(status)) {
    return { status: 'disabled', statusText: status === '冻结' || status === 'frozen' ? '冻结' : '停用' }
  }
  return { status, statusText: status }
}

function normalizeProfile(data = {}) {
  const merchant = data.merchant || profile.value.merchant || {}
  const shop = data.shop || profile.value.shop || {}
  const gateway = data.gateway || data
  const statusInfo = normalizeStatus(pick(gateway, ['status', 'merchantStatus'], merchant.status))

  return {
    merchantId: pick(gateway, ['merchantId', 'merchant_id', 'id'], merchant.id || shop.merchantId),
    merchantName: pick(
      gateway,
      ['merchantName', 'merchant_name', 'name', 'shopname'],
      shop.shopname || merchant.nickname || merchant.username,
    ),
    contactName: pick(
      gateway,
      ['contactName', 'contact_name', 'contact', 'linkman'],
      merchant.nickname || merchant.username,
    ),
    contactMobile: pick(gateway, ['contactMobile', 'contact_mobile', 'mobile', 'phone'], merchant.mobile),
    settlementMode: pick(gateway, ['settlementMode', 'settlement_mode'], '预存款'),
    status: statusInfo.status,
    statusText: statusInfo.statusText,
    appKey: pick(gateway, ['appKey', 'app_key', 'AppKey', 'ak']),
    appSecret: pick(gateway, ['appSecret', 'app_secret', 'AppSecret', 'secret']),
    prepaidBalance: Number(pick(gateway, ['prepaidBalance', 'prepaid_balance', 'balance'], 0) || 0),
    pointsRule: pick(gateway, ['pointsRule', 'points_rule', 'pointRule'], '未配置（使用默认规则）'),
  }
}

function applyDetail(data) {
  Object.assign(detail, normalizeProfile(data))
}

async function load() {
  loading.value = true
  try {
    const data = await gatewayMerchantProfile()
    applyDetail(data)
  } catch (e) {
    applyDetail({})
    console.warn('[hwsj] gateway merchant profile fallback:', e)
  } finally {
    loading.value = false
  }
}

function openEdit() {
  Object.assign(form, {
    merchantName: detail.merchantName,
    contactName: detail.contactName,
    contactMobile: detail.contactMobile,
    settlementMode: detail.settlementMode,
    status: detail.status,
    pointsRule: detail.pointsRule,
  })
  editVisible.value = true
}

async function submitEdit() {
  if (!formRef.value) return
  const valid = await formRef.value.validate().catch(() => false)
  if (!valid) return

  saving.value = true
  try {
    await gatewayMerchantProfileSave({
      merchantId: detail.merchantId,
      ...form,
    })
    ElMessage.success('保存成功')
    editVisible.value = false
    await load()
  } catch (e) {
    ElMessage.error(e.message || '保存失败')
  } finally {
    saving.value = false
  }
}

function displayValue(value) {
  return value === undefined || value === null || value === '' ? '-' : String(value)
}

function maskSecret(value) {
  if (!value) return '-'
  const raw = String(value)
  if (raw.length <= 8) return '*'.repeat(raw.length)
  return `${raw.slice(0, 4)}${'*'.repeat(Math.max(raw.length - 8, 8))}${raw.slice(-4)}`
}

function formatMoney(value) {
  const n = Number(value || 0)
  return n.toFixed(2)
}

async function copyText(text) {
  if (!text) return
  try {
    await navigator.clipboard.writeText(String(text))
    ElMessage.success('复制成功')
  } catch (e) {
    ElMessage.error('复制失败')
  }
}

onMounted(load)
</script>

<style scoped>
.merchant-profile-page {
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

.detail-card {
  min-height: 640px;
  border: none;
}

.card-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.detail-form {
  width: min(1090px, 100%);
  margin: 24px auto 0;
}

.detail-form :deep(.el-form-item) {
  margin-bottom: 20px;
}

.detail-form :deep(.el-input__wrapper) {
  min-height: 42px;
  background: #fff;
}

.copy-line {
  display: flex;
  width: 100%;
  gap: 8px;
}

.copy-line .el-input {
  flex: 1;
}

@media (max-width: 768px) {
  .merchant-profile-page {
    padding: 16px;
  }

  .page-head {
    align-items: flex-start;
    flex-direction: column;
    gap: 12px;
  }

  .detail-form {
    margin-top: 16px;
  }
}
</style>
