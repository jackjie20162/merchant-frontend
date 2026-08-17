<template>
  <div class="page">
    <el-card shadow="never">
      <div class="toolbar">
        <el-radio-group v-model="type" @change="load">
          <el-radio-button value="goods">商品类目</el-radio-button>
          <el-radio-button value="article">文章类目</el-radio-button>
        </el-radio-group>
        <el-button type="primary" @click="openCreate()">新增顶级类目</el-button>
        <el-button @click="load">刷新</el-button>
      </div>

      <el-table
        v-loading="loading"
        :data="tree"
        row-key="id"
        :tree-props="{ children: 'children' }"
        default-expand-all
      >
        <el-table-column prop="name" label="类目名称" min-width="180" />
        <el-table-column label="图片" width="80">
          <template #default="{ row }">
            <el-image v-if="row.image" :src="row.image" fit="cover" style="width: 40px; height: 40px" />
            <span v-else class="muted">-</span>
          </template>
        </el-table-column>
        <el-table-column prop="weigh" label="排序" width="80" />
        <el-table-column label="导航显示" width="100">
          <template #default="{ row }">
            <el-tag v-if="row.isnav === 1" type="success" size="small">显示</el-tag>
            <el-tag v-else type="info" size="small">隐藏</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="状态" width="80">
          <template #default="{ row }">
            <el-tag v-if="row.status === 'normal'" type="success" size="small">正常</el-tag>
            <el-tag v-else type="info" size="small">隐藏</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="160">
          <template #default="{ row }">
            <el-button link type="primary" @click="openCreate(row)">添加子类</el-button>
            <el-button link type="primary" @click="openEdit(row)">编辑</el-button>
            <el-button link type="danger" @click="onDelete(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>

    <!-- 新增/编辑弹窗 -->
    <el-dialog v-model="dialogVisible" :title="form.id ? '编辑类目' : '新增类目'" width="520px">
      <el-form :model="form" label-width="90px">
        <el-form-item label="上级类目">
          <el-cascader
            v-model="pidPath"
            :options="pidOptions"
            :props="{ value: 'id', label: 'name', children: 'children', checkStrictly: true, emitPath: true }"
            clearable
            placeholder="不选则为顶级类目"
            style="width: 100%"
          />
        </el-form-item>
        <el-form-item label="类目名称">
          <el-input v-model="form.name" placeholder="请输入类目名称" maxlength="50" />
        </el-form-item>
        <el-form-item label="类目图片">
          <ImagePicker v-model="form.image" :multiple="false" :max="1" />
        </el-form-item>
        <el-form-item label="排序">
          <el-input-number v-model="form.weigh" :min="0" :max="999" />
        </el-form-item>
        <el-form-item label="导航显示">
          <el-switch v-model="form.isnav" :active-value="1" :inactive-value="0" />
        </el-form-item>
        <el-form-item label="状态">
          <el-radio-group v-model="form.status">
            <el-radio value="normal">正常</el-radio>
            <el-radio value="hidden">隐藏</el-radio>
          </el-radio-group>
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
import { computed, onMounted, ref } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { categoryTree, categorySave, categoryDelete } from '../../api/shop'
import ImagePicker from '../../components/ImagePicker.vue'

const type = ref('goods')
const loading = ref(false)
const tree = ref([])

async function load() {
  loading.value = true
  try {
    tree.value = (await categoryTree(type.value)) || []
  } catch (e) {
    ElMessage.error(e.message)
  } finally {
    loading.value = false
  }
}

// ===== 新增/编辑 =====
const dialogVisible = ref(false)
const saving = ref(false)
const form = ref(emptyForm())
const pidPath = ref([])

function emptyForm() {
  return { id: 0, pid: 0, name: '', image: '', weigh: 0, isnav: 1, status: 'normal' }
}

// 上级选项 = 当前树（编辑时排除自身子树，防止循环）
const pidOptions = computed(() => {
  if (!form.value.id) return tree.value
  const excludeId = form.value.id
  const filter = (nodes) =>
    nodes
      .filter((n) => n.id !== excludeId)
      .map((n) => ({ ...n, children: n.children?.length ? filter(n.children) : undefined }))
  return filter(tree.value)
})

function openCreate(parent) {
  form.value = emptyForm()
  form.value.pid = parent?.id || 0
  pidPath.value = parent ? findPath(tree.value, parent.id) : []
  dialogVisible.value = true
}

function openEdit(row) {
  form.value = {
    id: row.id,
    pid: row.pid || 0,
    name: row.name,
    image: row.image || '',
    weigh: row.weigh || 0,
    isnav: row.isnav ?? 1,
    status: row.status || 'normal',
  }
  pidPath.value = row.pid ? findPath(tree.value, row.pid) : []
  dialogVisible.value = true
}

// 在树中找节点 id 的完整路径
function findPath(nodes, id, path = []) {
  for (const n of nodes) {
    const next = [...path, n.id]
    if (n.id === id) return next
    if (n.children?.length) {
      const found = findPath(n.children, id, next)
      if (found) return found
    }
  }
  return null
}

async function onSave() {
  if (!form.value.name?.trim()) {
    ElMessage.warning('请输入类目名称')
    return
  }
  saving.value = true
  try {
    await categorySave({
      ...form.value,
      id: form.value.id || undefined,
      pid: pidPath.value.length ? pidPath.value[pidPath.value.length - 1] : 0,
      type: type.value,
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
  if (row.children?.length) {
    ElMessage.warning('请先删除子类目')
    return
  }
  try {
    await ElMessageBox.confirm(`确定删除类目「${row.name}」吗？`, '提示', { type: 'warning' })
  } catch {
    return
  }
  try {
    await categoryDelete([row.id])
    ElMessage.success('删除成功')
    await load()
  } catch (e) {
    ElMessage.error(e.message)
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
  align-items: center;
  gap: 12px;
  margin-bottom: 16px;
}
.muted {
  color: #9ca3af;
}
</style>
