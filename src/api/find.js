// 种草短视频（发现动态）相关接口
import { request } from '../utils/request'

export const findList = (body) => request('/merchant/find/list', { method: 'POST', body })

export const findDetail = (id) => request('/merchant/find/detail', { method: 'POST', body: { id } })

export const findCreate = (body) => request('/merchant/find/create', { method: 'POST', body })

export const findUpdate = (body) => request('/merchant/find/update', { method: 'POST', body })

export const findDelete = (ids) => request('/merchant/find/delete', { method: 'POST', body: { ids } })

export const findRestore = (ids) => request('/merchant/find/restore', { method: 'POST', body: { ids } })
