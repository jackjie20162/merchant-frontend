// 物流运费相关接口（运费模板）
import { request } from '../utils/request'

// 运费模板列表（status: normal=正常 hidden=隐藏，空=全部）
export const freightTplList = (body) => request('/merchant/freight/tpl/list', { method: 'POST', body })

// 运费模板详情（含区域运费行）
export const freightTplDetail = (id) => request(`/merchant/freight/tpl/detail/${id}`)

// 新增/编辑运费模板（{freight:{...}, data:[区域运费行...]}，freight.id 为空=新建）
export const freightTplSave = (body) => request('/merchant/freight/tpl/save', { method: 'POST', body })

// 删除运费模板
export const freightTplDelete = (ids) =>
  request('/merchant/freight/tpl/delete', { method: 'POST', body: { ids } })
