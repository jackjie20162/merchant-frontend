// 营销活动相关接口（优惠券）
import { request } from '../utils/request'

// 优惠券列表（type: reduction=满减 discount=折扣 shipping=包邮 vip=会员，空=全部）
export const couponList = (body) => request('/merchant/coupon/list', { method: 'POST', body })

// 新增/编辑优惠券（id 为空=新建）
export const couponSave = (body) => request('/merchant/coupon/save', { method: 'POST', body })

// 删除优惠券
export const couponDelete = (ids) => request('/merchant/coupon/delete', { method: 'POST', body: { ids } })
