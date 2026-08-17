<template>
  <el-card>
    <template #header>
      <div class="card-header">
        <span>商品评论</span>
        <div class="filter-area">
          <el-select v-model="query.status" style="width: 130px" @change="onSearch">
            <el-option label="全部状态" value="" />
            <el-option label="正常" value="normal" />
            <el-option label="已隐藏" value="hidden" />
          </el-select>
        </div>
      </div>
    </template>

    <el-tabs v-model="query.state" @tab-change="onSearch">
      <el-tab-pane label="全部" name="" />
      <el-tab-pane label="好评" name="0" />
      <el-tab-pane label="中评" name="1" />
      <el-tab-pane label="差评" name="2" />
    </el-tabs>

    <el-table :data="list" v-loading="loading" stripe>
      <el-table-column label="买家" width="120">
        <template #default="{ row }">
          {{ row.switch === 1 ? '匿名用户' : row.user_nickname || `用户${row.user_id}` }}
        </template>
      </el-table-column>
      <el-table-column label="评价" width="80">
        <template #default="{ row }">
          <el-tag :type="rateTag(row.state)" size="small">{{ rateText(row.state) }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="评论内容" min-width="260">
        <template #default="{ row }">
          <div>{{ row.content || '-' }}</div>
          <div v-if="parseImages(row.images).length" class="comment-imgs">
            <el-image
              v-for="(img, i) in parseImages(row.images)"
              :key="i"
              :src="img"
              :preview-src-list="parseImages(row.images)"
              :initial-index="i"
              class="comment-img"
              fit="cover"
            />
          </div>
        </template>
      </el-table-column>
      <el-table-column label="商品" min-width="160">
        <template #default="{ row }">
          <div>{{ row.goods_title || '-' }}</div>
          <div class="goods-suk">{{ row.suk || '' }}</div>
        </template>
      </el-table-column>
      <el-table-column label="评分" width="80">
        <template #default="{ row }">{{ row.score ?? '-' }}</template>
      </el-table-column>
      <el-table-column label="状态" width="90">
        <template #default="{ row }">
          <el-tag v-if="row.status === 'hidden'" type="info" size="small">已隐藏</el-tag>
          <el-tag v-else type="success" size="small">正常</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="评论时间" width="170">
        <template #default="{ row }">{{ formatTime(row.createtime) }}</template>
      </el-table-column>
      <el-table-column label="操作" width="90" fixed="right">
        <template #default="{ row }">
          <el-button
            v-if="hasPerm('comment:update')"
            link
            :type="row.status === 'hidden' ? 'success' : 'danger'"
            @click="onToggle(row)"
          >
            {{ row.status === 'hidden' ? '显示' : '隐藏' }}
          </el-button>
        </template>
      </el-table-column>
    </el-table>

    <div class="pager">
      <el-pagination
        v-model:current-page="query.page"
        v-model:page-size="query.page_size"
        :total="total"
        layout="total, prev, pager, next, sizes"
        :page-sizes="[10, 20, 50]"
        @current-change="load"
        @size-change="onSearch"
      />
    </div>
  </el-card>
</template>

<script setup>
import { onMounted, reactive, ref } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { commentList, commentUpdate } from '../../api/trade'
import { hasPerm } from '../../store/auth'
import { formatTime } from '../../utils/format'

const loading = ref(false)
const list = ref([])
const total = ref(0)
const query = reactive({ page: 1, page_size: 10, state: '', status: '' })

const rateMap = { 0: '好评', 1: '中评', 2: '差评' }
const rateTagMap = { 0: 'success', 1: 'warning', 2: 'danger' }
const rateText = (s) => rateMap[s] ?? '-'
const rateTag = (s) => rateTagMap[s] || 'info'

// 评论图片：兼容 JSON 数组与逗号分隔两种存储
function parseImages(images) {
  if (!images) return []
  try {
    const arr = JSON.parse(images)
    if (Array.isArray(arr)) return arr.filter(Boolean)
  } catch (_) {
    // ignore
  }
  return images.split(',').filter(Boolean)
}

async function load() {
  loading.value = true
  try {
    const body = { page: query.page, page_size: query.page_size }
    if (query.state) body.state = query.state
    if (query.status) body.status = query.status
    const resp = await commentList(body)
    list.value = resp?.data || []
    total.value = Number(resp?.total || 0)
  } catch (e) {
    ElMessage.error(e.message)
  } finally {
    loading.value = false
  }
}

function onSearch() {
  query.page = 1
  load()
}

async function onToggle(row) {
  const hide = row.status !== 'hidden'
  try {
    await ElMessageBox.confirm(hide ? '确定隐藏该评论？' : '确定显示该评论？', '提示', { type: 'warning' })
    await commentUpdate({ id: row.id, status: hide ? 'hidden' : 'normal' })
    ElMessage.success('操作成功')
    load()
  } catch (e) {
    if (e !== 'cancel') ElMessage.error(e.message)
  }
}

onMounted(load)
</script>

<style scoped>
.card-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
}
.pager {
  display: flex;
  justify-content: flex-end;
  margin-top: 12px;
}
.comment-imgs {
  display: flex;
  gap: 4px;
  margin-top: 4px;
  flex-wrap: wrap;
}
.comment-img {
  width: 44px;
  height: 44px;
  border-radius: 4px;
}
.goods-suk {
  color: #9ca3af;
  font-size: 12px;
}
</style>
