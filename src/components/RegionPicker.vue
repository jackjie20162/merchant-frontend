<template>
  <el-dialog
    v-model="visible"
    title="选择地区"
    width="680px"
    align-center
    destroy-on-close
    @open="onOpen"
    @close="onClose"
  >
    <div class="region-picker">
      <div class="selected-bar">
        <span class="label">已选：</span>
        <span class="value">{{ displayText || '请选择省市区' }}</span>
      </div>

      <el-tabs v-model="activeTab" type="card" class="region-tabs">
        <el-tab-pane label="省份" name="province">
          <div class="letter-groups">
            <div v-for="group in groups" :key="group.label" class="letter-group">
              <div class="group-label">{{ group.label }}</div>
              <div class="group-items">
                <span
                  v-for="p in group.provinces"
                  :key="p.name"
                  :class="['region-item', { active: selectedProvince?.name === p.name }]"
                  @click="onSelectProvince(p)"
                >
                  {{ p.name }}
                </span>
              </div>
            </div>
          </div>
        </el-tab-pane>

        <el-tab-pane label="城市" name="city" :disabled="!selectedProvince">
          <div v-if="selectedProvince" class="city-list">
            <span
              v-for="c in selectedProvince.cities"
              :key="c.name"
              :class="['region-item', { active: selectedCity?.name === c.name }]"
              @click="onSelectCity(c)"
            >
              {{ c.name }}
            </span>
          </div>
        </el-tab-pane>

        <el-tab-pane label="区县" name="district" :disabled="!selectedCity">
          <div v-if="selectedCity" class="district-list">
            <span
              v-for="d in selectedCity.districts"
              :key="d"
              :class="['region-item', { active: selectedDistrict === d }]"
              @click="onSelectDistrict(d)"
            >
              {{ d }}
            </span>
          </div>
        </el-tab-pane>
      </el-tabs>
    </div>

    <template #footer>
      <el-button @click="visible = false">取消</el-button>
      <el-button type="primary" :disabled="!canConfirm" @click="onConfirm">确定</el-button>
    </template>
  </el-dialog>
</template>

<script setup>
import { ref, computed, watch } from 'vue'
import regionData, { letterGroups } from '../utils/regionData.js'

const props = defineProps({
  modelValue: {
    type: String,
    default: ''
  }
})

const emit = defineEmits(['update:modelValue'])

const visible = defineModel('visible', { type: Boolean, default: false })

const activeTab = ref('province')
const selectedProvince = ref(null)
const selectedCity = ref(null)
const selectedDistrict = ref('')

const groups = computed(() => {
  return letterGroups.map((g) => ({
    label: g.label,
    provinces: regionData.filter((p) => {
      const first = p.name.charAt(0)
      return first >= g.range[0] && first <= g.range[1]
    })
  }))
})

const displayText = computed(() => {
  const parts = []
  if (selectedProvince.value) parts.push(selectedProvince.value.name)
  if (selectedCity.value) parts.push(selectedCity.value.name)
  if (selectedDistrict.value) parts.push(selectedDistrict.value)
  return parts.join(' / ')
})

const canConfirm = computed(() => selectedProvince.value && selectedCity.value && selectedDistrict.value)

function parseValue(value) {
  const parts = (value || '').split('/').map((s) => s.trim()).filter(Boolean)
  if (parts.length < 1) return

  const province = regionData.find((p) => p.name === parts[0])
  if (!province) return

  let city = null
  if (parts.length >= 2) {
    city = province.cities.find((c) => c.name === parts[1])
  }
  if (!city) {
    city = province.cities[0]
  }

  let district = ''
  if (parts.length >= 3) {
    district = city.districts.find((d) => d === parts[2]) || ''
  }

  selectedProvince.value = province
  selectedCity.value = city
  selectedDistrict.value = district
}

function onOpen() {
  parseValue(props.modelValue)
  activeTab.value = 'province'
}

function onClose() {
  selectedProvince.value = null
  selectedCity.value = null
  selectedDistrict.value = ''
}

function onSelectProvince(province) {
  selectedProvince.value = province
  selectedCity.value = null
  selectedDistrict.value = ''
  activeTab.value = 'city'
}

function onSelectCity(city) {
  selectedCity.value = city
  selectedDistrict.value = ''
  activeTab.value = 'district'
}

function onSelectDistrict(district) {
  selectedDistrict.value = district
}

function onConfirm() {
  if (!canConfirm.value) return
  const value = [selectedProvince.value.name, selectedCity.value.name, selectedDistrict.value].join(' / ')
  emit('update:modelValue', value)
  visible.value = false
}

watch(() => props.modelValue, (val) => {
  if (visible.value) {
    parseValue(val)
  }
})
</script>

<style scoped>
.region-picker {
  min-height: 260px;
}

.selected-bar {
  margin-bottom: 16px;
  padding: 10px 12px;
  background: #f5f7fa;
  border-radius: 4px;
  font-size: 14px;
}

.selected-bar .label {
  color: #606266;
}

.selected-bar .value {
  color: #303133;
  font-weight: 500;
}

.letter-groups {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.letter-group {
  display: flex;
  align-items: flex-start;
  gap: 12px;
}

.group-label {
  flex-shrink: 0;
  width: 40px;
  font-weight: 500;
  color: #909399;
  line-height: 28px;
}

.group-items,
.city-list,
.district-list {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  flex: 1;
}

.region-item {
  display: inline-block;
  padding: 4px 10px;
  border-radius: 4px;
  cursor: pointer;
  font-size: 13px;
  color: #606266;
  transition: all 0.2s;
  white-space: nowrap;
}

.region-item:hover {
  background: #ecf5ff;
  color: #409eff;
}

.region-item.active {
  background: #409eff;
  color: #fff;
}

.region-tabs :deep(.el-tabs__content) {
  padding-top: 8px;
}
</style>
