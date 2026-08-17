<template>
  <div class="page">
    <el-card shadow="never">
      <div class="toolbar">
        <el-upload :show-file-list="false" :http-request="onUpload" accept="image/*" multiple>
          <el-button type="primary" :loading="uploading">上传图片</el-button>
        </el-upload>
        <el-button @click="load">刷新</el-button>
        <el-button
          type="danger"
          plain
          :disabled="!selected.length"
          @click="onDeleteSelected"
        >
          删除选中（{{ selected.length }}）
        </el-button>
        <span class="tip">支持 jpg/png/gif/webp/bmp/svg，单张不超过 10MB</span>
      </div>

      <div v-loading="loading" class="grid">
        <div
          v-for="item in list"
          :key="item.id"
          class="item"
          :class="{ active: selected.includes(item.id) }"
          @click="toggleSelect(item.id)"
        >
          <el-image :src="item.url" fit="cover" class="img" :preview-src-list="previewUrls" />
          <span v-if="selected.includes(item.id)" class="check">✓</span>
          <div class="meta">
            <span class="name" :title="item.name">{{ item.name }}</span>
            <span class="ops">
              <el-link type="primary" :underline="false" @click.stop="copyUrl(item.url)">复制</el-link>
              <el-link type="danger" :underline="false" @click.stop="onDelete(item)">删除</el-link>
            </span>
          </div>
        </div>
        <el-empty v-if="!loading && list.length === 0" description="暂无图片，请上传" />
      </div>

      <div class="pager">
        <el-pagination
          v-model:current-page="page"
          :page-size="pageSize"
          :total="total"
          layout="total, prev, pager, next"
          @current-change="load"
        />
      </div>
    </el-card>
  </div>
</template>

<script setup>
import { computed, onMounted, ref } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { attachmentList, attachmentDelete, attachmentUpload } from '../../api/attachment'

const loading = ref(false)
const uploading = ref(false)
const list = ref([])
const total = ref(0)
const page = ref(1)
const pageSize = 30
const selected = ref([])

const previewUrls = computed(() => list.value.map((i) => i.url))

async function load() {
  loading.value = true
  try {
    const resp = await attachmentList({ page: page.value, page_size: pageSize })
    list.value = resp?.data || []
    total.value = Number(resp?.total || 0)
    selected.value = selected.value.filter((id) => list.value.some((i) => i.id === id))
  } catch (e) {
    ElMessage.error(e.message)
  } finally {
    loading.value = false
  }
}

function toggleSelect(id) {
  const i = selected.value.indexOf(id)
  if (i >= 0) selected.value.splice(i, 1)
  else selected.value.push(id)
}

async function onUpload({ file }) {
  uploading.value = true
  try {
    await attachmentUpload(file)
    ElMessage.success('上传成功')
    page.value = 1
    await load()
  } catch (e) {
    ElMessage.error(e.message)
  } finally {
    uploading.value = false
  }
}

function copyUrl(url) {
  const full = new URL(url, window.location.origin).href
  navigator.clipboard
    ?.writeText(full)
    .then(() => ElMessage.success('链接已复制'))
    .catch(() => ElMessage.warning('复制失败，请手动复制'))
}

async function doDelete(ids) {
  try {
    await ElMessageBox.confirm(`确定删除选中的 ${ids.length} 张图片吗？`, '提示', { type: 'warning' })
  } catch {
    return
  }
  try {
    await attachmentDelete(ids)
    ElMessage.success('删除成功')
    selected.value = []
    await load()
  } catch (e) {
    ElMessage.error(e.message)
  }
}

const onDelete = (row) => doDelete([row.id])
const onDeleteSelected = () => doDelete(selected.value)

onMounted(load)
</script>

<style scoped>
.page {
  padding: 16px;
}
.toolbar {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 16px;
}
.tip {
  color: #6b7280;
  font-size: 12px;
}
.grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(150px, 1fr));
  gap: 12px;
  min-height: 140px;
}
.item {
  position: relative;
  border: 2px solid transparent;
  border-radius: 6px;
  overflow: hidden;
  background: #fff;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.08);
  cursor: pointer;
}
.item.active {
  border-color: #f59e0b;
}
.img {
  width: 100%;
  height: 110px;
  display: block;
}
.check {
  position: absolute;
  top: 4px;
  right: 4px;
  width: 18px;
  height: 18px;
  line-height: 18px;
  text-align: center;
  background: #f59e0b;
  color: #fff;
  border-radius: 50%;
  font-size: 12px;
}
.meta {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 4px 8px;
  font-size: 12px;
}
.name {
  color: #374151;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  max-width: 80px;
}
.ops {
  display: flex;
  gap: 6px;
  white-space: nowrap;
}
.pager {
  display: flex;
  justify-content: flex-end;
  margin-top: 12px;
}
</style>
