// 数全宝网关分发接口相关 API
import { request } from '../../utils/request'

// ===== 商户信息 =====

// 当前商户的数全宝网关资料
export const gatewayMerchantProfile = () => request('/merchant/gateway/profile')

// 保存当前商户的数全宝网关资料
export const gatewayMerchantProfileSave = (body) =>
  request('/merchant/gateway/profile/save', { method: 'POST', body })

// ===== 预存款充值 =====

// 创建预存款充值支付单
export const gatewayRechargeCreate = (body) =>
  request('/merchant/gateway/recharge/create', { method: 'POST', body })

// 查询预存款充值支付状态
export const gatewayRechargeStatus = (orderNo) =>
  request('/merchant/gateway/recharge/status', { method: 'POST', body: { orderNo } })

// ===== 汇付进件 =====

// 提交汇付个人/小微商户进件资料
export const gatewayHuifuPersonalEnterSubmit = (body) =>
  request('/merchant/gateway/huifu/enter/personal', { method: 'POST', body })

// ===== 消息提醒 =====

// 消息提醒统计
export const gatewayMessageSummary = () => request('/merchant/gateway/messages/summary')

// 交易异常列表
export const gatewayMessageRiskList = (body = {}) =>
  request('/merchant/gateway/messages/risk/list', { method: 'POST', body })

// 对账差异列表
export const gatewayMessageDiffList = (body = {}) =>
  request('/merchant/gateway/messages/reconcile-diff/list', { method: 'POST', body })

// ===== 提现管理 =====

// 可提现余额
export const gatewayWithdrawSummary = () => request('/merchant/gateway/withdraw/summary')

// 提现记录
export const gatewayWithdrawList = (body = {}) =>
  request('/merchant/gateway/withdraw/list', { method: 'POST', body })

// 申请提现
export const gatewayWithdrawApply = (body) =>
  request('/merchant/gateway/withdraw/apply', { method: 'POST', body })

// 撤销提现
export const gatewayWithdrawCancel = (id) =>
  request('/merchant/gateway/withdraw/cancel', { method: 'POST', body: { id } })

// ===== 数据统计 =====

export const gatewayDashboardStats = (body = {}) =>
  request('/merchant/gateway/dashboard/stats', { method: 'POST', body })

export const gatewayDashboardPointList = (body = {}) =>
  request('/merchant/gateway/dashboard/points', { method: 'POST', body })

export const gatewayDashboardBalanceList = (body = {}) =>
  request('/merchant/gateway/dashboard/balance-flows', { method: 'POST', body })

// ===== 会员管理 =====

export const gatewayMemberList = (body = {}) =>
  request('/merchant/gateway/member/list', { method: 'POST', body })

export const gatewayMemberDetail = (id) =>
  request('/merchant/gateway/member/detail', { method: 'POST', body: { id } })

export const gatewayMemberDelete = (ids) =>
  request('/merchant/gateway/member/delete', { method: 'POST', body: { ids } })

// ===== 订单与对账 =====

export const gatewayOrderList = (body = {}) =>
  request('/merchant/gateway/order/list', { method: 'POST', body })

export const gatewayOrderDelete = (ids) =>
  request('/merchant/gateway/order/delete', { method: 'POST', body: { ids } })

// ===== 对账差异 =====

export const gatewayReconciliationList = (body = {}) =>
  request('/merchant/gateway/reconciliation/list', { method: 'POST', body })

export const gatewayReconciliationDelete = (ids) =>
  request('/merchant/gateway/reconciliation/delete', { method: 'POST', body: { ids } })

// ===== 资金流水 =====

export const gatewayFlowList = (body = {}) =>
  request('/merchant/gateway/flow/list', { method: 'POST', body })

export const gatewayFlowDelete = (ids) =>
  request('/merchant/gateway/flow/delete', { method: 'POST', body: { ids } })

// ===== API Key 管理 =====

// 获取 API Key 列表
export const apiKeyList = (body = {}) =>
  request('/merchant/gateway/apikey/list', { method: 'POST', body })

// 新增/编辑 API Key
export const apiKeySave = (body) =>
  request('/merchant/gateway/apikey/save', { method: 'POST', body })

// 删除 API Key
export const apiKeyDelete = (ids) =>
  request('/merchant/gateway/apikey/delete', { method: 'POST', body: { ids } })

// 重置 API Key
export const apiKeyReset = (id) =>
  request('/merchant/gateway/apikey/reset', { method: 'POST', body: { id } })

// 获取 API Key 详情
export const apiKeyDetail = (id) =>
  request('/merchant/gateway/apikey/detail', { method: 'POST', body: { id } })
