<template>
  <el-card>
    <template #header>
      <div class="card-header">
        <span>拼团订单</span>
        <el-input
          v-model="query.order_no"
          placeholder="订单号"
          clearable
          style="width: 240px"
          @keyup.enter="onSearch"
          @clear="onSearch"
        />
      </div>
    </template>

    <el-tabs v-model="query.state" @tab-change="onSearch">
      <el-tab-pane label="全部" name="" />
      <el-tab-pane label="待成团" name="2" />
      <el-tab-pane label="待发货" name="3" />
      <el-tab-pane label="待收货" name="4" />
      <el-tab-pane label="已完成" name="6" />
      <el-tab-pane label="已取消" name="7" />
    </el-tabs>

    <el-table :data="list" v-loading="loading" stripe>
      <el-table-column prop="order_no" label="订单号" min-width="180" />
      <el-table-column prop="user_id" label="买家ID" width="90" />
      <el-table-column label="状态" width="100">
        <template #default="{ row }">
          <el-tag :type="stateTag(row.state)" size="small">{{ stateText(row.state) }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="成团时间" width="170">
        <template #default="{ row }">{{ formatTime(row.groupstime) }}</template>
      </el-table-column>
      <el-table-column label="快递" min-width="150">
        <template #default="{ row }">
          <span v-if="row.express_no">{{ row.express_name }} {{ row.express_no }}</span>
          <span v-else>-</span>
        </template>
      </el-table-column>
      <el-table-column label="下单时间" width="170">
        <template #default="{ row }">{{ formatTime(row.createtime) }}</template>
      </el-table-column>
      <el-table-column label="备注" min-width="120">
        <template #default="{ row }">{{ row.remarks || '-' }}</template>
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
import { onMounted, reactive, ref } from 'vue'
import { ElMessage } from 'element-plus'
import { groupsOrderList } from '../../api/trade'
import { formatTime } from '../../utils/format'

const loading = ref(false)
const list = ref([])
const total = ref(0)
const query = reactive({ page: 1, page_size: 10, state: '', order_no: '' })

const stateMap = {
  1: '待支付', 2: '待成团', 3: '待发货', 4: '待收货',
  5: '待评论', 6: '已完成', 7: '已取消',
}
const stateTagMap = {
  1: 'info', 2: 'warning', 3: 'warning', 4: 'primary',
  5: 'primary', 6: 'success', 7: 'info',
}
const stateText = (s) => stateMap[s] || s || '-'
const stateTag = (s) => stateTagMap[s] || 'info'

async function load() {
  loading.value = true
  try {
    const body = { page: query.page, page_size: query.page_size }
    if (query.state) body.state = query.state
    if (query.order_no) body.order_no = query.order_no
    const resp = await groupsOrderList(body)
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
