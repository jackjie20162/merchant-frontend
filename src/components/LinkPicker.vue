<template>
  <el-dialog v-model="visibleProxy" title="选择链接" width="600px" append-to-body>
    <el-tabs v-model="tab">
      <el-tab-pane label="自定义链接" name="url">
        <el-input v-model="urlInput" placeholder="输入 URL，如 https:// 或 /pages/..." clearable />
        <p class="tip">可直接粘贴外部链接或客户端路由路径</p>
      </el-tab-pane>
      <el-tab-pane label="店铺页面" name="page">
        <div v-loading="pageLoading" class="pick-list">
          <div
            v-for="p in pages"
            :key="p.id"
            class="pick-item"
            :class="{ active: pagePick === p.id }"
            @click="pagePick = p.id"
          >
            <span>{{ p.name }}</span>
            <el-tag size="small" type="info">{{ p.type }}</el-tag>
          </div>
          <el-empty v-if="!pageLoading && pages.length === 0" description="暂无店铺页面" :image-size="60" />
        </div>
        <p class="tip">选中后写入格式：page:{页面ID}</p>
      </el-tab-pane>
      <el-tab-pane label="商品" name="goods">
        <div v-loading="goodsLoading" class="pick-list">
          <div
            v-for="g in goods"
            :key="g.id"
            class="pick-item"
            :class="{ active: goodsPick === g.id }"
            @click="goodsPick = g.id"
          >
            <el-image v-if="g.image" :src="g.image" fit="cover" class="pick-img" />
            <span class="pick-title">{{ g.title }}</span>
            <span class="pick-price">¥{{ g.price }}</span>
          </div>
          <el-empty v-if="!goodsLoading && goods.length === 0" description="暂无商品" :image-size="60" />
        </div>
        <p class="tip">选中后写入格式：goods:{商品ID}</p>
      </el-tab-pane>
    </el-tabs>
    <template #footer>
      <el-button @click="visibleProxy = false">取消</el-button>
      <el-button type="primary" @click="onConfirm">确定</el-button>
    </template>
  </el-dialog>
</template>

<script setup>
import { computed, ref, watch } from 'vue'
import { ElMessage } from 'element-plus'
import { pageList } from '../api/page'
import { goodsList } from '../api/goods'

const props = defineProps({
  visible: { type: Boolean, default: false },
  initial: { type: String, default: '' },
})
const emit = defineEmits(['update:visible', 'confirm'])

const visibleProxy = computed({
  get: () => props.visible,
  set: (v) => emit('update:visible', v),
})

const tab = ref('url')
const urlInput = ref('')
const pages = ref([])
const pageLoading = ref(false)
const pagePick = ref(0)
const goods = ref([])
const goodsLoading = ref(false)
const goodsPick = ref(0)

watch(
  () => props.visible,
  async (v) => {
    if (!v) return
    tab.value = 'url'
    urlInput.value = props.initial || ''
    pagePick.value = 0
    goodsPick.value = 0
    // 预解析已有值
    const cur = props.initial || ''
    if (cur.startsWith('page:')) pagePick.value = Number(cur.slice(5)) || 0
    else if (cur.startsWith('goods:')) goodsPick.value = Number(cur.slice(6)) || 0
    pageLoading.value = true
    try {
      const resp = await pageList({ page: 1, page_size: 100 })
      pages.value = resp?.data || []
    } catch {
      pages.value = []
    } finally {
      pageLoading.value = false
    }
    goodsLoading.value = true
    try {
      const resp = await goodsList({ page: 1, page_size: 50, grounding: 1 })
      goods.value = resp?.data || []
    } catch {
      goods.value = []
    } finally {
      goodsLoading.value = false
    }
  },
)

function onConfirm() {
  if (tab.value === 'url') {
    emit('confirm', urlInput.value.trim())
  } else if (tab.value === 'page') {
    if (!pagePick.value) {
      ElMessage.warning('请选择店铺页面')
      return
    }
    emit('confirm', `page:${pagePick.value}`)
  } else {
    if (!goodsPick.value) {
      ElMessage.warning('请选择商品')
      return
    }
    emit('confirm', `goods:${goodsPick.value}`)
  }
  visibleProxy.value = false
}
</script>

<style scoped>
.tip {
  color: #9ca3af;
  font-size: 12px;
  margin-top: 8px;
}
.pick-list {
  max-height: 300px;
  overflow-y: auto;
  border: 1px solid #e5e7eb;
  border-radius: 6px;
}
.pick-item {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 8px 12px;
  cursor: pointer;
  border-bottom: 1px solid #f3f4f6;
}
.pick-item:hover {
  background: #f9fafb;
}
.pick-item.active {
  background: #fff7ed;
  outline: 1px solid #f59e0b;
}
.pick-img {
  width: 36px;
  height: 36px;
  border-radius: 4px;
  flex-shrink: 0;
}
.pick-title {
  flex: 1;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
.pick-price {
  color: #ef4444;
  font-size: 12px;
}
</style>
