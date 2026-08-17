<template>
  <div class="page">
    <el-card shadow="never">
      <div class="toolbar">
        <el-input
          v-model="keyword"
          placeholder="品牌名称"
          clearable
          style="width: 200px"
          @keyup.enter="onSearch"
        />
        <el-button type="primary" @click="onSearch">搜索</el-button>
        <el-button @click="openForm()">新增品牌</el-button>
      </div>

      <el-table v-loading="loading" :data="list">
        <el-table-column prop="id" label="ID" width="70" />
        <el-table-column label="品牌图标" width="80">
          <template #default="{ row }">
            <el-image v-if="row.image" :src="row.image" fit="cover" style="width: 40px; height: 40px" />
            <span v-else class="muted">-</span>
          </template>
        </el-table-column>
        <el-table-column prop="name" label="品牌名称" min-width="140" />
        <el-table-column label="关联类目" min-width="160">
          <template #default="{ row }">
            <span>{{ categoryName(row.category_id) || '-' }}</span>
          </template>
        </el-table-column>
        <el-table-column prop="weigh" label="排序" width="70" />
        <el-table-column label="状态" width="90">
          <template #default="{ row }">
            <el-tag v-if="row.is_switch === 1" type="success" size="small">启用</el-tag>
            <el-tag v-else type="info" size="small">停用</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="130">
          <template #default="{ row }">
            <el-button link type="primary" @click="openForm(row)">编辑</el-button>
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

    <!-- 新增/编辑弹窗 -->
    <el-dialog v-model="dialogVisible" :title="form.id ? '编辑品牌' : '新增品牌'" width="520px">
      <el-form :model="form" label-width="90px">
        <el-form-item label="品牌名称">
          <el-input v-model="form.name" maxlength="50" />
        </el-form-item>
        <el-form-item label="品牌图标">
          <ImagePicker v-model="form.image" :multiple="false" :max="1" />
        </el-form-item>
        <el-form-item label="关联类目">
          <el-cascader
            v-model="categoryIds"
            :options="catOptions"
            :props="{ value: 'id', label: 'name', children: 'children', multiple: true, checkStrictly: true, emitPath: false }"
            clearable
            collapse-tags
            placeholder="可多选，不选为全部类目"
            style="width: 100%"
          />
        </el-form-item>
        <el-form-item label="品牌介绍">
          <el-input v-model="form.content" type="textarea" :rows="3" maxlength="500" />
        </el-form-item>
        <el-form-item label="排序">
          <el-input-number v-model="form.weigh" :min="0" :max="999" />
        </el-form-item>
        <el-form-item label="是否启用">
          <el-switch v-model="form.is_switch" :active-value="1" :inactive-value="0" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="saving" @click="onSave">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { onMounted, ref } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { brandListAll, brandSave, brandDelete, categoryTree } from '../../api/shop'
import ImagePicker from '../../components/ImagePicker.vue'

const loading = ref(false)
const list = ref([])
const total = ref(0)
const page = ref(1)
const pageSize = 20
const keyword = ref('')

// 类目选项与名称映射（关联类目展示用）
const catOptions = ref([])
const catNameMap = new Map()

async function loadCats() {
  try {
    const tree = (await categoryTree('goods')) || []
    catOptions.value = tree
    const walk = (nodes) => {
      for (const n of nodes) {
        catNameMap.set(n.id, n.name)
        if (n.children?.length) walk(n.children)
      }
    }
    walk(tree)
  } catch (e) {
    // 类目拉取失败不阻塞品牌页
  }
}

function categoryName(idsStr) {
  if (!idsStr) return ''
  return String(idsStr)
    .split(',')
    .filter(Boolean)
    .map((id) => catNameMap.get(Number(id)) || id)
    .join('、')
}

async function load() {
  loading.value = true
  try {
    const resp = await brandListAll({
      page: page.value,
      page_size: pageSize,
      name: keyword.value || undefined,
    })
    list.value = resp?.data || []
    total.value = Number(resp?.total || 0)
  } catch (e) {
    ElMessage.error(e.message)
  } finally {
    loading.value = false
  }
}

function onSearch() {
  page.value = 1
  load()
}

// ===== 新增/编辑 =====
const dialogVisible = ref(false)
const saving = ref(false)
const form = ref(emptyForm())
const categoryIds = ref([])

function emptyForm() {
  return { id: 0, name: '', image: '', content: '', weigh: 0, is_switch: 1 }
}

function openForm(row) {
  form.value = row
    ? {
        id: row.id,
        name: row.name || '',
        image: row.image || '',
        content: row.content || '',
        weigh: row.weigh || 0,
        is_switch: row.is_switch ?? 1,
      }
    : emptyForm()
  categoryIds.value = row?.category_id
    ? String(row.category_id).split(',').filter(Boolean).map(Number)
    : []
  dialogVisible.value = true
}

async function onSave() {
  if (!form.value.name?.trim()) {
    ElMessage.warning('请输入品牌名称')
    return
  }
  saving.value = true
  try {
    await brandSave({
      ...form.value,
      id: form.value.id || undefined,
      category_id: categoryIds.value.join(','),
    })
    ElMessage.success('保存成功')
    dialogVisible.value = false
    await load()
  } catch (e) {
    ElMessage.error(e.message)
  } finally {
    saving.value = false
  }
}

async function onDelete(row) {
  try {
    await ElMessageBox.confirm(`确定删除品牌「${row.name}」吗？`, '提示', { type: 'warning' })
  } catch {
    return
  }
  try {
    await brandDelete([row.id])
    ElMessage.success('删除成功')
    await load()
  } catch (e) {
    ElMessage.error(e.message)
  }
}

onMounted(() => {
  loadCats()
  load()
})
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
.pager {
  display: flex;
  justify-content: flex-end;
  margin-top: 12px;
}
.muted {
  color: #9ca3af;
}
</style>
