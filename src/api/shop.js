// 店铺管理相关接口（自定义类目/店铺资料/品牌）
import { request } from '../utils/request'

// ===== 自定义类目 =====

// 本店类目树（type: goods=商品类目 article=文章类目）
export const categoryTree = (type = 'goods') =>
  request('/merchant/category/tree', { method: 'POST', body: { type } })

// 新增/编辑类目（id 为空=新建）
export const categorySave = (body) => request('/merchant/category/save', { method: 'POST', body })

// 删除类目
export const categoryDelete = (ids) =>
  request('/merchant/category/delete', { method: 'POST', body: { ids } })

// ===== 店铺资料 =====

// 本店资料
export const shopInfo = () => request('/merchant/shop/info')

// 更新本店资料
export const shopSave = (body) => request('/merchant/shop/save', { method: 'POST', body })

// ===== 品牌管理 =====

// 品牌列表
export const brandListAll = (body = {}) => request('/merchant/brand/list', { method: 'POST', body })

// 新增/编辑品牌
export const brandSave = (body) => request('/merchant/brand/save', { method: 'POST', body })

// 删除品牌
export const brandDelete = (ids) => request('/merchant/brand/delete', { method: 'POST', body: { ids } })

// ===== 店铺配置（商家店铺配置/寄件人信息/退货信息） =====

// 本店配置
export const shopSettingsGet = () => request('/merchant/settings/get')

// 保存本店配置
export const shopSettingsSave = (body) =>
  request('/merchant/settings/save', { method: 'POST', body })
