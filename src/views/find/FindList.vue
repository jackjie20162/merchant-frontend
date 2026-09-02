<template>
  <el-card>
    <template #header>
      <div class="card-header">
        <span>{{ recycle ? '种草短视频 - 回收站' : '种草短视频' }}</span>
        <div class="header-actions">
          <el-button @click="load">刷新</el-button>
          <el-dropdown v-if="!recycle && hasPerm('find:publish')" @command="openCreate" style="margin-right: 8px">
            <el-button type="primary">发布<span class="dropdown-arrow">▾</span></el-button>
            <template #dropdown>
              <el-dropdown-menu>
                <el-dropdown-item v-for="t in typeOptions" :key="t.value" :command="t.value">
                  {{ t.label }}
                </el-dropdown-item>
              </el-dropdown-menu>
            </template>
          </el-dropdown>
          <el-button v-if="hasPerm(recycle ? 'find:restore' : 'find:delete')" @click="onBatchAction">
            {{ recycle ? '恢复' : '删除' }}
          </el-button>
          <el-button :type="recycle ? 'warning' : 'default'" @click="toggleRecycle">
            {{ recycle ? '返回列表' : '回收站' }}
          </el-button>
        </div>
      </div>
    </template>

    <el-tabs v-if="!recycle" v-model="tab" @tab-change="onTabChange">
      <el-tab-pane label="全部" name="all" />
      <el-tab-pane v-for="t in typeOptions" :key="t.value" :label="t.label" :name="t.value" />
    </el-tabs>

    <el-alert v-if="recycle" type="info" :closable="false" style="margin-bottom: 12px">
      当前为回收站视图，展示已删除的动态，可勾选后批量恢复。
    </el-alert>

    <div class="toolbar">
      <el-input
        v-model="query.content"
        placeholder="内容关键词"
        clearable
        style="width: 220px"
        @keyup.enter="onSearch"
        @clear="onSearch"
      />
      <el-button type="primary" @click="onSearch">搜索</el-button>
    </div>

    <el-table :data="list" v-loading="loading" stripe @selection-change="onSelectionChange">
      <el-table-column type="selection" width="50" />
      <el-table-column prop="id" label="ID" width="70" />
      <el-table-column label="类型" width="100">
        <template #default="{ row }">
          <el-tag size="small">{{ typeLabel(row.type) }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="图片组" width="90">
        <template #default="{ row }">
          <el-image
            v-if="firstImage(row.images)"
            :src="firstImage(row.images)"
            class="find-img"
            fit="cover"
            :preview-src-list="row.images ? row.images.split(',') : []"
          />
          <span v-else>-</span>
        </template>
      </el-table-column>
      <el-table-column label="创作号" width="120">
        <template #default="{ row }">{{ row.user_no || '-' }}</template>
      </el-table-column>
      <el-table-column prop="views" label="浏览量" width="80" />
      <el-table-column prop="likes" label="点赞" width="80" />
      <el-table-column prop="comments" label="评论" width="80" />
      <el-table-column label="发现状态" width="110">
        <template #default="{ row }">
          <el-tag :type="stateTagType(row.state)" size="small">{{ stateLabel(row.state) }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="更新时间" width="170">
        <template #default="{ row }">{{ formatTime(row.updatetime) }}</template>
      </el-table-column>
      <el-table-column label="操作" width="160" fixed="right">
        <template #default="{ row }">
          <template v-if="recycle">
            <el-button v-if="hasPerm('find:restore')" link type="success" @click="onRestore([row.id])">恢复</el-button>
          </template>
          <template v-else>
            <el-button v-if="hasPerm('find:publish')" link type="primary" @click="openEdit(row)">编辑</el-button>
            <el-button v-if="hasPerm('find:delete')" link type="danger" @click="onDelete(row)">删除</el-button>
          </template>
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

    <!-- 发布/编辑弹窗 -->
    <el-dialog v-model="dialog.visible" :title="dialog.isEdit ? '编辑动态' : '发布动态'" width="640px">
      <el-form :model="form" label-width="90px">
        <el-form-item label="类型" required>
          <el-select v-model="form.type" style="width: 200px">
            <el-option v-for="t in typeOptions" :key="t.value" :label="t.label" :value="t.value" />
          </el-select>
        </el-form-item>
        <el-form-item label="内容" required>
          <el-input v-model="form.content" type="textarea" :rows="4" placeholder="动态文案内容" maxlength="500" show-word-limit />
        </el-form-item>
        <el-form-item label="图片组">
          <ImagePicker v-model="form.images" multiple :max="9" />
        </el-form-item>
        <el-form-item v-if="form.type === 'video' || form.type === 'live'" label="视频ID">
          <el-input v-model="form.video_id" placeholder="关联视频ID（可选）" />
        </el-form-item>
        <el-form-item label="关联商品">
          <el-input v-model="form.goods_ids" placeholder="商品ID，多个用逗号分隔（可选）" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialog.visible = false">取消</el-button>
        <el-button type="primary" :loading="saving" @click="onSave">保存</el-button>
      </template>
    </el-dialog>
  </el-card>
</template>

<script setup>
import { onMounted, reactive, ref } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { findList, findCreate, findUpdate, findDelete, findRestore } from '../../api/find'
import { hasPerm } from '../../store/auth'
import { formatTime } from '../../utils/format'
import ImagePicker from '../../components/ImagePicker.vue'

const typeOptions = [
  { value: 'new', label: '上新' },
  { value: 'video', label: '短视频' },
  { value: 'live', label: '直播' },
  { value: 'want', label: '种草' },
  { value: 'activity', label: '活动' },
  { value: 'show', label: '买家秀' },
]

const stateMap = {
  publish: '发布中',
  examine: '待审核',
  hazard: '危险内容',
  transcoding: '转码中',
  screenshot: '截图中',
  normal: '发布成功',
}

const tab = ref('all')
const recycle = ref(false)
const loading = ref(false)
const saving = ref(false)
const list = ref([])
const total = ref(0)
const selected = ref([])
const query = reactive({ page: 1, page_size: 10, content: '' })

const dialog = reactive({ visible: false, isEdit: false })
const form = reactive({ id: null, type: 'want', content: '', images: '', video_id: '', goods_ids: '' })

function typeLabel(type) {
  return typeOptions.find((t) => t.value === type)?.label || type || '-'
}

function stateLabel(state) {
  return stateMap[state] || state || '-'
}

function stateTagType(state) {
  if (state === 'normal') return 'success'
  if (state === 'hazard') return 'danger'
  if (state === 'examine') return 'warning'
  return 'info'
}

function firstImage(images) {
  return images ? images.split(',')[0] : ''
}

async function load() {
  loading.value = true
  try {
    const body = { page: query.page, page_size: query.page_size }
    if (tab.value !== 'all') body.type = tab.value
    if (query.content) body.content = query.content
    if (recycle.value) body.recycle = true
    const resp = await findList(body)
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

function onTabChange() {
  query.page = 1
  load()
}

function toggleRecycle() {
  recycle.value = !recycle.value
  query.page = 1
  query.content = ''
  load()
}

function onSelectionChange(rows) {
  selected.value = rows
}

function openCreate(type) {
  Object.assign(form, { id: null, type, content: '', images: '', video_id: '', goods_ids: '' })
  dialog.isEdit = false
  dialog.visible = true
}

function openEdit(row) {
  Object.assign(form, {
    id: row.id,
    type: row.type || 'want',
    content: row.content || '',
    images: row.images || '',
    video_id: row.video_id || '',
    goods_ids: row.goods_ids || '',
  })
  dialog.isEdit = true
  dialog.visible = true
}

async function onSave() {
  if (!form.content.trim()) {
    ElMessage.warning('请填写内容')
    return
  }
  saving.value = true
  try {
    const body = {
      type: form.type,
      content: form.content,
      images: form.images,
      state: 'normal',
    }
    if (form.video_id) body.video_id = form.video_id
    if (form.goods_ids) body.goods_ids = form.goods_ids
    if (dialog.isEdit) {
      body.id = form.id
      await findUpdate(body)
      ElMessage.success('保存成功')
    } else {
      await findCreate(body)
      ElMessage.success('发布成功')
    }
    dialog.visible = false
    load()
  } catch (e) {
    ElMessage.error(e.message)
  } finally {
    saving.value = false
  }
}

async function onDelete(row) {
  try {
    await ElMessageBox.confirm('删除后将移入回收站，确认删除该动态？', '提示', { type: 'warning' })
    await findDelete([row.id])
    ElMessage.success('删除成功')
    load()
  } catch (e) {
    if (e !== 'cancel') ElMessage.error(e.message)
  }
}

async function onRestore(ids) {
  try {
    await ElMessageBox.confirm('确认恢复选中的动态？', '提示', { type: 'warning' })
    await findRestore(ids)
    ElMessage.success('恢复成功')
    load()
  } catch (e) {
    if (e !== 'cancel') ElMessage.error(e.message)
  }
}

function onBatchAction() {
  if (!selected.value.length) {
    ElMessage.warning(recycle.value ? '请先选择要恢复的动态' : '请先选择要删除的动态')
    return
  }
  const ids = selected.value.map((r) => r.id)
  if (recycle.value) {
    onRestore(ids)
    return
  }
  ElMessageBox.confirm(`确认删除选中的 ${ids.length} 条动态？删除后移入回收站。`, '提示', { type: 'warning' })
    .then(() => findDelete(ids))
    .then(() => {
      ElMessage.success('删除成功')
      load()
    })
    .catch((e) => {
      if (e !== 'cancel') ElMessage.error(e.message)
    })
}

onMounted(load)
</script>

<style scoped>
.card-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
}
.header-actions {
  display: flex;
  align-items: center;
  gap: 8px;
}
.dropdown-arrow {
  margin-left: 4px;
  font-size: 12px;
}
.toolbar {
  display: flex;
  gap: 8px;
  margin-bottom: 12px;
}
.find-img {
  width: 60px;
  height: 60px;
  border-radius: 4px;
}
.pager {
  display: flex;
  justify-content: flex-end;
  margin-top: 12px;
}
</style>
