<template>
  <el-card>
    <template #header>
      <div class="card-header">
        <span>商品订单</span>
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
      <el-tab-pane label="待发货" name="2" />
      <el-tab-pane label="待收货" name="3" />
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
      <el-table-column label="快递" min-width="150">
        <template #default="{ row }">
          <span v-if="row.express_no">{{ row.express_name }} {{ row.express_no }}</span>
          <span v-else>-</span>
        </template>
      </el-table-column>
      <el-table-column label="下单时间" width="170">
        <template #default="{ row }">{{ formatTime(row.createtime) }}</template>
      </el-table-column>
      <el-table-column label="操作" width="150" fixed="right">
        <template #default="{ row }">
          <el-button link type="primary" @click="openDetail(row)">详情</el-button>
          <el-button
            v-if="hasPerm('order:deliver') && row.state === '2'"
            link
            type="success"
            @click="openDeliver(row)"
          >
            发货
          </el-button>
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

    <!-- 订单详情抽屉 -->
    <el-drawer v-model="detail.visible" title="订单详情" size="560px">
      <div v-loading="detail.loading">
        <template v-if="detail.order">
          <el-descriptions :column="2" border size="small" title="订单信息">
            <el-descriptions-item label="订单号" :span="2">{{ detail.order.order_no }}</el-descriptions-item>
            <el-descriptions-item label="状态">
              <el-tag :type="stateTag(detail.order.state)" size="small">{{ stateText(detail.order.state) }}</el-tag>
            </el-descriptions-item>
            <el-descriptions-item label="买家ID">{{ detail.order.user_id }}</el-descriptions-item>
            <el-descriptions-item label="下单时间">{{ formatTime(detail.order.createtime) }}</el-descriptions-item>
            <el-descriptions-item label="支付时间">{{ formatTime(detail.order.paymenttime) }}</el-descriptions-item>
            <el-descriptions-item label="发货时间">{{ formatTime(detail.order.delivertime) }}</el-descriptions-item>
            <el-descriptions-item label="收货时间">{{ formatTime(detail.order.taketime) }}</el-descriptions-item>
            <el-descriptions-item label="快递" :span="2">
              <span v-if="detail.order.express_no">{{ detail.order.express_name }} {{ detail.order.express_no }}</span>
              <span v-else>-</span>
            </el-descriptions-item>
            <el-descriptions-item label="买家备注" :span="2">{{ detail.order.remarks || '-' }}</el-descriptions-item>
          </el-descriptions>

          <div class="section-title">商品明细</div>
          <el-table :data="detail.goods" size="small" border>
            <el-table-column label="商品" min-width="220">
              <template #default="{ row }">
                <div class="goods-cell">
                  <el-image v-if="row.image" :src="row.image" class="goods-img" fit="cover" />
                  <div>
                    <div>{{ row.title }}</div>
                    <div class="goods-suk">{{ row.difference || '-' }}</div>
                  </div>
                </div>
              </template>
            </el-table-column>
            <el-table-column label="单价" width="90">
              <template #default="{ row }">￥{{ formatPrice(row.price) }}</template>
            </el-table-column>
            <el-table-column prop="number" label="数量" width="70" />
            <el-table-column label="实付" width="90">
              <template #default="{ row }">￥{{ formatPrice(row.actual_payment) }}</template>
            </el-table-column>
          </el-table>

          <div class="section-title">收货地址</div>
          <el-descriptions :column="1" border size="small">
            <el-descriptions-item label="收货人">{{ detail.address?.name || '-' }}</el-descriptions-item>
            <el-descriptions-item label="手机号">{{ detail.address?.mobile || '-' }}</el-descriptions-item>
            <el-descriptions-item label="地址">
              {{ detail.address ? `${detail.address.address_name || ''} ${detail.address.address || ''}` : '-' }}
            </el-descriptions-item>
          </el-descriptions>

          <div v-if="detail.order.state === '2' && hasPerm('order:deliver')" style="margin-top: 16px">
            <el-button type="primary" @click="openDeliver(detail.order)">发货</el-button>
          </div>
        </template>
      </div>
    </el-drawer>

    <!-- 发货弹窗 -->
    <el-dialog v-model="deliver.visible" title="订单发货" width="440px">
      <el-form label-width="90px">
        <el-form-item label="订单号">{{ deliver.order_no }}</el-form-item>
        <el-form-item label="快递公司" required>
          <el-select
            v-model="deliver.express_name"
            filterable
            allow-create
            default-first-option
            placeholder="选择或输入快递公司"
            style="width: 100%"
          >
            <el-option v-for="n in expressNames" :key="n" :label="n" :value="n" />
          </el-select>
        </el-form-item>
        <el-form-item label="快递单号" required>
          <el-input v-model="deliver.express_no" placeholder="请输入快递单号" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="deliver.visible = false">取消</el-button>
        <el-button type="primary" :loading="deliver.saving" @click="onDeliver">确认发货</el-button>
      </template>
    </el-dialog>
  </el-card>
</template>

<script setup>
import { onMounted, reactive, ref } from 'vue'
import { ElMessage } from 'element-plus'
import { orderList, orderDetail, orderDeliver } from '../../api/trade'
import { hasPerm } from '../../store/auth'
import { formatTime, formatPrice } from '../../utils/format'

const loading = ref(false)
const list = ref([])
const total = ref(0)
const query = reactive({ page: 1, page_size: 10, state: '', order_no: '' })

const stateMap = {
  1: '待支付', 2: '待发货', 3: '待收货', 4: '待评价',
  5: '售后订单', 6: '已完成', 7: '已取消',
}
const stateTagMap = {
  1: 'info', 2: 'warning', 3: 'primary', 4: 'primary',
  5: 'danger', 6: 'success', 7: 'info',
}
const stateText = (s) => stateMap[s] || s || '-'
const stateTag = (s) => stateTagMap[s] || 'info'

const expressNames = ['顺丰速运', '中通快递', '圆通速递', '韵达快递', '申通快递', '邮政快递包裹', '京东物流', '德邦快递']

async function load() {
  loading.value = true
  try {
    const body = { page: query.page, page_size: query.page_size }
    if (query.state) body.state = query.state
    if (query.order_no) body.order_no = query.order_no
    const resp = await orderList(body)
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

// ===== 详情抽屉 =====
const detail = reactive({ visible: false, loading: false, order: null, goods: [], address: null })

async function openDetail(row) {
  detail.visible = true
  detail.loading = true
  detail.order = null
  detail.goods = []
  detail.address = null
  try {
    const resp = await orderDetail(row.id)
    detail.order = resp?.order || null
    detail.goods = resp?.goods || []
    detail.address = resp?.address || null
  } catch (e) {
    ElMessage.error(e.message)
  } finally {
    detail.loading = false
  }
}

// ===== 发货 =====
const deliver = reactive({ visible: false, saving: false, order_id: 0, order_no: '', express_name: '', express_no: '' })

function openDeliver(row) {
  Object.assign(deliver, {
    visible: true,
    order_id: row.id,
    order_no: row.order_no,
    express_name: row.express_name || '',
    express_no: '',
  })
}

async function onDeliver() {
  if (!deliver.express_name || !deliver.express_no) {
    ElMessage.warning('请填写快递公司与快递单号')
    return
  }
  deliver.saving = true
  try {
    await orderDeliver({
      order_id: deliver.order_id,
      express_name: deliver.express_name,
      express_no: deliver.express_no,
    })
    ElMessage.success('发货成功')
    deliver.visible = false
    detail.visible = false
    load()
  } catch (e) {
    ElMessage.error(e.message)
  } finally {
    deliver.saving = false
  }
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
.section-title {
  font-weight: 600;
  margin: 16px 0 8px;
}
.goods-cell {
  display: flex;
  align-items: center;
  gap: 8px;
}
.goods-img {
  width: 44px;
  height: 44px;
  border-radius: 4px;
  flex-shrink: 0;
}
.goods-suk {
  color: #9ca3af;
  font-size: 12px;
}
</style>
