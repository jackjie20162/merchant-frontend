<template>
  <div class="page">
    <el-card shadow="never">
      <div class="toolbar">
        <el-button type="primary" @click="openCreate">新建页面</el-button>
        <el-button @click="load">刷新</el-button>
      </div>

      <el-table v-loading="loading" :data="list">
        <el-table-column label="封面" width="100">
          <template #default="{ row }">
            <el-image v-if="row.cover" :src="row.cover" fit="cover" style="width: 60px; height: 40px" />
            <span v-else class="muted">-</span>
          </template>
        </el-table-column>
        <el-table-column prop="name" label="页面名称" min-width="160" />
        <el-table-column label="类型" width="100">
          <template #default="{ row }">
            <el-tag size="small" :type="row.type === 'shop' ? 'warning' : 'info'">
              {{ typeLabel(row.type) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="更新时间" width="170">
          <template #default="{ row }">{{ formatTime(row.updatetime) }}</template>
        </el-table-column>
        <el-table-column label="操作" width="140">
          <template #default="{ row }">
            <el-button link type="primary" @click="enterEdit(row)">装修</el-button>
            <el-button link type="danger" @click="onDelete(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>

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

    <!-- 新建页面弹窗 -->
    <el-dialog v-model="createVisible" title="新建页面" width="520px">
      <el-form label-width="90px">
        <el-form-item label="页面名称">
          <el-input v-model="newName" placeholder="如：店铺首页" maxlength="30" />
        </el-form-item>
        <el-form-item label="页面模板">
          <el-radio-group v-model="tplId">
            <el-radio :value="0">空白页面</el-radio>
            <el-radio v-for="t in templates" :key="t.id" :value="t.id">
              {{ t.name }}
            </el-radio>
          </el-radio-group>
          <p class="tip">选择平台模板将复制模板的组件与页面配置，模板本身不可修改</p>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="createVisible = false">取消</el-button>
        <el-button type="primary" :loading="creating" @click="onCreate">创建并装修</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { onMounted, ref } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { pageList, pageDetail, pageSave, pageDelete } from '../../api/page'
import { formatTime } from '../../utils/format'

const router = useRouter()

const loading = ref(false)
const list = ref([])
const total = ref(0)
const page = ref(1)
const pageSize = 20

function typeLabel(type) {
  return { shop: '店铺页', page: '单页', index: '首页' }[type] || type
}

async function load() {
  loading.value = true
  try {
    const resp = await pageList({ page: page.value, page_size: pageSize })
    list.value = resp?.data || []
    total.value = Number(resp?.total || 0)
  } catch (e) {
    ElMessage.error(e.message)
  } finally {
    loading.value = false
  }
}

function enterEdit(row) {
  router.push(`/shop/diy/${row.id}`)
}

async function onDelete(row) {
  try {
    await ElMessageBox.confirm(`确定删除页面「${row.name}」吗？`, '提示', { type: 'warning' })
  } catch {
    return
  }
  try {
    await pageDelete([row.id])
    ElMessage.success('删除成功')
    await load()
  } catch (e) {
    ElMessage.error(e.message)
  }
}

// ===== 新建 =====
const createVisible = ref(false)
const creating = ref(false)
const newName = ref('')
const tplId = ref(0)
const templates = ref([])

async function openCreate() {
  newName.value = ''
  tplId.value = 0
  createVisible.value = true
  try {
    const resp = await pageList({ page: 1, page_size: 50, type: 'systpl' })
    templates.value = resp?.data || []
  } catch {
    templates.value = []
  }
}

async function onCreate() {
  if (!newName.value.trim()) {
    ElMessage.warning('请输入页面名称')
    return
  }
  creating.value = true
  try {
    let pageConfStr = ''
    let itemStr = '[]'
    if (tplId.value) {
      const tpl = await pageDetail(tplId.value)
      pageConfStr = tpl?.page || ''
      itemStr = tpl?.item || '[]'
    }
    const resp = await pageSave({
      name: newName.value,
      type: 'page',
      page: pageConfStr,
      item: itemStr,
    })
    ElMessage.success('创建成功')
    createVisible.value = false
    router.push(`/shop/diy/${resp.id}`)
  } catch (e) {
    ElMessage.error(e.message)
  } finally {
    creating.value = false
  }
}

onMounted(load)
</script>

<style scoped>
.page {
  padding: 16px;
}
.toolbar {
  display: flex;
  gap: 8px;
  margin-bottom: 16px;
}
.pager {
  display: flex;
  justify-content: flex-end;
  margin-top: 12px;
}
.muted {
  color: #9ca3af;
}
.tip {
  color: #9ca3af;
  font-size: 12px;
  margin-top: 4px;
}
</style>
