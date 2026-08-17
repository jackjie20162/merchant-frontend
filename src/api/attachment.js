// 图片空间（附件）相关接口
import { getToken, request } from '../utils/request'

// 附件列表
export const attachmentList = (body = {}) => request('/merchant/attachment/list', { method: 'POST', body })

// 删除附件
export const attachmentDelete = (ids) =>
  request('/merchant/attachment/delete', { method: 'POST', body: { ids } })

// 上传图片（multipart，字段名 file），返回 { id, url }
export async function attachmentUpload(file) {
  const fd = new FormData()
  fd.append('file', file)
  const resp = await fetch('/merchant/attachment/upload', {
    method: 'POST',
    headers: { Authorization: `Bearer ${getToken()}` },
    body: fd,
  })
  let result
  try {
    result = await resp.json()
  } catch (e) {
    throw new Error(`响应解析失败(HTTP ${resp.status})`)
  }
  if (result.code !== 0) {
    throw new Error(result.msg || '上传失败')
  }
  return result.data
}
