import { request } from '../utils/request'

// ===== 交易管理 API =====
// 列表接口统一返回 { total, data }；shop_id 由后端从会话注入，前端不传

// 商品订单
export const orderList = (body) => request('/merchant/order/list', { method: 'POST', body })
export const orderDetail = (id) => request(`/merchant/order/detail/${id}`)
export const orderDeliver = (body) => request('/merchant/order/deliver', { method: 'POST', body })

// 拼团订单
export const groupsOrderList = (body) => request('/merchant/groups/list', { method: 'POST', body })

// 评论
export const commentList = (body) => request('/merchant/comment/list', { method: 'POST', body })
export const commentUpdate = (body) => request('/merchant/comment/update', { method: 'POST', body })

// 退款
export const refundList = (body) => request('/merchant/refund/list', { method: 'POST', body })
export const refundDetail = (id) => request(`/merchant/refund/detail/${id}`)
export const refundAudit = (body) => request('/merchant/refund/audit', { method: 'POST', body })
export const refundReceive = (id) => request(`/merchant/refund/receive/${id}`, { method: 'POST' })
