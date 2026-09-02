import { auth } from '../store/auth'

const TRAVEL_API_BASE = (import.meta.env.VITE_TRAVEL_API_BASE_URL || '').replace(/\/$/, '')

function profileId(...values) {
  for (const value of values) {
    const id = Number(value)
    if (Number.isInteger(id) && id > 0) return id
  }
  return 0
}

function travelHeaders() {
  const profile = auth.profile || {}
  const merchant = profile.merchant || {}
  const shop = profile.shop || {}
  const tenant = profile.tenant || {}
  const staff = profile.staff || {}
  const tenantId = profileId(profile.tenantId, tenant.id, merchant.tenantId, shop.tenantId)
  const merchantId = profileId(profile.merchantId, merchant.id, shop.merchantId)
  const customerId = profileId(profile.customerId, staff.customerId)
  if (!tenantId || !merchantId) throw new Error('商户身份信息不完整，无法访问旅游服务')

  const headers = { 'Content-Type': 'application/json', 'X-Tenant-ID': String(tenantId), 'X-Merchant-ID': String(merchantId) }
  if (customerId) headers['X-Customer-ID'] = String(customerId)
  if (auth.token) headers.Authorization = `Bearer ${auth.token}`
  return headers
}

export async function travelRequest(path, { method = 'GET', body } = {}) {
  const response = await fetch(`${TRAVEL_API_BASE}${path}`, { method, headers: travelHeaders(), body: body === undefined ? undefined : JSON.stringify(body) })
  if (response.status === 401) throw new Error('旅游服务认证已失效')
  let result
  try { result = await response.json() } catch { throw new Error(`旅游服务响应解析失败(HTTP ${response.status})`) }
  if (!response.ok || result.code !== 0) throw new Error(result.msg || `旅游服务请求失败(HTTP ${response.status})`)
  return result.data
}

export const listTravelProducts = (params = {}) => {
  const query = new URLSearchParams()
  Object.entries(params).forEach(([key, value]) => { if (value !== undefined && value !== '') query.set(key, value) })
  return travelRequest(`/api/travel/products${query.toString() ? `?${query}` : ''}`)
}
export const getTravelProduct = (id) => travelRequest(`/api/travel/products/${id}`)
export const checkTravelInventory = (body) => travelRequest('/api/travel/inventory/check', { method: 'POST', body })
export const createTravelOrder = (body) => travelRequest('/api/travel/orders', { method: 'POST', body })
export const getTravelOrder = (orderNo) => travelRequest(`/api/travel/orders/${encodeURIComponent(orderNo)}`)
export const createTravelPayment = (body) => travelRequest('/api/travel/payments', { method: 'POST', body })
export const getTravelPayment = (paymentNo) => travelRequest(`/api/travel/payments/${encodeURIComponent(paymentNo)}`)
