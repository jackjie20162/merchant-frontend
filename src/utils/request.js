// 商家端接口请求封装：统一携带 token、解包 {code, msg, data} 响应
const TOKEN_KEY = 'merchant_token'

export function getToken() {
  return localStorage.getItem(TOKEN_KEY) || ''
}

export function setToken(token) {
  localStorage.setItem(TOKEN_KEY, token)
}

export function clearToken() {
  localStorage.removeItem(TOKEN_KEY)
}

export async function request(path, { method = 'GET', body } = {}) {
  const headers = { 'Content-Type': 'application/json' }
  const token = getToken()
  if (token) {
    headers.Authorization = `Bearer ${token}`
  }
  const resp = await fetch(path, {
    method,
    headers,
    body: body === undefined ? undefined : JSON.stringify(body),
  })
  if (resp.status === 401) {
    clearToken()
    window.location.href = '/login'
    throw new Error('登录已过期，请重新登录')
  }
  let result
  try {
    result = await resp.json()
  } catch (e) {
    throw new Error(`响应解析失败(HTTP ${resp.status})`)
  }
  if (result.code === 401) {
    clearToken()
    window.location.href = '/login'
    throw new Error('登录已过期，请重新登录')
  }
  if (result.code === 403) {
    throw new Error(result.msg || '没有权限执行此操作')
  }
  if (result.code !== 0) {
    throw new Error(result.msg || '请求失败')
  }
  return result.data
}
