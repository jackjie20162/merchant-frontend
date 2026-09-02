<template>
  <div class="page">
    <el-card shadow="never" class="layout">
      <!-- 左侧目录 -->
      <div class="sidebar">
        <div class="sidebar-head">
          <span>图片目录</span>
          <el-link type="primary" :underline="false" @click="onAddGroup">+ 新建</el-link>
        </div>
        <div
          class="group-item"
          :class="{ active: activeGroup === 'all' }"
          @click="selectGroup('all')"
        >
          <span class="gname">全部图片</span>
        </div>
        <div
          class="group-item"
          :class="{ active: activeGroup === 0 }"
          @click="selectGroup(0)"
        >
          <span class="gname">未分组</span>
          <span class="gcount">{{ countMap[0] || 0 }}</span>
        </div>
        <div
          v-for="g in groups"
          :key="g.id"
          class="group-item"
          :class="{ active: activeGroup === g.id }"
          @click="selectGroup(g.id)"
        >
          <span class="gname" :title="g.name">{{ g.name }}</span>
          <span class="gcount">{{ countMap[g.id] || 0 }}</span>
          <span class="gops" @click.stop>
            <el-link type="primary" :underline="false" @click="onRenameGroup(g)">改名</el-link>
            <el-link type="danger" :underline="false" @click="onDeleteGroup(g)">删除</el-link>
          </span>
        </div>
        <el-empty v-if="groups.length === 0" description="暂无目录" :image-size="60" />
      </div>

      <!-- 右侧图片区 -->
      <div class="main">
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
          <el-dropdown :disabled="!selected.length" @command="onMoveSelected">
            <el-button :disabled="!selected.length">移动到目录</el-button>
            <template #dropdown>
              <el-dropdown-menu>
                <el-dropdown-item :command="0">未分组</el-dropdown-item>
                <el-dropdown-item v-for="g in groups" :key="g.id" :command="g.id">
                  {{ g.name }}
                </el-dropdown-item>
              </el-dropdown-menu>
            </template>
          </el-dropdown>
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
                <el-dropdown trigger="click" @command="(gid) => onMoveOne(item, gid)">
                  <el-link type="primary" :underline="false" @click.stop>移动</el-link>
                  <template #dropdown>
                    <el-dropdown-menu>
                      <el-dropdown-item :command="0">未分组</el-dropdown-item>
                      <el-dropdown-item v-for="g in groups" :key="g.id" :command="g.id">
                        {{ g.name }}
                      </el-dropdown-item>
                    </el-dropdown-menu>
                  </template>
                </el-dropdown>
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
      </div>
    </el-card>
  </div>
</template>

<script setup>
import { computed, onMounted, ref } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import {
  attachmentList,
  attachmentDelete,
  attachmentUpload,
  attachmentMove,
  attachmentGroupList,
  attachmentGroupSave,
  attachmentGroupDelete,
} from '../../api/attachment'

const loading = ref(false)
const uploading = ref(false)
const list = ref([])
const total = ref(0)
const page = ref(1)
const pageSize = 30
const selected = ref([])

const groups = ref([])
const countMap = ref({})
// 'all' | 0(未分组) | 分组id
const activeGroup = ref('all')

const previewUrls = computed(() => list.value.map((i) => i.url))

async function loadGroups() {
  try {
    const resp = await attachmentGroupList({ page: 1, page_size: 200 })
    groups.value = resp?.data || []
    const map = {}
    let ungrouped = 0
    for (const g of groups.value) {
      map[g.id] = Number(g.count || 0)
    }
    // 未分组数量 = 全部 - 已分组
    const all = Object.values(map).reduce((s, n) => s + n, 0)
    const totalResp = await attachmentList({ page: 1, page_size: 1 })
    const totalAll = Number(totalResp?.total || 0)
    ungrouped = Math.max(totalAll - all, 0)
    map[0] = ungrouped
    countMap.value = map
  } catch (e) {
    ElMessage.error(e.message)
  }
}

async function load() {
  loading.value = true
  try {
    const body = { page: page.value, page_size: pageSize }
    if (activeGroup.value !== 'all') body.group_id = activeGroup.value
    const resp = await attachmentList(body)
    list.value = resp?.data || []
    total.value = Number(resp?.total || 0)
    selected.value = selected.value.filter((id) => list.value.some((i) => i.id === id))
  } catch (e) {
    ElMessage.error(e.message)
  } finally {
    loading.value = false
  }
}

function selectGroup(gid) {
  activeGroup.value = gid
  page.value = 1
  selected.value = []
  load()
}

function toggleSelect(id) {
  const i = selected.value.indexOf(id)
  if (i >= 0) selected.value.splice(i, 1)
  else selected.value.push(id)
}

async function onUpload({ file }) {
  uploading.value = true
  try {
    const gid = typeof activeGroup.value === 'number' && activeGroup.value > 0 ? activeGroup.value : undefined
    await attachmentUpload(file, gid)
    ElMessage.success('上传成功')
    page.value = 1
    await Promise.all([load(), loadGroups()])
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
    await Promise.all([load(), loadGroups()])
  } catch (e) {
    ElMessage.error(e.message)
  }
}

const onDelete = (row) => doDelete([row.id])
const onDeleteSelected = () => doDelete(selected.value)

async function doMove(ids, groupId) {
  try {
    await attachmentMove(ids, groupId)
    ElMessage.success('移动成功')
    selected.value = []
    await Promise.all([load(), loadGroups()])
  } catch (e) {
    ElMessage.error(e.message)
  }
}

const onMoveOne = (row, groupId) => doMove([row.id], groupId)
const onMoveSelected = (groupId) => doMove(selected.value, groupId)

async function onAddGroup() {
  let name
  try {
    const r = await ElMessageBox.prompt('请输入目录名称', '新建目录', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      inputValidator: (v) => (v && v.trim() ? true : '名称不能为空'),
    })
    name = r.value.trim()
  } catch {
    return
  }
  try {
    await attachmentGroupSave({ name })
    ElMessage.success('创建成功')
    await loadGroups()
  } catch (e) {
    ElMessage.error(e.message)
  }
}

async function onRenameGroup(g) {
  let name
  try {
    const r = await ElMessageBox.prompt('请输入新的目录名称', '重命名', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      inputValue: g.name,
      inputValidator: (v) => (v && v.trim() ? true : '名称不能为空'),
    })
    name = r.value.trim()
  } catch {
    return
  }
  try {
    await attachmentGroupSave({ id: g.id, name })
    ElMessage.success('修改成功')
    await loadGroups()
  } catch (e) {
    ElMessage.error(e.message)
  }
}

async function onDeleteGroup(g) {
  try {
    await ElMessageBox.confirm(
      `确定删除目录「${g.name}」吗？目录内图片将归入未分组。`,
      '提示',
      { type: 'warning' },
    )
  } catch {
    return
  }
  try {
    await attachmentGroupDelete([g.id])
    ElMessage.success('删除成功')
    if (activeGroup.value === g.id) activeGroup.value = 'all'
    await Promise.all([load(), loadGroups()])
  } catch (e) {
    ElMessage.error(e.message)
  }
}

onMounted(() => {
  loadGroups()
  load()
})
</script>

<style scoped>
.page {
  padding: 16px;
}
.layout {
  display: flex;
  align-items: stretch;
}
.layout :deep(.el-card__body) {
  display: flex;
  width: 100%;
  padding: 0;
}
.sidebar {
  width: 200px;
  flex-shrink: 0;
  border-right: 1px solid #e5e7eb;
  padding: 12px 0;
}
.sidebar-head {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 12px 8px;
  font-weight: 600;
  color: #374151;
}
.group-item {
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 8px 12px;
  font-size: 13px;
  color: #4b5563;
  cursor: pointer;
}
.group-item:hover {
  background: #f9fafb;
}
.group-item.active {
  background: #fff7ed;
  color: #f59e0b;
  font-weight: 600;
}
.gname {
  flex: 1;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
.gcount {
  color: #9ca3af;
  font-size: 12px;
}
.gops {
  display: none;
  gap: 4px;
  white-space: nowrap;
}
.group-item:hover .gops {
  display: inline-flex;
}
.group-item:hover .gcount {
  display: none;
}
.main {
  flex: 1;
  min-width: 0;
  padding: 12px 16px;
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
  max-width: 60px;
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
