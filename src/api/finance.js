// 财务管理相关接口（对账单/提现）
import { request } from '../utils/request'

// ===== 对账单 =====

// 财务汇总（收入/退款/提现/可提现余额）
export const billSummary = () => request('/merchant/bill/summary')

// 对账单明细（direction: income=收入,refund=退款支出，空=全部）
export const billList = (body) => request('/merchant/bill/list', { method: 'POST', body })

// ===== 提现 =====

// 本店提现记录
export const withdrawList = (body) => request('/merchant/withdraw/list', { method: 'POST', body })

// 申请提现
export const withdrawApply = (body) => request('/merchant/withdraw/apply', { method: 'POST', body })

// 撤销提现申请（仅申请中状态可撤销）
export const withdrawDelete = (ids) =>
  request('/merchant/withdraw/delete', { method: 'POST', body: { ids } })
