<template>
  <el-card>
    <template #header>
      <div class="card-header">
        <span>退款管理</span>
      </div>
    </template>

    <el-tabs v-model="query.state" @tab-change="onSearch">
      <el-tab-pane label="全部" name="" />
      <el-tab-pane label="待处理" name="0" />
      <el-tab-pane label="已同意" name="1" />
      <el-tab-pane label="待收货" name="3" />
      <el-tab-pane label="已拒绝" name="2" />
      <el-tab-pane label="已完成" name="7" />
    </el-tabs>

    <el-table :data="list" v-loading="loading" stripe>
      <el-table-column prop="id" label="ID" width="70" />
      <el-table-column prop="order_id" label="订单ID" width="90" />
      <el-table-column label="退款类型" width="100">
        <template #default="{ row }">
          <el-tag :type="row.type === '1' ? 'warning' : 'info'" size="small">
            {{ row.type === '1' ? '退货退款' : '仅退款' }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column label="退款金额" width="100">
        <template #default="{ row }">￥{{ formatPrice(row.price) }}</template>
      </el-table-column>
      <el-table-column prop="reason" label="退款原因" min-width="140" />
      <el-table-column label="状态" width="100">
        <template #default="{ row }">
          <el-tag :type="stateTag(row.state)" size="small">{{ stateText(row.state) }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="申请时间" width="170">
        <template #default="{ row }">{{ formatTime(row.createtime) }}</template>
      </el-table-column>
      <el-table-column label="操作" width="200" fixed="right">
        <template #default="{ row }">
          <el-button link type="primary" @click="openDetail(row)">详情</el-button>
          <el-button
            v-if="hasPerm('refund:audit') && row.state === '0'"
            link
            type="warning"
            @click="openAudit(row)"
          >
            审核
          </el-button>
          <el-button
            v-if="hasPerm('refund:audit') && row.state === '3'"
            link
            type="success"
            @click="onReceive(row)"
          >
            确认收货退款
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

    <!-- 退款详情抽屉 -->
    <el-drawer v-model="detail.visible" title="退款详情" size="520px">
      <div v-loading="detail.loading">
        <el-descriptions v-if="detail.info" :column="2" border size="small">
          <el-descriptions-item label="退款单ID">{{ detail.info.id }}</el-descriptions-item>
          <el-descriptions-item label="订单ID">{{ detail.info.order_id }}</el-descriptions-item>
          <el-descriptions-item label="退款类型">{{ detail.info.type === '1' ? '退货退款' : '仅退款' }}</el-descriptions-item>
          <el-descriptions-item label="退款金额">￥{{ formatPrice(detail.info.price) }}</el-descriptions-item>
          <el-descriptions-item label="状态">
            <el-tag :type="stateTag(detail.info.state)" size="small">{{ stateText(detail.info.state) }}</el-tag>
          </el-descriptions-item>
          <el-descriptions-item label="退货方式">{{ detail.info.express_type === '1' ? '买家退货' : '无需退货' }}</el-descriptions-item>
          <el-descriptions-item label="退款原因" :span="2">{{ detail.info.reason || '-' }}</el-descriptions-item>
          <el-descriptions-item label="退款说明" :span="2">{{ detail.info.refund_content || '-' }}</el-descriptions-item>
          <el-descriptions-item label="拒绝原因" :span="2">{{ detail.info.refuse_content || '-' }}</el-descriptions-item>
          <el-descriptions-item label="退货快递" :span="2">
            <span v-if="detail.info.express_no">{{ detail.info.express_name }} {{ detail.info.express_no }}</span>
            <span v-else>-</span>
          </el-descriptions-item>
          <el-descriptions-item label="申请时间">{{ formatTime(detail.info.createtime) }}</el-descriptions-item>
          <el-descriptions-item label="同意时间">{{ formatTime(detail.info.agreetime) }}</el-descriptions-item>
          <el-descriptions-item label="退货时间">{{ formatTime(detail.info.returntime) }}</el-descriptions-item>
          <el-descriptions-item label="完成时间">{{ formatTime(detail.info.completetime) }}</el-descriptions-item>
          <el-descriptions-item label="凭证图片" :span="2">
            <div v-if="parseImages(detail.info.images).length" class="evidence-imgs">
              <el-image
                v-for="(img, i) in parseImages(detail.info.images)"
                :key="i"
                :src="img"
                :preview-src-list="parseImages(detail.info.images)"
                :initial-index="i"
                class="evidence-img"
                fit="cover"
              />
            </div>
            <span v-else>-</span>
          </el-descriptions-item>
        </el-descriptions>

        <div v-if="detail.info" style="margin-top: 16px; display: flex; gap: 8px">
          <el-button
            v-if="hasPerm('refund:audit') && detail.info.state === '0'"
            type="warning"
            @click="openAudit(detail.info)"
          >
            审核
          </el-button>
          <el-button
            v-if="hasPerm('refund:audit') && detail.info.state === '3'"
            type="success"
            @click="onReceive(detail.info)"
          >
            确认收货退款
          </el-button>
        </div>
      </div>
    </el-drawer>

    <!-- 审核弹窗 -->
    <el-dialog v-model="audit.visible" title="退款审核" width="440px">
      <el-form label-width="90px">
        <el-form-item label="退款单ID">{{ audit.refund_id }}</el-form-item>
        <el-form-item label="退款金额">￥{{ formatPrice(audit.price) }}</el-form-item>
        <el-form-item label="审核结果" required>
          <el-radio-group v-model="audit.agree">
            <el-radio :value="true">{{ audit.type === '1' ? '同意退货' : '同意退款' }}</el-radio>
            <el-radio :value="false">拒绝</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item v-if="!audit.agree" label="拒绝原因" required>
          <el-input v-model="audit.refuse_content" type="textarea" :rows="3" placeholder="请输入拒绝原因" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="audit.visible = false">取消</el-button>
        <el-button type="primary" :loading="audit.saving" @click="onAudit">提交</el-button>
      </template>
    </el-dialog>
  </el-card>
</template>

<script setup>
import { onMounted, reactive, ref } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { refundList, refundDetail, refundAudit, refundReceive } from '../../api/trade'
import { hasPerm } from '../../store/auth'
import { formatTime, formatPrice } from '../../utils/format'

const loading = ref(false)
const list = ref([])
const total = ref(0)
const query = reactive({ page: 1, page_size: 10, state: '' })

const stateMap = {
  0: '待处理', 1: '已同意', 2: '已拒绝', 3: '待收货',
  4: '已收货', 5: '已拒收', 6: '已关闭', 7: '已完成', 8: '已撤销',
}
const stateTagMap = {
  0: 'warning', 1: 'primary', 2: 'danger', 3: 'warning',
  4: 'primary', 5: 'danger', 6: 'info', 7: 'success', 8: 'info',
}
const stateText = (s) => stateMap[s] || s || '-'
const stateTag = (s) => stateTagMap[s] || 'info'

// 凭证图片：兼容 JSON 数组与逗号分隔两种存储
function parseImages(images) {
  if (!images) return []
  try {
    const arr = JSON.parse(images)
    if (Array.isArray(arr)) return arr.filter(Boolean)
  } catch (_) {
    // ignore
  }
  return images.split(',').filter(Boolean)
}

async function load() {
  loading.value = true
  try {
    const body = { page: query.page, page_size: query.page_size }
    if (query.state) body.state = query.state
    const resp = await refundList(body)
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

// ===== 详情 =====
const detail = reactive({ visible: false, loading: false, info: null })

async function openDetail(row) {
  detail.visible = true
  detail.loading = true
  detail.info = null
  try {
    detail.info = await refundDetail(row.id)
  } catch (e) {
    ElMessage.error(e.message)
  } finally {
    detail.loading = false
  }
}

// ===== 审核 =====
const audit = reactive({ visible: false, saving: false, refund_id: 0, price: 0, type: '0', agree: true, refuse_content: '' })

function openAudit(row) {
  Object.assign(audit, {
    visible: true,
    refund_id: row.id,
    price: row.price,
    type: row.type,
    agree: true,
    refuse_content: '',
  })
}

async function onAudit() {
  if (!audit.agree && !audit.refuse_content) {
    ElMessage.warning('请填写拒绝原因')
    return
  }
  audit.saving = true
  try {
    await refundAudit({
      refund_id: audit.refund_id,
      agree: audit.agree,
      refuse_content: audit.refuse_content,
    })
    ElMessage.success('审核成功')
    audit.visible = false
    detail.visible = false
    load()
  } catch (e) {
    ElMessage.error(e.message)
  } finally {
    audit.saving = false
  }
}

// ===== 确认收货退款 =====
async function onReceive(row) {
  try {
    await ElMessageBox.confirm('确认已收到退货并完成退款？', '提示', { type: 'warning' })
    await refundReceive(row.id)
    ElMessage.success('退款完成')
    detail.visible = false
    load()
  } catch (e) {
    if (e !== 'cancel') ElMessage.error(e.message)
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
.evidence-imgs {
  display: flex;
  gap: 4px;
  flex-wrap: wrap;
}
.evidence-img {
  width: 60px;
  height: 60px;
  border-radius: 4px;
}
</style>
