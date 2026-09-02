// 阶梯拼团相关接口
import { request } from '../utils/request'

// ===== 拼团商品 =====
export const groupsGoodsList = (body) => request('/merchant/groups/goods/list', { method: 'POST', body })

export const groupsGoodsDetail = (id) => request(`/merchant/groups/goods/detail/${id}`)

export const groupsGoodsSave = (body) => request('/merchant/groups/goods/save', { method: 'POST', body })

export const groupsGoodsDelete = (ids) =>
  request('/merchant/groups/goods/delete', { method: 'POST', body: { ids } })

export const groupsGoodsGrounding = (id, grounding) =>
  request('/merchant/groups/goods/grounding', { method: 'POST', body: { id, grounding } })

// ===== 拼团记录 =====
export const groupsList = (body) => request('/merchant/groups/manage/list', { method: 'POST', body })

export const groupsDetail = (id) => request(`/merchant/groups/manage/detail/${id}`)

// ===== 复制商城商品（待后端实现） =====
export const copyGoodsFromShop = (goodsId) =>
  request('/merchant/groups/goods/copy', { method: 'POST', body: { goods_id: goodsId } })

// ===== 回收站（待后端实现） =====
export const groupsGoodsRecycleList = (body) =>
  request('/merchant/groups/goods/recycle/list', { method: 'POST', body })

export const groupsGoodsRestore = (ids) =>
  request('/merchant/groups/goods/recycle/restore', { method: 'POST', body: { ids } })
