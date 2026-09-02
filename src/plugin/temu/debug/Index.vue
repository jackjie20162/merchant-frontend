<template>
  <div class="temu-page">
    <div class="page-head">
      <div>
        <h2>Temu API Debug</h2>
        <span>Build requests, sign them, and inspect responses.</span>
      </div>
      <el-breadcrumb separator="/">
        <el-breadcrumb-item :to="{ path: '/dashboard' }">Home</el-breadcrumb-item>
        <el-breadcrumb-item>Temu</el-breadcrumb-item>
        <el-breadcrumb-item>Debug</el-breadcrumb-item>
      </el-breadcrumb>
    </div>

    <el-row :gutter="16" class="top-row">
      <el-col :xs="24" :sm="8">
        <div class="stat-card">
          <span>Request URL</span>
          <strong>{{ previewUrl || '-' }}</strong>
        </div>
      </el-col>
      <el-col :xs="24" :sm="8">
        <div class="stat-card">
          <span>Response</span>
          <strong>{{ result.statusText }}</strong>
        </div>
      </el-col>
      <el-col :xs="24" :sm="8">
        <div class="stat-card">
          <span>Latency</span>
          <strong>{{ result.elapsed }} ms</strong>
        </div>
      </el-col>
    </el-row>

    <el-row :gutter="16">
      <el-col :xs="24" :lg="12">
        <el-card shadow="never" class="panel-card">
          <template #header>
            <div class="card-header">
              <span>Request Setup</span>
              <el-button-group>
                <el-button :icon="VideoPlay" type="primary" :loading="sending" @click="sendRequest">Send</el-button>
                <el-button :icon="MagicStick" @click="fillSignature">Sign</el-button>
                <el-button :icon="DocumentCopy" @click="copyCurl">Copy cURL</el-button>
                <el-button :icon="Refresh" @click="resetForm">Reset</el-button>
              </el-button-group>
            </div>
          </template>

          <el-form label-position="top" :model="form" class="debug-form">
            <el-row :gutter="12">
              <el-col :xs="24" :sm="14">
                <el-form-item label="Request URL">
                  <el-input v-model="form.targetUrl" placeholder="https://example.com/temu/member/query" />
                </el-form-item>
              </el-col>
              <el-col :xs="24" :sm="10">
                <el-form-item label="Method">
                  <el-select v-model="form.method" style="width: 100%">
                    <el-option label="GET" value="GET" />
                    <el-option label="POST" value="POST" />
                    <el-option label="PUT" value="PUT" />
                    <el-option label="PATCH" value="PATCH" />
                    <el-option label="DELETE" value="DELETE" />
                  </el-select>
                </el-form-item>
              </el-col>
            </el-row>

            <el-row :gutter="12">
              <el-col :xs="24" :sm="12">
                <el-form-item label="Interface Code">
                  <el-input v-model="form.interfaceCode" placeholder="temu.member.query" />
                </el-form-item>
              </el-col>
              <el-col :xs="24" :sm="12">
                <el-form-item label="API Key">
                  <el-input v-model="form.apiKey" placeholder="tm_xxx" />
                </el-form-item>
              </el-col>
            </el-row>

            <el-row :gutter="12">
              <el-col :xs="24" :sm="12">
                <el-form-item label="API Secret">
                  <el-input v-model="form.apiSecret" type="password" show-password placeholder="used for signing" />
                </el-form-item>
              </el-col>
              <el-col :xs="24" :sm="12">
                <el-form-item label="User ID">
                  <el-input v-model="form.userId" placeholder="10086" />
                </el-form-item>
              </el-col>
            </el-row>

            <el-row :gutter="12">
              <el-col :xs="24" :sm="12">
                <el-form-item label="Timestamp">
                  <el-input v-model="form.timestamp" placeholder="unix seconds" />
                </el-form-item>
              </el-col>
              <el-col :xs="24" :sm="12">
                <el-form-item label="Auto Sign">
                  <el-switch v-model="form.autoSign" inline-prompt active-text="on" inactive-text="off" />
                </el-form-item>
              </el-col>
            </el-row>

            <el-row :gutter="12">
              <el-col :xs="24" :sm="8">
                <el-form-item label="Use Self App">
                  <el-switch v-model="form.useSelfApp" inline-prompt active-text="yes" inactive-text="no" />
                </el-form-item>
              </el-col>
              <el-col :xs="24" :sm="8">
                <el-form-item label="Gateway App Key">
                  <el-input v-model="form.gatewayAppKey" placeholder="default app key" />
                </el-form-item>
              </el-col>
              <el-col :xs="24" :sm="8">
                <el-form-item label="Gateway App Secret">
                  <el-input v-model="form.gatewayAppSecret" type="password" show-password placeholder="default app secret" />
                </el-form-item>
              </el-col>
            </el-row>

            <el-row :gutter="12">
              <el-col :xs="24" :sm="12">
                <el-form-item label="Access Token">
                  <el-input v-model="form.accessToken" placeholder="optional access token" />
                </el-form-item>
              </el-col>
            </el-row>

            <el-form-item label="Query JSON">
              <el-input
                v-model="form.queryText"
                type="textarea"
                :rows="4"
                placeholder='{"member_id":"10086"}'
              />
            </el-form-item>

            <el-form-item label="Headers JSON">
              <el-input
                v-model="form.headersText"
                type="textarea"
                :rows="4"
                placeholder='{"X-Trace-Id":"demo-001"}'
              />
            </el-form-item>

            <el-form-item label="Body JSON">
              <el-input
                v-model="form.bodyText"
                type="textarea"
                :rows="8"
                placeholder='{"order_id":"T20260830001"}'
              />
            </el-form-item>
          </el-form>
        </el-card>
      </el-col>

      <el-col :xs="24" :lg="12">
        <el-card shadow="never" class="panel-card">
          <template #header>
            <div class="card-header">
              <span>Result</span>
              <el-tag v-if="result.ok !== null" :type="result.ok ? 'success' : 'danger'">
                {{ result.ok ? 'ok' : 'error' }}
              </el-tag>
            </div>
          </template>

          <el-alert
            v-if="errorMessage"
            :title="errorMessage"
            type="error"
            show-icon
            :closable="false"
            class="mb12"
          />

          <el-descriptions :column="1" border>
            <el-descriptions-item label="URL">{{ previewUrl || '-' }}</el-descriptions-item>
            <el-descriptions-item label="Method">{{ form.method }}</el-descriptions-item>
            <el-descriptions-item label="Status">{{ result.statusCode || '-' }}</el-descriptions-item>
            <el-descriptions-item label="Content-Type">{{ result.contentType || '-' }}</el-descriptions-item>
            <el-descriptions-item label="Latency">{{ result.elapsed }} ms</el-descriptions-item>
          </el-descriptions>

          <el-tabs v-model="activeTab" class="result-tabs">
            <el-tab-pane label="Response" name="response">
              <pre class="code-block">{{ formattedResponse }}</pre>
            </el-tab-pane>
            <el-tab-pane label="Request Preview" name="request">
              <pre class="code-block">{{ requestPreview }}</pre>
            </el-tab-pane>
            <el-tab-pane label="Response Headers" name="headers">
              <pre class="code-block">{{ formattedHeaders }}</pre>
            </el-tab-pane>
          </el-tabs>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script setup>
import { computed, reactive, ref } from 'vue'
import { ElMessage } from 'element-plus'
import { DocumentCopy, MagicStick, Refresh, VideoPlay } from '@element-plus/icons-vue'

const defaultForm = () => ({
  targetUrl: 'http://127.0.0.1:8092/temu/v2/gateway/temu.member.query',
  method: 'POST',
  interfaceCode: 'temu.member.query',
  apiKey: 'tm_demo_7f9a9c9c3b5e',
  apiSecret: 'demo-secret-please-replace',
  useSelfApp: false,
  gatewayAppKey: '',
  gatewayAppSecret: '',
  accessToken: '',
  userId: '10086',
  timestamp: String(Math.floor(Date.now() / 1000)),
  autoSign: true,
  queryText: '{"member_id":"10086"}',
  headersText: '{}',
  bodyText: '{"member_id":"10086"}',
})

const form = reactive(defaultForm())
const sending = ref(false)
const activeTab = ref('response')
const errorMessage = ref('')
const result = reactive({
  ok: null,
  statusCode: '',
  statusText: '-',
  contentType: '',
  elapsed: 0,
  responseText: '',
  responseHeaders: [],
})

const previewUrl = computed(() => buildUrl())
const formattedResponse = computed(() => prettyJson(result.responseText))
const formattedHeaders = computed(() =>
  result.responseHeaders.length
    ? result.responseHeaders.map((row) => `${row.name}: ${row.value}`).join('\n')
    : '-',
)
const requestPreview = computed(() => buildCurl())

function resetForm() {
  Object.assign(form, defaultForm())
  errorMessage.value = ''
  Object.assign(result, {
    ok: null,
    statusCode: '',
    statusText: '-',
    contentType: '',
    elapsed: 0,
    responseText: '',
    responseHeaders: [],
  })
}

function buildUrl() {
  const raw = String(form.targetUrl || '').trim()
  if (!raw) return ''
  const url = new URL(raw, window.location.origin)
  const query = safeParseJson(form.queryText, {})
  Object.entries(query).forEach(([key, value]) => {
    if (value === undefined || value === null || value === '') return
    url.searchParams.set(key, String(value))
  })
  return url.toString()
}

function buildBodyText() {
  const text = String(form.bodyText || '').trim()
  if (!text) return ''
  try {
    return JSON.stringify(JSON.parse(text))
  } catch (e) {
    return text
  }
}

function buildHeaders() {
  const extra = safeParseJson(form.headersText, {})
  const headers = {
    'Content-Type': 'application/json',
    ...extra,
  }
  if (form.apiKey) {
    headers['X-Temu-Key'] = form.apiKey
  }
  if (form.useSelfApp) {
    headers['X-Temu-Use-Self-App'] = 'true'
    if (form.gatewayAppKey) {
      headers['X-Temu-App-Key'] = form.gatewayAppKey
    }
    if (form.gatewayAppSecret) {
      headers['X-Temu-App-Secret'] = form.gatewayAppSecret
    }
  }
  if (form.accessToken) {
    headers['X-Temu-Access-Token'] = form.accessToken
  }
  if (form.userId) {
    headers['X-Temu-User-Id'] = form.userId
  }
  if (form.autoSign && form.apiSecret) {
    headers['X-Temu-Timestamp'] = form.timestamp || String(Math.floor(Date.now() / 1000))
  }
  return headers
}

async function fillSignature() {
  if (!form.apiSecret) {
    ElMessage.warning('Please fill API secret first')
    return
  }
  form.timestamp = String(Math.floor(Date.now() / 1000))
  const url = new URL(buildUrl())
  const body = buildBodyText()
  const payload = [form.method.toUpperCase(), url.pathname, url.search.replace(/^\?/, ''), form.timestamp, body].join('\n')
  form.headersText = JSON.stringify(
    {
      ...safeParseJson(form.headersText, {}),
      'X-Temu-Key': form.apiKey || '',
      'X-Temu-Timestamp': form.timestamp,
      'X-Temu-Signature': await hmacSha256Hex(form.apiSecret, payload),
    },
    null,
    2,
  )
  form.autoSign = false
  ElMessage.success('Signed')
}

async function sendRequest() {
  errorMessage.value = ''
  sending.value = true
  const start = performance.now()
  try {
    const url = new URL(buildUrl())
    const headers = buildHeaders()
    if (form.autoSign && form.apiSecret) {
      const bodyForSign = buildBodyText()
      const payload = [form.method.toUpperCase(), url.pathname, url.search.replace(/^\?/, ''), headers['X-Temu-Timestamp'], bodyForSign].join('\n')
      headers['X-Temu-Signature'] = await hmacSha256Hex(form.apiSecret, payload)
    }

    const options = {
      method: form.method,
      headers,
    }
    if (!['GET', 'HEAD'].includes(form.method.toUpperCase())) {
      options.body = buildBodyText()
    }

    const resp = await fetch(url.toString(), options)
    const text = await resp.text()
    result.ok = resp.ok
    result.statusCode = resp.status
    result.statusText = resp.statusText || (resp.ok ? 'OK' : 'ERROR')
    result.contentType = resp.headers.get('content-type') || ''
    result.responseText = text
    result.responseHeaders = Array.from(resp.headers.entries()).map(([name, value]) => ({ name, value }))
    result.elapsed = Math.round(performance.now() - start)
    activeTab.value = 'response'
  } catch (e) {
    errorMessage.value = e?.message || 'Request failed'
    result.ok = false
    result.statusText = 'ERROR'
    result.elapsed = Math.round(performance.now() - start)
  } finally {
    sending.value = false
  }
}

async function copyCurl() {
  try {
    await navigator.clipboard.writeText(buildCurl())
    ElMessage.success('Copied cURL')
  } catch (e) {
    ElMessage.error('Copy failed')
  }
}

function buildCurl() {
  const headers = buildHeaders()
  const lines = [`curl -X ${form.method.toUpperCase()} "${previewUrl.value || ''}"`]
  Object.entries(headers).forEach(([key, value]) => {
    lines.push(`  -H "${key}: ${escapeDoubleQuotes(String(value))}"`)
  })
  const body = buildBodyText()
  if (body && !['GET', 'HEAD'].includes(form.method.toUpperCase())) {
    lines.push(`  --data-raw '${body.replaceAll("'", "'\\''")}'`)
  }
  return lines.join(' \\\n')
}

function safeParseJson(text, fallback = {}) {
  const value = String(text || '').trim()
  if (!value) return fallback
  try {
    const parsed = JSON.parse(value)
    return parsed && typeof parsed === 'object' ? parsed : fallback
  } catch (e) {
    return fallback
  }
}

function prettyJson(text) {
  const value = String(text || '').trim()
  if (!value) return '-'
  try {
    return JSON.stringify(JSON.parse(value), null, 2)
  } catch (e) {
    return value
  }
}

function escapeDoubleQuotes(text) {
  return text.replaceAll('"', '\\"')
}

async function hmacSha256Hex(secret, message) {
  const key = await crypto.subtle.importKey(
    'raw',
    new TextEncoder().encode(secret),
    { name: 'HMAC', hash: 'SHA-256' },
    false,
    ['sign'],
  )
  const signature = await crypto.subtle.sign('HMAC', key, new TextEncoder().encode(message))
  return Array.from(new Uint8Array(signature))
    .map((b) => b.toString(16).padStart(2, '0'))
    .join('')
}
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

.top-row {
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
  display: block;
  font-size: 16px;
  color: #111827;
  word-break: break-all;
}

.panel-card {
  border-radius: 8px;
}

.card-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
}

.debug-form {
  max-height: none;
}

.mb12 {
  margin-bottom: 12px;
}

.result-tabs {
  margin-top: 16px;
}

.code-block {
  margin: 0;
  min-height: 240px;
  padding: 12px;
  border-radius: 8px;
  background: #0f172a;
  color: #e2e8f0;
  white-space: pre-wrap;
  word-break: break-word;
}
</style>
