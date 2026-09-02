// 会员管理 Mock 数据
const mockMembers = Array.from({ length: 100 }, (_, index) => {
  const id = index + 1
  const statuses = ['正常', '冻结', '注销']
  const statusWeights = [0.8, 0.15, 0.05] // 权重分布
  const randomStatus = () => {
    const rand = Math.random()
    if (rand < statusWeights[0]) return '正常'
    if (rand < statusWeights[0] + statusWeights[1]) return '冻结'
    return '注销'
  }
  
  return {
    id,
    mobile: `13${Math.floor(100000000 + Math.random() * 900000000)}`,
    nickname: `会员_${id.toString().padStart(4, '0')}`,
    pointsInStore: Number((Math.random() * 1000).toFixed(2)),
    pointsAvailableInPlatform: Number((Math.random() * 500).toFixed(2)),
    pointsTotalInPlatform: Number((Math.random() * 800).toFixed(2)),
    status: randomStatus(),
    createdAt: new Date(2026, 7, Math.floor(Math.random() * 26) + 1, 
      Math.floor(Math.random() * 24), Math.floor(Math.random() * 60)).toLocaleString('zh-CN'),
  }
})

export function getMembers(page = 1, pageSize = 10, filters = {}) {
  return new Promise((resolve) => {
    setTimeout(() => {
      let filtered = mockMembers
      
      // 应用筛选条件
      if (filters.mobile) {
        filtered = filtered.filter(m => m.mobile.includes(filters.mobile))
      }
      if (filters.status) {
        filtered = filtered.filter(m => m.status === filters.status)
      }
      if (filters.keyword) {
        filtered = filtered.filter(m => 
          m.nickname.includes(filters.keyword) || 
          m.mobile.includes(filters.keyword)
        )
      }
      
      const total = filtered.length
      const start = (page - 1) * pageSize
      const list = filtered.slice(start, start + pageSize)
      
      resolve({
        code: 0,
        msg: 'success',
        data: {
          list,
          total,
          page,
          page_size: pageSize,
        },
      })
    }, 300) // 模拟网络延迟
  })
}

export function getMemberDetail(id) {
  return new Promise((resolve) => {
    setTimeout(() => {
      const member = mockMembers.find(m => m.id === id) || null
      resolve({
        code: 0,
        msg: 'success',
        data: member,
      })
    }, 200)
  })
}
