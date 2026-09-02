<template>
  <div>
    <div class="toolbar">
      <el-input v-model="keyword" placeholder="搜索旅游产品" clearable @keyup.enter="load" />
      <el-input v-model="destination" placeholder="目的地" clearable @keyup.enter="load" />
      <el-button type="primary" :loading="loading" @click="load">查询</el-button>
    </div>
    <el-table :data="items" v-loading="loading" stripe>
      <el-table-column prop="id" label="ID" width="90" />
      <el-table-column prop="title" label="产品名称" min-width="220" />
      <el-table-column prop="destination" label="目的地" width="150" />
      <el-table-column prop="currency" label="币种" width="90" />
      <el-table-column prop="minPrice" label="起价" width="120" />
      <el-table-column prop="status" label="状态" width="110" />
    </el-table>
    <el-pagination v-model:current-page="page" v-model:page-size="pageSize" :total="total" layout="total, prev, pager, next" @current-change="load" />
  </div>
</template>

<script setup>
import { onMounted, ref } from 'vue'
import { ElMessage } from 'element-plus'
import { listTravelProducts } from '../../api/travel'

const keyword = ref('')
const destination = ref('')
const page = ref(1)
const pageSize = ref(20)
const total = ref(0)
const items = ref([])
const loading = ref(false)

async function load() {
  loading.value = true
  try {
    const data = await listTravelProducts({ keyword: keyword.value, destination: destination.value, page: page.value, pageSize: pageSize.value })
    items.value = data.items || []
    total.value = data.total || 0
  } catch (e) { ElMessage.error(e.message) } finally { loading.value = false }
}

onMounted(load)
</script>

<style scoped>
.toolbar { display: flex; gap: 12px; margin-bottom: 16px; }
.toolbar .el-input { width: 220px; }
.el-pagination { margin-top: 16px; }
</style>
