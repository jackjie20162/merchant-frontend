<template>
  <div class="page">
    <el-card shadow="never">
      <div class="toolbar">
        <el-input
          v-model="keyword"
          placeholder="优惠券名称"
          clearable
          style="width: 200px"
          @keyup.enter="onSearch"
        />
        <el-button type="primary" @click="onSearch">搜索</el-button>
        <el-button @click="openForm()">新增优惠券</el-button>
      </div>

      <el-tabs v-model="activeTab" @tab-change="onTabChange">
        <el-tab-pane label="全部" name="" />
        <el-tab-pane label="满减" name="reduction" />
        <el-tab-pane label="折扣" name="discount" />
        <el-tab-pane label="包邮" name="shipping" />
      </el-tabs>

      <el-table v-loading="loading" :data="list">
        <el-table-column prop="id" label="ID" width="70" />
        <el-table-column prop="name" label="优惠券名称" min-width="140" />
        <el-table-column label="类型" width="90">
          <template #default="{ row }">
            <el-tag :type="typeTag(row.type)" size="small">{{ typeName(row.type) }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="优惠信息" min-width="160">
          <template #default="{ row }">
            <span v-if="row.type === 'reduction'">满 {{ formatPrice(row.limit) }} 减 {{ formatPrice(row.price) }}</span>
            <span v-else-if="row.type === 'discount'">{{ row.discount }} 折</span>
            <span v-else-if="row.type === 'shipping'">包邮</span>
            <span v-else class="muted">-</span>
          </template>
        </el-table-column>
        <el-table-column label="适用范围" width="100">
          <template #default="{ row }">{{ rangeName(row.rangetype) }}</template>
        </el-table-column>
        <el-table-column label="有效期" min-width="170">
          <template #default="{ row }">
            <span v-if="row.pretype === 'appoint' && row.startdate">{{ row.startdate }} ~ {{ row.enddate }}</span>
            <span v-else>领取后 {{ row.validity }} 天</span>
          </template>
        </el-table-column>
        <el-table-column prop="surplus" label="剩余" width="70" />
        <el-table-column label="状态" width="80">
          <template #default="{ row }">
            <el-tag v-if="row.status === 'normal'" type="success" size="small">正常</el-tag>
            <el-tag v-else type="info" size="small">隐藏</el-tag>
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
    <el-dialog v-model="dialogVisible" :title="form.id ? '编辑优惠券' : '新增优惠券'" width="640px">
      <el-form :model="form" label-width="100px">
        <el-form-item label="优惠券名称">
          <el-input v-model="form.name" maxlength="50" placeholder="如：新人满减券" />
        </el-form-item>
        <el-form-item label="优惠券类型">
          <el-select v-model="form.type" style="width: 200px">
            <el-option label="满减券" value="reduction" />
            <el-option label="折扣券" value="discount" />
            <el-option label="包邮券" value="shipping" />
            <el-option label="会员券" value="vip" />
          </el-select>
        </el-form-item>
        <el-form-item label="优惠方式">
          <el-select v-model="form.usertype" style="width: 200px">
            <el-option label="满减" value="reduction" />
            <el-option label="折扣" value="discount" />
          </el-select>
        </el-form-item>
        <el-form-item label="用户等级">
          <el-select v-model="form.userlevel" style="width: 200px">
            <el-option label="全部用户" value="0" />
            <el-option label="等级 1" value="1" />
            <el-option label="等级 2" value="2" />
            <el-option label="等级 3" value="3" />
            <el-option label="等级 4" value="4" />
            <el-option label="等级 5" value="5" />
          </el-select>
        </el-form-item>
        <el-form-item v-if="form.usertype === 'reduction'" label="优惠金额">
          <el-input-number v-model="form.price" :min="0" :precision="2" :step="1" />
          <span class="hint">元</span>
        </el-form-item>
        <el-form-item v-if="form.usertype === 'discount'" label="折扣率">
          <el-input-number v-model="form.discount" :min="0.1" :max="9.9" :precision="1" :step="0.5" />
          <span class="hint">折（如 9.5 = 95 折）</span>
        </el-form-item>
        <el-form-item label="使用门槛">
          <el-input-number v-model="form.limit" :min="0" :precision="2" :step="10" />
          <span class="hint">满多少元可用，0 = 无门槛</span>
        </el-form-item>
        <el-form-item label="适用范围">
          <el-radio-group v-model="form.rangetype" @change="onRangeTypeChange">
            <el-radio value="all">全店通用</el-radio>
            <el-radio value="goods">指定商品</el-radio>
            <el-radio value="category">指定类目</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item v-if="form.rangetype !== 'all'" :label="form.rangetype === 'goods' ? '指定商品' : '指定类目'">
          <div class="range-box">
            <el-button plain type="primary" @click="scopeVisible = true">
              选择{{ form.rangetype === 'goods' ? '商品' : '类目' }}
            </el-button>
            <template v-if="rangeItems.length">
              <el-tag
                v-for="it in rangeItems.slice(0, 12)"
                :key="it.id"
                size="small"
                closable
                @close="removeRangeItem(it)"
              >
                {{ it.name }}
              </el-tag>
              <span v-if="rangeItems.length > 12" class="hint">共 {{ rangeItems.length }} 个</span>
            </template>
            <span v-else class="hint">未选择</span>
          </div>
        </el-form-item>
        <el-form-item label="有效期方式">
          <el-radio-group v-model="form.pretype">
            <el-radio value="fixed">领取后 N 天</el-radio>
            <el-radio value="appoint">指定时间段</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item v-if="form.pretype === 'fixed'" label="有效天数">
          <el-input-number v-model="form.validity" :min="1" :max="365" />
          <span class="hint">天</span>
        </el-form-item>
        <el-form-item v-if="form.pretype === 'appoint'" label="起止日期">
          <el-date-picker
            v-model="form.startdate"
            type="date"
            value-format="YYYY-MM-DD"
            placeholder="开始日期"
            style="width: 160px"
          />
          <span class="hint">至</span>
          <el-date-picker
            v-model="form.enddate"
            type="date"
            value-format="YYYY-MM-DD"
            placeholder="结束日期"
            style="width: 160px"
          />
        </el-form-item>
        <el-form-item label="每人限领">
          <el-input-number v-model="form.drawlimit" :min="1" :max="99" />
          <span class="hint">张</span>
        </el-form-item>
        <el-form-item label="发放方式">
          <el-radio-group v-model="form.grant">
            <el-radio value="auto">自动发放</el-radio>
            <el-radio value="manual">手动发放</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="使用说明">
          <el-input v-model="form.content" type="textarea" :rows="2" maxlength="500" />
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

    <!-- 指定商品/类目选择弹窗 -->
    <ScopePicker
      v-model:visible="scopeVisible"
      :type="form.rangetype === 'category' ? 'category' : 'goods'"
      :model-value="form.range"
      @confirm="onScopeConfirm"
    />
  </div>
</template>

<script setup>
import { onMounted, ref } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { couponList, couponSave, couponDelete } from '../../api/marketing'
import { formatPrice } from '../../utils/format'
import ScopePicker from '../../components/ScopePicker.vue'

const loading = ref(false)
const list = ref([])
const total = ref(0)
const page = ref(1)
const pageSize = 20
const keyword = ref('')
const activeTab = ref('')

function typeName(t) {
  return { reduction: '满减', discount: '折扣', shipping: '包邮', vip: '会员' }[t] || t || '-'
}
function typeTag(t) {
  return { reduction: 'danger', discount: 'warning', shipping: 'success', vip: 'primary' }[t] || 'info'
}
function rangeName(t) {
  return { all: '全店通用', goods: '指定商品', category: '指定类目' }[t] || '-'
}

async function load() {
  loading.value = true
  try {
    const body = {
      page: page.value,
      page_size: pageSize,
      name: keyword.value || undefined,
    }
    if (activeTab.value) body.type = activeTab.value
    const resp = await couponList(body)
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

function onTabChange() {
  page.value = 1
  load()
}

// ===== 新增/编辑 =====
const dialogVisible = ref(false)
const saving = ref(false)
const form = ref(emptyForm())
const scopeVisible = ref(false)
// 已选范围项 { id, name }，回显用（编辑时名称未知显示 #ID，弹窗确认后替换为真实名称）
const rangeItems = ref([])

function emptyForm() {
  return {
    id: 0,
    type: 'reduction',
    name: '',
    userlevel: '0',
    usertype: 'reduction',
    price: 0,
    discount: 9.5,
    limit: 0,
    rangetype: 'all',
    range: '',
    pretype: 'fixed',
    validity: 7,
    startdate: '',
    enddate: '',
    drawlimit: 1,
    grant: 'auto',
    content: '',
    status: 'normal',
  }
}

function openForm(row) {
  form.value = row
    ? {
        id: row.id,
        type: row.type || 'reduction',
        name: row.name || '',
        // userlevel 为 int 列，统一转为数字字符串；usertype 为 enum，非法/空时回退 reduction
        userlevel: String(row.userlevel ?? '0'),
        usertype: row.usertype === 'discount' ? 'discount' : 'reduction',
        price: Number(row.price || 0),
        discount: Number(row.discount || 9.5),
        limit: Number(row.limit || 0),
        rangetype: row.rangetype || 'all',
        range: row.range || '',
        pretype: row.pretype === 'appoint' ? 'appoint' : 'fixed',
        validity: Number(row.validity || 7),
        startdate: row.startdate || '',
        enddate: row.enddate || '',
        drawlimit: Number(row.drawlimit || 1),
        grant: row.grant === 'manual' ? 'manual' : 'auto',
        content: row.content || '',
        status: row.status === 'hidden' ? 'hidden' : 'normal',
      }
    : emptyForm()
  rangeItems.value = (form.value.range || '')
    .split(',')
    .map((s) => Number(String(s).trim()))
    .filter((n) => n > 0)
    .map((id) => ({ id, name: `#${id}` }))
  dialogVisible.value = true
}

// 切换适用范围类型时清空已选
function onRangeTypeChange() {
  form.value.range = ''
  rangeItems.value = []
}

function onScopeConfirm({ ids, items }) {
  form.value.range = ids
  rangeItems.value = items
}

function removeRangeItem(it) {
  rangeItems.value = rangeItems.value.filter((x) => x.id !== it.id)
  form.value.range = rangeItems.value.map((x) => x.id).join(',')
}

async function onSave() {
  if (!form.value.name?.trim()) {
    ElMessage.warning('请输入优惠券名称')
    return
  }
  if (form.value.rangetype !== 'all' && !form.value.range?.trim()) {
    ElMessage.warning(form.value.rangetype === 'goods' ? '请选择指定商品' : '请选择指定类目')
    return
  }
  if (form.value.pretype === 'appoint' && (!form.value.startdate || !form.value.enddate)) {
    ElMessage.warning('请选择有效期起止日期')
    return
  }
  saving.value = true
  try {
    await couponSave({
      ...form.value,
      id: form.value.id || undefined,
      // DB 约束：userlevel 为 int、usertype 为 enum，必须传合法值
      userlevel: String(form.value.userlevel || '0'),
      usertype: form.value.usertype || 'reduction',
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
    await ElMessageBox.confirm(`确定删除优惠券「${row.name}」吗？`, '提示', { type: 'warning' })
  } catch {
    return
  }
  try {
    await couponDelete([row.id])
    ElMessage.success('删除成功')
    await load()
  } catch (e) {
    ElMessage.error(e.message)
  }
}

onMounted(() => {
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
  margin-bottom: 8px;
}
.pager {
  display: flex;
  justify-content: flex-end;
  margin-top: 12px;
}
.muted {
  color: #9ca3af;
}
.hint {
  margin-left: 8px;
  color: #9ca3af;
  font-size: 12px;
}
.range-box {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  gap: 6px;
}
</style>
