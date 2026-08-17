// 通用格式化工具

// Unix 秒时间戳 -> yyyy-MM-dd HH:mm:ss
export function formatTime(ts) {
  if (!ts) return '-'
  const d = new Date(ts * 1000)
  const pad = (n) => String(n).padStart(2, '0')
  return `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())} ${pad(d.getHours())}:${pad(d.getMinutes())}:${pad(d.getSeconds())}`
}

// 金额保留两位小数
export function formatPrice(v) {
  if (v === undefined || v === null) return '-'
  return Number(v).toFixed(2)
}
