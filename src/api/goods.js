// 商品管理相关接口
import { request } from '../utils/request'

// 商品列表（grounding=1 出售中 / =0 仓库中）
export const goodsList = (body) => request('/merchant/goods/list', { method: 'POST', body })

// 商品详情（含 SPU/SKU）
export const goodsDetail = (id) => request(`/merchant/goods/detail/${id}`)

// 发布/编辑商品（goods+spus+skus 整体保存，goods.id 为空=新建）
export const goodsSave = (body) => request('/merchant/goods/save', { method: 'POST', body })

// 删除商品
export const goodsDelete = (ids) => request('/merchant/goods/delete', { method: 'POST', body: { ids } })

// 上架/下架
export const goodsGrounding = (id, grounding) =>
  request('/merchant/goods/grounding', { method: 'POST', body: { id, grounding } })

// 运费模板列表（商品编辑选择用）
export const freightList = (body = {}) => request('/merchant/freight/list', { method: 'POST', body })

// 平台类目树（公开接口，商品类目级联用）
export const platformCategoryTree = () => request('/api/category/tree/goods')

// 本店自定义类目树（店铺类目多选用）
export const shopCategoryTree = () =>
  request('/merchant/category/tree', { method: 'POST', body: { type: 'goods' } })

// 本店品牌列表（商品编辑选择用）
export const brandList = (body = {}) => request('/merchant/brand/list', { method: 'POST', body })
