<template>
  <div class="page">
    <el-card shadow="never">
      <div class="toolbar">
        <el-input
          v-model="keyword"
          placeholder="模板名称"
          clearable
          style="width: 200px"
          @keyup.enter="onSearch"
        />
        <el-button type="primary" @click="onSearch">搜索</el-button>
        <el-button @click="openForm()">新增模板</el-button>
      </div>

      <el-tabs v-model="activeTab" @tab-change="onTabChange">
        <el-tab-pane label="全部" name="" />
        <el-tab-pane label="正常" name="normal" />
        <el-tab-pane label="隐藏" name="hidden" />
      </el-tabs>

      <el-table v-loading="loading" :data="list">
        <el-table-column prop="id" label="ID" width="70" />
        <el-table-column prop="name" label="模板名称" min-width="160" />
        <el-table-column label="发货时间" width="120">
          <template #default="{ row }">{{ deliveryName(row.delivery) }}</template>
        </el-table-column>
        <el-table-column label="运费方式" width="110">
          <template #default="{ row }">
            <el-tag v-if="row.isdelivery === '1'" type="success" size="small">卖家包邮</el-tag>
            <el-tag v-else type="warning" size="small">自定义运费</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="计价方式" width="100">
          <template #default="{ row }">{{ valuationName(row.valuation) }}</template>
        </el-table-column>
        <el-table-column label="状态" width="80">
          <template #default="{ row }">
            <el-tag v-if="row.status === 'normal'" type="success" size="small">正常</el-tag>
            <el-tag v-else type="info" size="small">隐藏</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="创建时间" width="170">
          <template #default="{ row }">{{ formatTime(row.createtime) }}</template>
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
    <el-dialog v-model="dialogVisible" :title="form.id ? '编辑运费模板' : '新增运费模板'" width="860px">
      <el-form :model="form" label-width="90px">
        <el-form-item label="模板名称">
          <el-input v-model="form.name" maxlength="50" placeholder="如：默认运费模板" style="width: 320px" />
        </el-form-item>
        <el-form-item label="发货时间">
          <el-select v-model="form.delivery" style="width: 200px">
            <el-option v-for="opt in deliveryOptions" :key="opt.value" :label="opt.label" :value="opt.value" />
          </el-select>
        </el-form-item>
        <el-form-item label="运费方式">
          <el-radio-group v-model="form.isdelivery">
            <el-radio value="0">自定义运费</el-radio>
            <el-radio value="1">卖家包邮</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="计价方式">
          <el-radio-group v-model="form.valuation">
            <el-radio value="0">按件数</el-radio>
            <el-radio value="1">按重量</el-radio>
            <el-radio value="2">按体积</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="状态">
          <el-radio-group v-model="form.status">
            <el-radio value="normal">正常</el-radio>
            <el-radio value="hidden">隐藏</el-radio>
          </el-radio-group>
        </el-form-item>
      </el-form>

      <!-- 区域运费行（自定义运费时编辑） -->
      <template v-if="form.isdelivery === '0'">
        <el-alert type="warning" :closable="false" show-icon class="region-tip">
          非包邮为避免无配送区域用户无法下单，系统默认使用配置配送区域第一个为默认运费
        </el-alert>
        <el-table :data="rows" size="small" border>
          <el-table-column label="配送区域" min-width="220">
            <template #default="{ row, $index }">
              <div class="region-cell">
                <span :class="{ muted: !row.province }">{{ row.province ? row.province.replace(/,/g, '、') : '默认运费（全国）' }}</span>
                <el-button link type="primary" size="small" @click="openRegionPicker($index)">编辑</el-button>
              </div>
            </template>
          </el-table-column>
          <el-table-column label="首件" width="90">
            <template #default="{ row }">
              <el-input-number v-model="row.first" :min="1" :controls="false" size="small" style="width: 70px" />
            </template>
          </el-table-column>
          <el-table-column label="首费(元)" width="100">
            <template #default="{ row }">
              <el-input-number v-model="row.first_fee" :min="0" :precision="2" :controls="false" size="small" style="width: 80px" />
            </template>
          </el-table-column>
          <el-table-column label="续件" width="90">
            <template #default="{ row }">
              <el-input-number v-model="row.additional" :min="1" :controls="false" size="small" style="width: 70px" />
            </template>
          </el-table-column>
          <el-table-column label="续费(元)" width="100">
            <template #default="{ row }">
              <el-input-number v-model="row.additional_fee" :min="0" :precision="2" :controls="false" size="small" style="width: 80px" />
            </template>
          </el-table-column>
          <el-table-column label="操作" width="70" align="center">
            <template #default="{ $index }">
              <el-button link type="danger" size="small" @click="rows.splice($index, 1)">删除</el-button>
            </template>
          </el-table-column>
        </el-table>
        <el-button style="margin-top: 8px" @click="openRegionPicker()">点击添加可配送区域和运费</el-button>
      </template>

      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="saving" @click="onSave">保存</el-button>
      </template>
    </el-dialog>

    <!-- 选择可配送区域弹窗 -->
    <el-dialog v-model="regionDialogVisible" title="选择可配送区域" width="520px">
      <div class="region-picker">
        <el-checkbox v-model="checkAll" :indeterminate="isIndeterminate">全选</el-checkbox>
        <el-button link type="primary" @click="clearSelected">清空</el-button>
        <el-divider />
        <el-checkbox-group v-model="selectedProvinces">
          <el-checkbox
            v-for="p in availableProvinces"
            :key="p"
            :label="p"
            :disabled="disabledProvinces.includes(p)"
          >{{ p }}</el-checkbox>
        </el-checkbox-group>
      </div>
      <template #footer>
        <el-button @click="regionDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="confirmRegionPicker">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { onMounted, ref, computed } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { freightTplList, freightTplDetail, freightTplSave, freightTplDelete } from '../../api/freight'
import { formatTime } from '../../utils/format'

const loading = ref(false)
const list = ref([])
const total = ref(0)
const page = ref(1)
const pageSize = 20
const keyword = ref('')
const activeTab = ref('')

// 发货时间选项（DB enum '0'-'18'）
const deliveryOptions = [
  { value: '0', label: '当天发货' },
  ...Array.from({ length: 18 }, (_, i) => ({ value: String(i + 1), label: `${i + 1} 天内发货` })),
]

// 可选省份（与后端 calc_freight 做 Contains 匹配，使用中文全称）
const allProvinces = [
  '北京市', '天津市', '河北省', '山西省', '内蒙古自治区',
  '辽宁省', '吉林省', '黑龙江省', '上海市', '江苏省',
  '浙江省', '安徽省', '福建省', '江西省', '山东省',
  '河南省', '湖北省', '湖南省', '广东省', '广西壮族自治区',
  '海南省', '重庆市', '四川省', '贵州省', '云南省',
  '西藏自治区', '陕西省', '甘肃省', '青海省', '宁夏回族自治区',
  '新疆维吾尔自治区', '台湾省', '香港特别行政区', '澳门特别行政区',
]

function deliveryName(v) {
  const hit = deliveryOptions.find((o) => o.value === String(v))
  return hit ? hit.label : v || '-'
}
function valuationName(v) {
  return { '0': '按件数', '1': '按重量', '2': '按体积' }[String(v)] || '-'
}

async function load() {
  loading.value = true
  try {
    const body = {
      page: page.value,
      page_size: pageSize,
      name: keyword.value || undefined,
    }
    if (activeTab.value) body.status = activeTab.value
    const resp = await freightTplList(body)
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
const rows = ref([])

function emptyForm() {
  return {
    id: 0,
    name: '',
    delivery: '5',
    isdelivery: '0',
    valuation: '0',
    status: 'normal',
  }
}

function emptyRow() {
  return {
    id: undefined,
    provinces: [],
    province: '',
    citys: '',
    first: 1,
    first_fee: 0,
    additional: 1,
    additional_fee: 0,
    status: 'normal',
  }
}

function provinceToArray(s) {
  if (!s) return []
  return s.split(',').map((x) => x.trim()).filter(Boolean)
}

async function openForm(row) {
  if (!row) {
    form.value = emptyForm()
    rows.value = [emptyRow()]
    dialogVisible.value = true
    return
  }
  try {
    const resp = await freightTplDetail(row.id)
    const f = resp?.freight || resp || {}
    form.value = {
      id: row.id,
      name: f.name || row.name || '',
      delivery: String(f.delivery ?? row.delivery ?? '5'),
      isdelivery: String(f.isdelivery ?? row.isdelivery ?? '0'),
      valuation: String(f.valuation ?? row.valuation ?? '0'),
      status: (f.status || row.status) === 'hidden' ? 'hidden' : 'normal',
    }
    rows.value = (resp?.data || []).map((r) => ({
      id: r.id || undefined,
      provinces: provinceToArray(r.province),
      province: r.province || '',
      citys: r.citys || '',
      first: Number(r.first || 1),
      first_fee: Number(r.first_fee || 0),
      additional: Number(r.additional || 1),
      additional_fee: Number(r.additional_fee || 0),
      status: r.status === 'hidden' ? 'hidden' : 'normal',
    }))
    dialogVisible.value = true
  } catch (e) {
    ElMessage.error(e.message)
  }
}

async function onSave() {
  if (!form.value.name?.trim()) {
    ElMessage.warning('请输入模板名称')
    return
  }
  saving.value = true
  try {
    await freightTplSave({
      freight: {
        ...form.value,
        id: form.value.id || undefined,
      },
      data: form.value.isdelivery === '0'
        ? rows.value.map((r) => ({
            ...r,
            province: r.provinces.join(','),
            citys: '',
          }))
        : [],
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
    await ElMessageBox.confirm(`确定删除运费模板「${row.name}」吗？`, '提示', { type: 'warning' })
  } catch {
    return
  }
  try {
    await freightTplDelete([row.id])
    ElMessage.success('删除成功')
    await load()
  } catch (e) {
    ElMessage.error(e.message)
  }
}

// ===== 区域选择弹窗 =====
const regionDialogVisible = ref(false)
const editingRowIndex = ref(-1)
const selectedProvinces = ref([])

// 当前正在被编辑的行自身已选省份（用于 disable 判断排除）
const editingRowProvinces = computed(() => {
  if (editingRowIndex.value >= 0) {
    return rows.value[editingRowIndex.value]?.provinces || []
  }
  return []
})

// 已被其他行占用的省份不可再选
const disabledProvinces = computed(() => {
  const used = new Set()
  rows.value.forEach((r, idx) => {
    if (idx === editingRowIndex.value) return
    r.provinces.forEach((p) => used.add(p))
  })
  return Array.from(used)
})

const availableProvinces = computed(() => allProvinces)

const checkAll = computed({
  get() {
    const available = allProvinces.filter((p) => !disabledProvinces.value.includes(p))
    return available.length > 0 && available.every((p) => selectedProvinces.value.includes(p))
  },
  set(v) {
    onCheckAll(v)
  },
})

const isIndeterminate = computed(() => {
  const available = allProvinces.filter((p) => !disabledProvinces.value.includes(p))
  const count = selectedProvinces.value.filter((p) => available.includes(p)).length
  return count > 0 && count < available.length
})

function onCheckAll(checked) {
  const available = allProvinces.filter((p) => !disabledProvinces.value.includes(p))
  if (checked) {
    const set = new Set(selectedProvinces.value)
    available.forEach((p) => set.add(p))
    selectedProvinces.value = Array.from(set)
  } else {
    selectedProvinces.value = selectedProvinces.value.filter((p) => !available.includes(p))
  }
}

function clearSelected() {
  selectedProvinces.value = []
}

function openRegionPicker(index = -1) {
  editingRowIndex.value = index
  if (index >= 0) {
    selectedProvinces.value = [...(rows.value[index]?.provinces || [])]
  } else {
    selectedProvinces.value = []
  }
  regionDialogVisible.value = true
}

function confirmRegionPicker() {
  if (editingRowIndex.value >= 0) {
    rows.value[editingRowIndex.value].provinces = [...selectedProvinces.value]
    rows.value[editingRowIndex.value].province = selectedProvinces.value.join(',')
  } else {
    rows.value.push({
      ...emptyRow(),
      provinces: [...selectedProvinces.value],
      province: selectedProvinces.value.join(','),
    })
  }
  regionDialogVisible.value = false
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
.region-tip {
  margin-bottom: 8px;
}
.region-cell {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 8px;
}
.region-picker .el-checkbox-group {
  display: flex;
  flex-wrap: wrap;
  gap: 8px 16px;
  max-height: 320px;
  overflow-y: auto;
}
.region-picker .el-checkbox {
  min-width: 100px;
  margin-right: 0;
}
.muted {
  color: #9ca3af;
}
</style>
