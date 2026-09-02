<template>
  <div class="temu-page">
    <div class="page-head">
      <div>
        <h2>Temu API Key</h2>
        <span>View the current merchant Temu key and gateway info.</span>
      </div>
      <el-breadcrumb separator="/">
        <el-breadcrumb-item :to="{ path: '/dashboard' }">Home</el-breadcrumb-item>
        <el-breadcrumb-item>Temu</el-breadcrumb-item>
        <el-breadcrumb-item>API Key</el-breadcrumb-item>
      </el-breadcrumb>
    </div>

    <el-row :gutter="16" class="stat-row">
      <el-col :xs="24" :sm="8">
        <div class="stat-card">
          <span>Merchant</span>
          <strong>{{ detail.merchantName }}</strong>
        </div>
      </el-col>
      <el-col :xs="24" :sm="8">
        <div class="stat-card">
          <span>Status</span>
          <strong><el-tag :type="detail.statusTag" size="small">{{ detail.statusText }}</el-tag></strong>
        </div>
      </el-col>
      <el-col :xs="24" :sm="8">
        <div class="stat-card">
          <span>Total Requests</span>
          <strong>{{ detail.requestTotal }}</strong>
        </div>
      </el-col>
    </el-row>

    <el-card v-loading="loading" shadow="never" class="panel-card">
      <template #header>
        <div class="card-header">
          <span>Key Details</span>
          <el-button :icon="Refresh" @click="loadDetail">Refresh</el-button>
        </div>
      </template>

      <el-descriptions :column="2" border>
        <el-descriptions-item label="Merchant ID">{{ detail.merchantId }}</el-descriptions-item>
        <el-descriptions-item label="Merchant Name">{{ detail.merchantName }}</el-descriptions-item>
        <el-descriptions-item label="Upstream URL">{{ detail.upstreamBaseUrl }}</el-descriptions-item>
        <el-descriptions-item label="Updated At">{{ detail.updatedAt }}</el-descriptions-item>
        <el-descriptions-item label="API Key">
          <div class="copy-line">
            <el-input :model-value="detail.apiKey" readonly />
            <el-tooltip content="Copy API Key" placement="top">
              <el-button :disabled="!detail.apiKey" @click="copyText(detail.apiKey)">
                <el-icon><CopyDocument /></el-icon>
              </el-button>
            </el-tooltip>
          </div>
        </el-descriptions-item>
        <el-descriptions-item label="API Secret">
          <div class="copy-line">
            <el-input :model-value="secretVisible ? detail.apiSecret : maskSecret(detail.apiSecret)" readonly />
            <el-tooltip :content="secretVisible ? 'Hide secret' : 'Show secret'" placement="top">
              <el-button :disabled="!detail.apiSecret" @click="secretVisible = !secretVisible">
                <el-icon>
                  <View v-if="!secretVisible" />
                  <Hide v-else />
                </el-icon>
              </el-button>
            </el-tooltip>
            <el-tooltip content="Copy secret" placement="top">
              <el-button :disabled="!detail.apiSecret" @click="copyText(detail.apiSecret)">
                <el-icon><CopyDocument /></el-icon>
              </el-button>
            </el-tooltip>
          </div>
        </el-descriptions-item>
      </el-descriptions>
    </el-card>
  </div>
</template>

<script setup>
import { onMounted, reactive, ref } from 'vue'
import { ElMessage } from 'element-plus'
import { CopyDocument, Hide, Refresh, View } from '@element-plus/icons-vue'

import { temuGatewayProfile } from '../api'

const loading = ref(false)
const secretVisible = ref(false)

const detail = reactive({
  merchantId: '-',
  merchantName: '-',
  apiKey: '-',
  apiSecret: '',
  statusText: 'enabled',
  statusTag: 'success',
  upstreamBaseUrl: '-',
  requestTotal: 0,
  updatedAt: '-',
})

const fallbackDetail = {
  merchantId: '10001',
  merchantName: 'Demo Merchant',
  apiKey: 'tm_demo_7f9a9c9c3b5e',
  apiSecret: 'demo-secret-please-replace',
  statusText: 'enabled',
  statusTag: 'success',
  upstreamBaseUrl: 'https://temu.example.com',
  requestTotal: 128,
  updatedAt: '2026-08-30 14:30:00',
}

function normalizeStatus(value) {
  const status = String(value || 'enabled').toLowerCase()
  if (['enabled', '1', 'normal', 'active'].includes(status)) {
    return { statusText: 'enabled', statusTag: 'success' }
  }
  if (['disabled', '0', 'frozen'].includes(status)) {
    return { statusText: 'disabled', statusTag: 'danger' }
  }
  return { statusText: status || '-', statusTag: 'info' }
}

function normalizeDetail(data = {}) {
  const status = normalizeStatus(data.status || data.merchantStatus)
  return {
    merchantId: data.merchantId || data.merchant_id || data.id || '-',
    merchantName: data.merchantName || data.merchant_name || data.name || '-',
    apiKey: data.apiKey || data.api_key || data.key || '-',
    apiSecret: data.apiSecret || data.api_secret || '',
    upstreamBaseUrl: data.upstreamBaseUrl || data.upstream_base_url || '-',
    requestTotal: Number(data.requestTotal ?? data.request_total ?? data.totalRequests ?? 0),
    updatedAt: data.updatedAt || data.updated_at || '-',
    ...status,
  }
}

async function loadDetail() {
  loading.value = true
  try {
    const data = await temuGatewayProfile()
    Object.assign(detail, normalizeDetail(data))
  } catch (e) {
    Object.assign(detail, fallbackDetail)
  } finally {
    loading.value = false
  }
}

function maskSecret(value) {
  const text = String(value || '')
  if (!text) return '-'
  if (text.length <= 8) return '****'
  return `${text.slice(0, 4)}****${text.slice(-4)}`
}

async function copyText(text) {
  try {
    await navigator.clipboard.writeText(text)
    ElMessage.success('Copied')
  } catch (e) {
    ElMessage.error('Copy failed')
  }
}

onMounted(loadDetail)
</script>

<style scoped>
.temu-page {
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
  font-size: 24px;
  color: #111827;
}

.page-head span {
  color: #6b7280;
}

.stat-row {
  margin-bottom: 16px;
}

.stat-card {
  padding: 16px 18px;
  border: 1px solid #e5e7eb;
  border-radius: 8px;
  background: #fff;
}

.stat-card span {
  display: block;
  margin-bottom: 8px;
  color: #6b7280;
  font-size: 13px;
}

.stat-card strong {
  font-size: 18px;
  color: #111827;
}

.panel-card {
  border-radius: 8px;
}

.card-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.copy-line {
  display: flex;
  gap: 8px;
  align-items: center;
}
</style>
