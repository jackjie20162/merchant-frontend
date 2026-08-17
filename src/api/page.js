// 装修页面（DIY）相关接口
import { request } from '../utils/request'

// 页面列表（type 不传=本店全部；type=systpl=平台模板只读）
export const pageList = (body = {}) => request('/merchant/page/list', { method: 'POST', body })

// 页面详情（本店页面或平台模板）
export const pageDetail = (id) => request(`/merchant/page/detail/${id}`)

// 新建/保存页面（id 为空=新建；page/item 为 JSON 字符串）
export const pageSave = (body) => request('/merchant/page/save', { method: 'POST', body })

// 删除页面
export const pageDelete = (ids) => request('/merchant/page/delete', { method: 'POST', body: { ids } })
