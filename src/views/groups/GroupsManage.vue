<template>
  <el-card>
    <template #header>
      <div class="card-header">
        <span>拼团管理</span>
        <el-input
          v-model="query.group_no"
          placeholder="拼团编号"
          clearable
          style="width: 240px"
          @keyup.enter="onSearch"
          @clear="onSearch"
        />
      </div>
    </template>

    <el-tabs v-model="query.state" @tab-change="onSearch">
      <el-tab-pane label="全部" name="" />
      <el-tab-pane label="准备中" name="1" />
      <el-tab-pane label="拼团中" name="2" />
      <el-tab-pane label="已成团" name="3" />
      <el-tab-pane label="拼团失败" name="4" />
      <el-tab-pane label="自动成团" name="5" />
    </el-tabs>

    <el-table :data="list" v-loading="loading" stripe>
      <el-table-column prop="id" label="ID" width="70" />
      <el-table-column prop="group_no" label="拼团编号" min-width="180" />
      <el-table-column label="拼团类型" width="110">
        <template #default="{ row }">
          <el-tag :type="row.is_ladder === 1 ? 'success' : 'info'" size="small">
            {{ row.is_ladder === 1 ? '阶梯拼团' : '普通拼团' }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="goods_title" label="商品" min-width="180" show-overflow-tooltip />
      <el-table-column prop="user_id" label="团长ID" width="90" />
      <el-table-column label="拼团进度" width="130">
        <template #default="{ row }">{{ row.join_num || 0 }} / {{ row.people_num || 0 }}</template>
      </el-table-column>
      <el-table-column label="拼团状态" width="110">
        <template #default="{ row }">
          <el-tag :type="stateTag(row.state)" size="small">{{ stateText(row.state) }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="有效时间" width="170">
        <template #default="{ row }">{{ formatTime(row.validitytime) }}</template>
      </el-table-column>
      <el-table-column label="成团时间" width="170">
        <template #default="{ row }">{{ formatTime(row.grouptime) }}</template>
      </el-table-column>
      <!-- 商家端拼团记录只读，管理端可操作删除 -->
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
import { onMounted, reactive, ref } from 'vue'
import { ElMessage } from 'element-plus'
import { groupsList } from '../../api/groups'
import { formatTime } from '../../utils/format'

const loading = ref(false)
const list = ref([])
const total = ref(0)
const query = reactive({ page: 1, page_size: 10, state: '', group_no: '' })

const stateMap = {
  1: '准备中', 2: '拼团中', 3: '已成团', 4: '拼团失败', 5: '自动成团',
}
const stateTagMap = {
  1: 'info', 2: 'warning', 3: 'success', 4: 'danger', 5: 'primary',
}
const stateText = (s) => stateMap[s] || s || '-'
const stateTag = (s) => stateTagMap[s] || 'info'

async function load() {
  loading.value = true
  try {
    const body = { page: query.page, page_size: query.page_size }
    if (query.state) body.state = query.state
    if (query.group_no) body.group_no = query.group_no
    const resp = await groupsList(body)
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

onMounted(load)
</script>

<style scoped>
.card-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
}
.pager {
  display: flex;
  justify-content: flex-end;
  margin-top: 12px;
}
</style>
