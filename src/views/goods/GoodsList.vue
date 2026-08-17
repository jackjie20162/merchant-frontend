<template>
  <el-card>
    <template #header>
      <div class="card-header">
        <span>{{ isSale ? '出售中的商品' : '仓库中的商品' }}</span>
        <el-button v-if="hasPerm('goods:save')" type="primary" @click="goCreate">发布商品</el-button>
      </div>
    </template>

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

    <el-table :data="list" v-loading="loading" stripe>
      <el-table-column prop="id" label="ID" width="70" />
      <el-table-column label="主图" width="90">
        <template #default="{ row }">
          <el-image v-if="row.image" :src="row.image" class="goods-img" fit="cover" :preview-src-list="[row.image]" />
          <span v-else>-</span>
        </template>
      </el-table-column>
      <el-table-column prop="title" label="商品标题" min-width="220" show-overflow-tooltip />
      <el-table-column label="价格" width="100">
        <template #default="{ row }">￥{{ formatPrice(row.price) }}</template>
      </el-table-column>
      <el-table-column prop="sales" label="销量" width="80" />
      <el-table-column prop="views" label="浏览量" width="90" />
      <el-table-column label="上架状态" width="100">
        <template #default="{ row }">
          <el-tag :type="row.grounding === 1 ? 'success' : 'info'" size="small">
            {{ row.grounding === 1 ? '出售中' : '仓库中' }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column label="创建时间" width="170">
        <template #default="{ row }">{{ formatTime(row.createtime) }}</template>
      </el-table-column>
      <el-table-column label="操作" width="220" fixed="right">
        <template #default="{ row }">
          <el-button v-if="hasPerm('goods:save')" link type="primary" @click="goEdit(row)">编辑</el-button>
          <el-button v-if="hasPerm('goods:save') && row.grounding === 1" link type="warning" @click="onGrounding(row, 0)">
            下架
          </el-button>
          <el-button v-if="hasPerm('goods:save') && row.grounding === 0" link type="success" @click="onGrounding(row, 1)">
            上架
          </el-button>
          <el-button v-if="hasPerm('goods:delete')" link type="danger" @click="onDelete(row)">删除</el-button>
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
import { computed, onMounted, reactive, ref, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { goodsList, goodsDelete, goodsGrounding } from '../../api/goods'
import { hasPerm } from '../../store/auth'
import { formatTime, formatPrice } from '../../utils/format'

const route = useRoute()
const router = useRouter()

// 出售中/仓库中两路由复用本页签，grounding 由路由 meta 决定
const grounding = computed(() => Number(route.meta?.grounding ?? 1))
const isSale = computed(() => grounding.value === 1)

const loading = ref(false)
const list = ref([])
const total = ref(0)
const query = reactive({ page: 1, page_size: 10, title: '' })

async function load() {
  loading.value = true
  try {
    const body = { page: query.page, page_size: query.page_size, grounding: grounding.value }
    if (query.title) body.title = query.title
    const resp = await goodsList(body)
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

function goCreate() {
  router.push('/goods/edit')
}

function goEdit(row) {
  router.push(`/goods/edit/${row.id}`)
}

async function onGrounding(row, val) {
  try {
    await ElMessageBox.confirm(val === 1 ? '确认上架该商品？' : '确认下架该商品？', '提示', { type: 'warning' })
    await goodsGrounding(row.id, val)
    ElMessage.success(val === 1 ? '已上架' : '已下架')
    load()
  } catch (e) {
    if (e !== 'cancel') ElMessage.error(e.message)
  }
}

async function onDelete(row) {
  try {
    await ElMessageBox.confirm('删除后不可恢复，确认删除该商品？', '提示', { type: 'warning' })
    await goodsDelete([row.id])
    ElMessage.success('删除成功')
    load()
  } catch (e) {
    if (e !== 'cancel') ElMessage.error(e.message)
  }
}

// 两路由间切换时（组件复用）重新加载
watch(grounding, () => {
  query.page = 1
  query.title = ''
  load()
})

onMounted(load)
</script>

<style scoped>
.card-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
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
