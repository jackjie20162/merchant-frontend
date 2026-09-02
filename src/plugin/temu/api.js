import { request } from '../../utils/request'

export const temuGatewayProfile = () => request('/merchant/temu/profile')

export const temuGatewayRequestLogList = (body = {}) =>
  request('/merchant/temu/request-log/list', { method: 'POST', body })

export const temuGatewayRequestLogDetail = (id) =>
  request('/merchant/temu/request-log/detail', { method: 'POST', body: { id } })
