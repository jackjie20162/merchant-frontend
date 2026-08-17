<template>
  <el-dialog
    v-model="visible"
    :title="type === 'goods' ? '选择指定商品' : '选择指定类目'"
    width="680px"
    append-to-body
    @open="onOpen"
  >
    <!-- 指定类目：本店自定义类目树（多选） -->
    <div v-if="type === 'category'" v-loading="loading" class="cat-wrap">
      <el-tree
        v-if="tree.length"
        ref="treeRef"
        :data="tree"
        node-key="id"
        show-checkbox
        check-strictly
        default-expand-all
        :props="{ label: 'name', children: 'children' }"
      />
      <el-empty
        v-if="!loading && !tree.length"
        description="本店暂无自定义类目，请先到「店铺设置 - 类目管理」维护"
        :image-size="70"
      />
    </div>

    <!-- 指定商品：出售中商品列表，搜索 + 跨页多选 -->
    <div v-else>
      <div class="toolbar">
        <el-input
          v-model="keyword"
          placeholder="商品标题关键词"
          clearable
          style="width: 220px"
          @keyup.enter="onSearch"
          @clear="onSearch"
        />
        <el-button type="primary" @click="onSearch">搜索</el-button>
        <span class="picked-hint">已选 {{ pickedCount }} 个</span>
      </div>

      <el-table
        ref="tableRef"
        v-loading="loading"
        :data="list"
        row-key="id"
        max-height="340"
        @selection-change="onSelectionChange"
      >
        <el-table-column type="selection" width="45" />
        <el-table-column prop="id" label="ID" width="70" />
        <el-table-column label="主图" width="70">
          <template #default="{ row }">
            <el-image v-if="row.image" :src="row.image" class="g-img" fit="cover" />
            <span v-else class="muted">-</span>
          </template>
        </el-table-column>
        <el-table-column prop="title" label="商品标题" min-width="200" show-overflow-tooltip />
        <el-table-column label="价格" width="90">
          <template #default="{ row }">￥{{ formatPrice(row.price) }}</template>
        </el-table-column>
      </el-table>

      <div class="pager">
        <el-pagination
          v-model:current-page="page"
          :page-size="pageSize"
          :total="total"
          layout="total, prev, pager, next"
          @current-change="loadGoods"
        />
      </div>
    </div>

    <template #footer>
      <el-button @click="visible = false">取消</el-button>
      <el-button type="primary" @click="onConfirm">确定</el-button>
    </template>
  </el-dialog>
</template>

<script setup>
import { computed, nextTick, ref } from 'vue'
import { ElMessage } from 'element-plus'
import { goodsList, shopCategoryTree } from '../api/goods'
import { formatPrice } from '../utils/format'

const props = defineProps({
  // goods=指定商品 category=指定类目
  type: { type: String, default: 'goods' },
  // 已选 ID，英文逗号分隔
  modelValue: { type: String, default: '' },
})
const emit = defineEmits(['confirm'])
const visible = defineModel('visible', { type: Boolean, default: false })

const loading = ref(false)
// id -> { id, name }，跨页保持已选
const picked = ref(new Map())
const pickedCount = computed(() => picked.value.size)

function parseIds(value) {
  return (value || '')
    .split(',')
    .map((s) => Number(String(s).trim()))
    .filter((n) => n > 0)
}

function onOpen() {
  picked.value = new Map(parseIds(props.modelValue).map((id) => [id, { id, name: `#${id}` }]))
  if (props.type === 'category') {
    loadTree()
  } else {
    page.value = 1
    keyword.value = ''
    loadGoods()
  }
}

// ===== 类目模式 =====
const tree = ref([])
const treeRef = ref(null)

async function loadTree() {
  loading.value = true
  try {
    const resp = await shopCategoryTree()
    tree.value = Array.isArray(resp) ? resp : []
    await nextTick()
    treeRef.value?.setCheckedKeys([...picked.value.keys()])
  } catch (e) {
    tree.value = []
    ElMessage.error(e.message)
  } finally {
    loading.value = false
  }
}

function findName(nodes, id) {
  for (const n of nodes || []) {
    if (n.id === id) return n.name
    if (n.children?.length) {
      const found = findName(n.children, id)
      if (found) return found
    }
  }
  return `#${id}`
}

// ===== 商品模式 =====
const tableRef = ref(null)
const list = ref([])
const total = ref(0)
const page = ref(1)
const pageSize = 10
const keyword = ref('')
// 加载数据/程序化勾选期间屏蔽 selection-change，避免误清已选
let syncing = false

async function loadGoods() {
  loading.value = true
  try {
    const body = { page: page.value, page_size: pageSize, grounding: 1 }
    if (keyword.value) body.title = keyword.value
    const resp = await goodsList(body)
    syncing = true
    list.value = resp?.data || []
    total.value = Number(resp?.total || 0)
    await nextTick()
    // 回显已选（含不在当前页数据里的历史勾选）
    for (const r of list.value) {
      if (picked.value.has(r.id)) tableRef.value?.toggleRowSelection(r, true)
    }
  } catch (e) {
    ElMessage.error(e.message)
  } finally {
    loading.value = false
    await nextTick()
    syncing = false
  }
}

function onSearch() {
  page.value = 1
  loadGoods()
}

function onSelectionChange(rows) {
  if (syncing) return
  const rowIds = new Set(list.value.map((r) => r.id))
  // 当前页被取消勾选的移除
  for (const id of [...picked.value.keys()]) {
    if (rowIds.has(id) && !rows.some((r) => r.id === id)) picked.value.delete(id)
  }
  // 新勾选的加入
  for (const r of rows) picked.value.set(r.id, { id: r.id, name: r.title })
}

// ===== 确认 =====
function onConfirm() {
  let items
  if (props.type === 'category') {
    const keys = treeRef.value?.getCheckedKeys() || []
    items = keys.map((id) => ({ id, name: findName(tree.value, id) }))
  } else {
    items = [...picked.value.values()]
  }
  if (!items.length) {
    ElMessage.warning(props.type === 'goods' ? '请至少选择一个商品' : '请至少选择一个类目')
    return
  }
  emit('confirm', { ids: items.map((i) => i.id).join(','), items })
  visible.value = false
}
</script>

<style scoped>
.cat-wrap {
  min-height: 200px;
  max-height: 400px;
  overflow-y: auto;
  border: 1px solid #e5e7eb;
  border-radius: 6px;
  padding: 8px;
}
.toolbar {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 8px;
}
.picked-hint {
  margin-left: auto;
  color: #6b7280;
  font-size: 12px;
}
.g-img {
  width: 40px;
  height: 40px;
  border-radius: 4px;
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
