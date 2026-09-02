<template>
  <el-card>
    <template #header>
      <div class="card-header">
        <span>拼团商品</span>
        <div class="header-actions">
          <el-button v-if="hasPerm('groups:goods:save')" type="primary" @click="goCreate">新增商品</el-button>
          <el-button v-if="hasPerm('groups:goods:save')" @click="onCopyFromShop">复制商城商品</el-button>
          <el-button v-if="hasPerm('groups:goods:delete')" @click="onBatchDelete">删除</el-button>
          <el-button @click="onRecycle">宝贝回收站</el-button>
        </div>
      </div>
    </template>

    <el-tabs v-model="tab" @tab-change="onTabChange">
      <el-tab-pane label="全部宝贝" name="all" />
      <el-tab-pane label="出售中宝贝" name="sale" />
      <el-tab-pane label="仓库中宝贝" name="warehouse" />
    </el-tabs>

    <div class="toolbar">
      <el-input
        v-model="query.title"
        placeholder="商品标题关键词"
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
      <el-table-column label="宝贝主图" width="90">
        <template #default="{ row }">
          <el-image v-if="row.image" :src="row.image" class="goods-img" fit="cover" :preview-src-list="[row.image]" />
          <span v-else>-</span>
        </template>
      </el-table-column>
      <el-table-column prop="title" label="商品标题" min-width="180" show-overflow-tooltip />
      <el-table-column label="拼团类型" width="110">
        <template #default="{ row }">
          <el-tag :type="row.is_ladder === 1 ? 'success' : 'info'" size="small">
            {{ row.is_ladder === 1 ? '阶梯拼团' : '普通拼团' }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column label="单买" width="80">
        <template #default="{ row }">{{ row.is_alone === 1 ? '是' : '否' }}</template>
      </el-table-column>
      <el-table-column prop="purchase_limit" label="限购" width="80" />
      <el-table-column label="拼团价" width="110">
        <template #default="{ row }">￥{{ formatPrice(row.price) }}</template>
      </el-table-column>
      <el-table-column prop="people_num" label="成团人数" width="90" />
      <el-table-column prop="group_hour" label="限时(小时)" width="100" />
      <el-table-column prop="sales" label="销量" width="80" />
      <el-table-column prop="views" label="点击" width="80" />
      <el-table-column label="状态" width="100">
        <template #default="{ row }">
          <el-tag :type="row.grounding === 1 ? 'success' : 'info'" size="small">
            {{ row.grounding === 1 ? '出售中' : '仓库中' }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column label="更新时间" width="170">
        <template #default="{ row }">{{ formatTime(row.updatetime) }}</template>
      </el-table-column>
      <el-table-column label="操作" width="220" fixed="right">
        <template #default="{ row }">
          <el-button v-if="hasPerm('groups:goods:save')" link type="primary" @click="goEdit(row)">编辑</el-button>
          <el-button v-if="hasPerm('groups:goods:save') && row.grounding === 1" link type="warning" @click="onGrounding(row, 0)">
            下架
          </el-button>
          <el-button v-if="hasPerm('groups:goods:save') && row.grounding === 0" link type="success" @click="onGrounding(row, 1)">
            上架
          </el-button>
          <el-button v-if="hasPerm('groups:goods:delete')" link type="danger" @click="onDelete(row)">删除</el-button>
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
import { onMounted, reactive, ref, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { groupsGoodsList, groupsGoodsDelete, groupsGoodsGrounding } from '../../api/groups'
import { hasPerm } from '../../store/auth'
import { formatTime, formatPrice } from '../../utils/format'

const route = useRoute()
const router = useRouter()

const tab = ref(route.query.tab || 'all')
const loading = ref(false)
const list = ref([])
const total = ref(0)
const selected = ref([])
const query = reactive({ page: 1, page_size: 10, title: '' })

function groundingByTab() {
  if (tab.value === 'sale') return 1
  if (tab.value === 'warehouse') return 0
  return undefined
}

async function load() {
  loading.value = true
  try {
    const body = { page: query.page, page_size: query.page_size }
    const grounding = groundingByTab()
    if (grounding !== undefined) body.grounding = grounding
    if (query.title) body.title = query.title
    const resp = await groupsGoodsList(body)
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
  query.title = ''
  load()
}

function goCreate() {
  router.push('/groups/goods/edit')
}

function goEdit(row) {
  router.push(`/groups/goods/edit/${row.id}`)
}

function onSelectionChange(rows) {
  selected.value = rows
}

async function onGrounding(row, val) {
  try {
    await ElMessageBox.confirm(val === 1 ? '确认上架该拼团商品？' : '确认下架该拼团商品？', '提示', { type: 'warning' })
    await groupsGoodsGrounding(row.id, val)
    ElMessage.success(val === 1 ? '已上架' : '已下架')
    load()
  } catch (e) {
    if (e !== 'cancel') ElMessage.error(e.message)
  }
}

async function onDelete(row) {
  try {
    await ElMessageBox.confirm('删除后不可恢复，确认删除该拼团商品？', '提示', { type: 'warning' })
    await groupsGoodsDelete([row.id])
    ElMessage.success('删除成功')
    load()
  } catch (e) {
    if (e !== 'cancel') ElMessage.error(e.message)
  }
}

async function onBatchDelete() {
  if (!selected.value.length) {
    ElMessage.warning('请先选择要删除的商品')
    return
  }
  try {
    await ElMessageBox.confirm(`确认删除选中的 ${selected.value.length} 个拼团商品？`, '提示', { type: 'warning' })
    await groupsGoodsDelete(selected.value.map((r) => r.id))
    ElMessage.success('删除成功')
    load()
  } catch (e) {
    if (e !== 'cancel') ElMessage.error(e.message)
  }
}

function onCopyFromShop() {
  ElMessage.info('复制商城商品功能需后端配合，待后续实现')
}

function onRecycle() {
  ElMessage.info('回收站功能需后端配合，待后续实现')
}

watch(
  () => route.query.tab,
  (val) => {
    if (val) tab.value = val
  },
)

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
  gap: 8px;
}
.toolbar {
  display: flex;
  gap: 8px;
  margin-bottom: 12px;
}
.goods-img {
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
