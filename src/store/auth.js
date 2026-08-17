// 登录态与权限管理（轻量 reactive store）
import { reactive } from 'vue'
import { request, setToken, clearToken, getToken } from '../utils/request'

export const auth = reactive({
  token: getToken(),
  profile: null, // MerchantProfileResp：{ merchant, shop, staff, perms }
})

// 是否拥有指定权限码
export function hasPerm(code) {
  if (!auth.profile) return false
  return (auth.profile.perms || []).includes(code)
}

// 是否主账号登录
export function isOwner() {
  return auth.profile && !auth.profile.staff
}

// 登录：成功后拉取资料
export async function login(account, password) {
  const data = await request('/merchant/login', {
    method: 'POST',
    body: { account, password },
  })
  setToken(data.token)
  auth.token = data.token
  await fetchProfile()
}

// 拉取当前登录身份资料（含权限码）
export async function fetchProfile() {
  auth.profile = await request('/merchant/profile')
}

// 退出登录
export function logout() {
  clearToken()
  auth.token = ''
  auth.profile = null
}
