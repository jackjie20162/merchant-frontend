<template>
  <div class="image-picker">
    <div class="thumbs">
      <div v-for="(url, i) in urls" :key="url + i" class="thumb">
        <el-image :src="url" fit="cover" class="thumb-img" :preview-src-list="urls" :initial-index="i" />
        <span class="remove" @click.stop="removeAt(i)">×</span>
      </div>
      <div v-if="urls.length < max" class="thumb add" @click="openPicker">
        <span class="add-icon">+</span>
        <span class="add-text">图片</span>
      </div>
    </div>

    <!-- 图片空间选择弹窗 -->
    <el-dialog v-model="visible" title="图片空间" width="860px" append-to-body>
      <div class="space-toolbar">
        <el-upload :show-file-list="false" :http-request="onUpload" accept="image/*">
          <el-button type="primary" :loading="uploading">上传图片</el-button>
        </el-upload>
        <el-button @click="load">刷新</el-button>
        <span class="tip">支持 jpg/png/gif/webp，已选 {{ temp.length }} 张</span>
      </div>

      <div v-loading="loading" class="space-grid">
        <div
          v-for="item in list"
          :key="item.id"
          class="space-item"
          :class="{ active: temp.includes(item.url) }"
          @click="toggle(item.url)"
        >
          <el-image :src="item.url" fit="cover" class="space-img" />
          <span class="check" v-if="temp.includes(item.url)">✓</span>
        </div>
        <el-empty v-if="!loading && list.length === 0" description="暂无图片，请先上传" :image-size="80" />
      </div>

      <div class="space-pager">
        <el-pagination
          v-model:current-page="page"
          :page-size="pageSize"
          :total="total"
          layout="prev, pager, next"
          small
          @current-change="load"
        />
      </div>

      <template #footer>
        <el-button @click="visible = false">取消</el-button>
        <el-button type="primary" @click="onConfirm">确定（{{ temp.length }}）</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { computed, ref } from 'vue'
import { ElMessage } from 'element-plus'
import { attachmentList, attachmentUpload } from '../api/attachment'

// modelValue 统一为逗号分隔 URL 字符串；multiple=false 时仅可保留一张
const props = defineProps({
  modelValue: { type: String, default: '' },
  multiple: { type: Boolean, default: false },
  max: { type: Number, default: 9 },
})
const emit = defineEmits(['update:modelValue'])

const urls = computed(() => (props.modelValue ? props.modelValue.split(',').filter(Boolean) : []))

function removeAt(i) {
  const next = urls.value.filter((_, idx) => idx !== i)
  emit('update:modelValue', next.join(','))
}

// ===== 弹窗 =====
const visible = ref(false)
const loading = ref(false)
const uploading = ref(false)
const list = ref([])
const total = ref(0)
const page = ref(1)
const pageSize = 30
const temp = ref([])

function openPicker() {
  temp.value = [...urls.value]
  visible.value = true
  load()
}

async function load() {
  loading.value = true
  try {
    const resp = await attachmentList({ page: page.value, page_size: pageSize })
    list.value = resp?.data || []
    total.value = Number(resp?.total || 0)
  } catch (e) {
    ElMessage.error(e.message)
  } finally {
    loading.value = false
  }
}

function toggle(url) {
  const i = temp.value.indexOf(url)
  if (i >= 0) {
    temp.value.splice(i, 1)
    return
  }
  if (!props.multiple) {
    temp.value = [url]
    return
  }
  if (temp.value.length >= props.max) {
    ElMessage.warning(`最多选择 ${props.max} 张`)
    return
  }
  temp.value.push(url)
}

async function onUpload({ file }) {
  uploading.value = true
  try {
    await attachmentUpload(file)
    ElMessage.success('上传成功')
    page.value = 1
    await load()
  } catch (e) {
    ElMessage.error(e.message)
  } finally {
    uploading.value = false
  }
}

function onConfirm() {
  emit('update:modelValue', temp.value.join(','))
  visible.value = false
}
</script>

<style scoped>
.thumbs {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}
.thumb {
  position: relative;
  width: 80px;
  height: 80px;
  border: 1px solid #e5e7eb;
  border-radius: 6px;
  overflow: hidden;
}
.thumb-img {
  width: 100%;
  height: 100%;
}
.remove {
  position: absolute;
  top: 2px;
  right: 2px;
  width: 18px;
  height: 18px;
  line-height: 16px;
  text-align: center;
  background: rgba(0, 0, 0, 0.55);
  color: #fff;
  border-radius: 50%;
  cursor: pointer;
  font-size: 12px;
}
.thumb.add {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  border-style: dashed;
  cursor: pointer;
  color: #9ca3af;
}
.thumb.add:hover {
  border-color: #f59e0b;
  color: #f59e0b;
}
.add-icon {
  font-size: 22px;
  line-height: 1;
}
.add-text {
  font-size: 12px;
  margin-top: 4px;
}
.space-toolbar {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 12px;
}
.tip {
  color: #6b7280;
  font-size: 12px;
}
.space-grid {
  display: grid;
  grid-template-columns: repeat(6, 1fr);
  gap: 8px;
  min-height: 120px;
}
.space-item {
  position: relative;
  border: 2px solid transparent;
  border-radius: 6px;
  overflow: hidden;
  cursor: pointer;
}
.space-item.active {
  border-color: #f59e0b;
}
.space-img {
  width: 100%;
  height: 100px;
  display: block;
}
.check {
  position: absolute;
  top: 4px;
  right: 4px;
  width: 18px;
  height: 18px;
  line-height: 18px;
  text-align: center;
  background: #f59e0b;
  color: #fff;
  border-radius: 50%;
  font-size: 12px;
}
.space-pager {
  display: flex;
  justify-content: center;
  margin-top: 12px;
}
</style>
