<template>
  <div v-loading="loading" class="diy-editor">
    <!-- 顶部工具栏 -->
    <div class="diy-topbar">
      <div class="topbar-left">
        <el-button size="small" @click="onBack">返回</el-button>
        <span class="page-title">{{ pageName || '未命名页面' }}</span>
        <el-select v-model="device" size="small" style="width: 130px">
          <el-option value="huaweiMate30" label="华为Mate30" />
          <el-option value="iPhoneX" label="iPhoneX" />
          <el-option value="iPhoneXmax" label="iPhoneXmax" />
          <el-option value="iPhone7" label="iPhone7" />
          <el-option value="iPhone7plus" label="iPhone7plus" />
          <el-option value="xiaomi9Pro" label="xiaomi9Pro" />
        </el-select>
        <el-select v-model="signal" size="small" style="width: 80px">
          <el-option value="WIFI" label="WIFI" />
          <el-option value="4G" label="4G" />
          <el-option value="5G" label="5G" />
        </el-select>
      </div>
      <div class="topbar-right">
        <el-button type="primary" size="small" :loading="saving" @click="save">保存页面</el-button>
      </div>
    </div>

    <div class="diy-body">
      <!-- 左侧组件库 -->
      <div class="diy-palette">
        <div class="palette-title">自定义组件</div>
        <div v-for="group in diyGroups" :key="group.key" class="palette-group">
          <div class="group-name">{{ group.label }}</div>
          <div class="group-row">
            <div
              v-for="el in group.items"
              :key="el.type"
              class="palette-item"
              @click="addComponent(el)"
            >
              <span class="palette-icon">{{ el.icon }}</span>
              <span>{{ el.name }}</span>
            </div>
          </div>
        </div>
      </div>

      <!-- 中间手机预览 -->
      <div class="diy-canvas">
        <div class="phone-frame" :style="{ width: phoneWidth }">
          <div
            class="phone-page"
            :style="{
              backgroundColor: pageConf.style.pageBackgroundColor,
              backgroundImage: pageConf.style.pageBackgroundImage
                ? `url(${pageConf.style.pageBackgroundImage})`
                : undefined,
              backgroundRepeat: pageConf.style.pageBackgroundRepeat,
            }"
          >
            <!-- 状态栏 + 导航 -->
            <div
              class="phone-nav"
              :class="{ active: selected === 'page' }"
              :style="{
                backgroundColor: pageConf.style.navigationBarBackgroundColor,
                color: pageConf.style.navigationBarTextStyle,
              }"
              @click="selected = 'page'"
            >
              <div class="status-bar">
                <span class="time">{{ nowTime }}</span>
                <span v-if="hasBangs" class="bangs"></span>
                <span v-else></span>
                <span class="device-info">{{ signal === 'WIFI' ? '📶' : signal }} 🔋</span>
              </div>
              <div class="nav-bar">
                <span class="nav-icon">‹</span>
                <span class="nav-title">{{ pageConf.params.navigationBarTitleText }}</span>
                <span class="nav-icon">⤴</span>
              </div>
            </div>

            <!-- 组件堆栈 -->
            <div
              v-for="(item, index) in items"
              :key="index"
              class="phone-mod"
              :class="{ active: selected === index }"
              :style="item.style"
              draggable="true"
              @click="selected = index"
              @dragstart="onDragStart(index, $event)"
              @dragover.prevent
              @drop="onDrop(index, $event)"
            >
              <!-- 轮播组件 -->
              <div v-if="item.type === 'banner'" class="mod-banner">
                <img
                  v-if="item.data[0]?.image"
                  :src="item.data[0].image"
                  :style="{ height: item.params?.height }"
                />
                <div v-else class="mod-placeholder" :style="{ height: item.params?.height }">
                  轮播图 {{ item.data.length }} 张
                </div>
                <div class="indicator">
                  <span v-for="(_, i) in item.data" :key="i" :class="{ on: i === 0 }"></span>
                </div>
              </div>
              <!-- 广告轮播 -->
              <div v-else-if="item.type === 'advertBanner'" class="mod-placeholder" :style="{ height: item.params?.height }">
                广告轮播（自动获取）
              </div>
              <!-- 图片橱窗 -->
              <div v-else-if="item.type === 'image'" class="mod-image">
                <div v-for="(img, i) in item.data" :key="i" class="image-item">
                  <img v-if="img.image" :src="img.image" />
                  <div v-else class="mod-placeholder">图片 {{ i + 1 }}</div>
                </div>
              </div>
              <!-- 广告单图 -->
              <div v-else-if="item.type === 'advertImage'" class="mod-placeholder" :style="{ height: item.style?.height }">
                广告图（自动获取）
              </div>
              <!-- 视频 -->
              <div v-else-if="item.type === 'video'" class="mod-video">
                <img v-if="item.data[0]?.image" :src="item.data[0].image" />
                <div v-else class="mod-placeholder">视频封面</div>
                <div class="play">▶</div>
              </div>
              <!-- 菜单 -->
              <div v-else-if="item.type === 'menu'" class="mod-menu">
                <div v-for="(me, i) in item.data" :key="i" class="menu-item">
                  <div class="menu-icon">
                    <img v-if="item.params?.menuType === 'image' && me.iconImage" :src="me.iconImage" />
                    <span v-else>▦</span>
                  </div>
                  <div class="menu-text" :style="{ fontSize: item.params?.menuTextSize }">
                    {{ me.text }}
                  </div>
                </div>
              </div>
              <!-- 公告栏 -->
              <div v-else-if="item.type === 'notice'" class="mod-notice">
                <span v-if="item.params?.show">📢</span>
                <span>{{ item.data[0]?.content }}</span>
              </div>
              <!-- 文章 -->
              <div v-else-if="item.type === 'article'" class="mod-article">
                <div v-for="(ar, i) in item.data" :key="i" class="article-item">
                  <div class="article-image">
                    <img v-if="ar.image" :src="ar.image" />
                    <div v-else class="mod-placeholder">图</div>
                  </div>
                  <div class="article-content">
                    <div class="article-title">{{ ar.articleTitle || '请选择文章' }}</div>
                    <div class="article-operate">
                      <span v-if="item.params?.showTime">2020年5月30日</span>
                      <span v-if="item.params?.showView">浏览：100</span>
                    </div>
                  </div>
                </div>
              </div>
              <!-- 头条 -->
              <div v-else-if="item.type === 'headlines'" class="mod-headlines">
                <span>📰</span>
                <div class="headlines-list">
                  <div class="headlines-text">热门 · 客户端自动获取头条数据</div>
                  <div class="headlines-pic">
                    <img v-if="item.data[0]?.image" :src="item.data[0].image" />
                  </div>
                </div>
              </div>
              <!-- 搜索栏 -->
              <div v-else-if="item.type === 'search'" class="mod-search">
                <div
                  :style="{
                    borderRadius: item.params?.searchRadius,
                    background: item.params?.searchBackground,
                    padding: item.params?.searchPadding,
                  }"
                >
                  <span>🔍 {{ item.data[0]?.content }}</span>
                </div>
              </div>
              <!-- 活动/分类橱窗 -->
              <div
                v-else-if="item.type === 'activity' || item.type === 'classify'"
                class="mod-category"
              >
                <div v-for="(cat, i) in item.data" :key="i" class="category-item">
                  <div class="category-name">
                    {{ item.type === 'activity' ? cat.activity : `分类#${cat.categoryId}` }}
                    <em v-if="cat.tags">{{ cat.tags }}</em>
                  </div>
                  <div v-if="cat.describe" class="category-describe">{{ cat.describe }}</div>
                  <div class="category-goods"><span></span><span></span></div>
                </div>
              </div>
              <!-- 类目标题 -->
              <div v-else-if="item.type === 'categoryTitle'" class="mod-category-title">
                <span>{{ item.data[0]?.categoryName }} ···</span>
                <span class="more">更多 ›</span>
              </div>
              <!-- 猜你喜欢 / 商品 -->
              <div
                v-else-if="item.type === 'likes' || item.type === 'goods'"
                class="mod-product"
              >
                <div v-for="n in 4" :key="n" class="product-item">
                  <div class="product-pic"></div>
                  <div class="product-info">
                    <div class="product-title">
                      {{ item.type === 'likes' ? '猜你喜欢自动获取' : `商品#${item.data[0]?.goodsLink ?? n}` }}
                    </div>
                    <div class="product-price">¥ 99.00</div>
                  </div>
                </div>
              </div>
              <!-- 拼团 -->
              <div v-else-if="item.type === 'groups'" class="mod-groups">
                <div class="groups-head">
                  <span :style="{ color: item.params?.titleColor, fontSize: item.params?.titleFontSize }">
                    {{ item.params?.titleText }}
                  </span>
                  <span :style="{ color: item.params?.infoColor, fontSize: item.params?.infoFontSize }">
                    {{ item.params?.infoText }}
                  </span>
                </div>
                <div class="groups-body">
                  <div v-for="n in 3" :key="n" class="groups-item">
                    <div class="groups-pic"></div>
                    <div class="groups-price">¥ 19.00</div>
                  </div>
                </div>
              </div>
              <!-- 空白行 -->
              <div v-else-if="item.type === 'empty'" class="mod-empty"></div>
              <!-- 分隔符 -->
              <div v-else-if="item.type === 'division'" class="mod-division">
                <div
                  class="line"
                  :style="{
                    width: item.params?.lineWidth,
                    height: item.params?.lineHeight,
                    background: item.params?.lineBackground,
                  }"
                ></div>
                <div
                  class="linetext"
                  :style="{
                    color: item.params?.lineTextColor,
                    fontSize: item.params?.lineTextSize,
                    background: item.params?.lineTextBackground,
                    padding: item.params?.lineTextPadding,
                  }"
                >
                  {{ item.params?.lineText }}
                </div>
              </div>
              <div v-else class="mod-placeholder">{{ item.name }}</div>

              <div class="mod-del" @click.stop="delModule(index)">×</div>
            </div>
            <div v-if="items.length === 0" class="phone-empty">点击左侧组件库添加模块</div>
          </div>
        </div>
      </div>

      <!-- 右侧配置 -->
      <div class="diy-config">
        <!-- 页面配置 -->
        <template v-if="selected === 'page'">
          <div class="config-title">页面配置</div>
          <div class="config-form">
            <div class="form-item">
              <label>页面名称</label>
              <el-input v-model="pageName" />
            </div>
            <div class="form-item">
              <label>页面封面</label>
              <ImagePicker v-model="pageCover" :multiple="false" :max="1" />
            </div>
            <div class="form-item">
              <label>导航栏标题</label>
              <el-input v-model="pageConf.params.navigationBarTitleText" />
            </div>
            <div class="form-item">
              <label>导航栏背景图</label>
              <ImagePicker v-model="pageConf.style.navigationBackgroundImage" :multiple="false" :max="1" />
            </div>
            <div class="form-item">
              <label>导航栏背景</label>
              <div class="color-row">
                <el-color-picker v-model="pageConf.style.navigationBarBackgroundColor" />
                <el-input v-model="pageConf.style.navigationBarBackgroundColor" />
              </div>
            </div>
            <div class="form-item">
              <label>导航前景色</label>
              <el-select v-model="pageConf.style.navigationBarTextStyle">
                <el-option value="#ffffff" label="浅色（白色）" />
                <el-option value="#000000" label="深色（黑色）" />
              </el-select>
            </div>
            <div class="form-item">
              <label>页面背景图</label>
              <ImagePicker v-model="pageConf.style.pageBackgroundImage" :multiple="false" :max="1" />
            </div>
            <div class="form-item">
              <label>页面背景</label>
              <div class="color-row">
                <el-color-picker v-model="pageConf.style.pageBackgroundColor" />
                <el-input v-model="pageConf.style.pageBackgroundColor" />
              </div>
            </div>
            <div class="form-item">
              <label>背景重复</label>
              <el-select v-model="pageConf.style.pageBackgroundRepeat">
                <el-option value="repeat-x" label="水平方向重复" />
                <el-option value="repeat-y" label="垂直方向重复" />
                <el-option value="no-repeat" label="不重复" />
              </el-select>
            </div>
          </div>
        </template>

        <!-- 组件配置 -->
        <template v-else-if="comp">
          <div class="config-toolbar">
            <span class="config-name">{{ comp.name }} #{{ selected + 1 }}</span>
            <span class="config-ops">
              <el-button size="small" link type="primary" @click="moveUp(selected)">上移</el-button>
              <el-button size="small" link type="primary" @click="moveDown(selected)">下移</el-button>
              <el-button size="small" link type="danger" @click="delModule(selected)">删除</el-button>
            </span>
          </div>
          <el-tabs v-model="rightTab" class="config-tabs">
            <el-tab-pane :label="`${comp.name}数据`" name="data">
              <div class="config-form">
                <el-button size="small" type="primary" @click="addData">+ 追加数据</el-button>
                <p class="config-tip">注意：请自行判断是否要添加数据，单数据如单图追加无效！</p>
                <div v-for="(entry, ei) in comp.data" :key="ei" class="data-panel">
                  <div class="data-panel-head">
                    <span>{{ comp.name }} <strong>#{{ ei + 1 }}</strong></span>
                    <span class="data-del" @click="delData(ei)">×</span>
                  </div>
                  <div class="data-panel-body">
                    <div v-for="(val, key) in entry" :key="key" class="form-item">
                      <template v-if="isHintKey(String(key))">
                        <p class="config-tip">{{ val }}</p>
                      </template>
                      <template v-else-if="isImageKey(String(key))">
                        <label>{{ dataLabel(String(key)) }}</label>
                        <ImagePicker v-model="entry[key]" :multiple="false" :max="1" />
                      </template>
                      <template v-else-if="isLinkKey(String(key))">
                        <label>{{ dataLabel(String(key)) }}</label>
                        <div class="color-row">
                          <el-input v-model="entry[key]" />
                          <el-button size="small" @click="openLink(entry, key)">选择</el-button>
                        </div>
                      </template>
                      <template v-else>
                        <label>{{ dataLabel(String(key)) }}</label>
                        <el-input v-model="entry[key]" />
                      </template>
                    </div>
                    <p v-if="Object.keys(entry).length === 0" class="config-tip">该组件无需配置数据</p>
                  </div>
                </div>
              </div>
            </el-tab-pane>
            <el-tab-pane v-if="comp.params" label="配置参数" name="params">
              <div class="config-form">
                <div v-for="(val, key) in comp.params" :key="key" class="form-item">
                  <label>{{ paramsLabel(String(key)) }}</label>
                  <el-switch
                    v-if="typeof val === 'boolean'"
                    :model-value="val"
                    @update:model-value="(v) => (comp.params[key] = v)"
                  />
                  <div v-else-if="isColorValue(val)" class="color-row">
                    <el-color-picker v-model="comp.params[key]" />
                    <el-input v-model="comp.params[key]" />
                  </div>
                  <el-input v-else v-model="comp.params[key]" />
                </div>
              </div>
            </el-tab-pane>
            <el-tab-pane label="CSS样式" name="style">
              <div class="config-form">
                <div v-for="(val, key) in comp.style" :key="key" class="form-item">
                  <label>{{ moduleStyleCatalog[String(key)] ?? key }}</label>
                  <div class="color-row">
                    <el-input v-model="comp.style[key]" />
                    <span class="style-del" @click="delStyleKey(String(key))">×</span>
                  </div>
                </div>
                <div class="form-item">
                  <label>追加属性</label>
                  <div class="color-row">
                    <el-select v-model="newStyleKey" placeholder="选择CSS属性" filterable>
                      <el-option
                        v-for="opt in styleAddOptions"
                        :key="opt.value"
                        :value="opt.value"
                        :label="opt.label"
                      />
                    </el-select>
                    <el-button size="small" @click="addStyleKey">添加</el-button>
                  </div>
                </div>
              </div>
            </el-tab-pane>
          </el-tabs>
        </template>
      </div>
    </div>

    <!-- 链接选择弹窗 -->
    <LinkPicker
      v-model:visible="linkVisible"
      :initial="linkInitial"
      @confirm="onLinkConfirm"
    />
  </div>
</template>

<script setup>
import { computed, onMounted, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { pageDetail, pageSave } from '../../api/page'
import ImagePicker from '../../components/ImagePicker.vue'
import LinkPicker from '../../components/LinkPicker.vue'
import {
  cloneComponentDef,
  dataKeyLabelMap,
  defaultPageConfig,
  diyGroups,
  moduleStyleCatalog,
  paramsKeyLabelMap,
} from './diyComponents'

const route = useRoute()
const router = useRouter()
const pageId = Number(route.params.id)

const loading = ref(false)
const saving = ref(false)
const device = ref('iPhoneX')
const signal = ref('WIFI')
const pageName = ref('')
const pageCover = ref('')
const pageConf = ref(defaultPageConfig())
const items = ref([])
const selected = ref('page')
const rightTab = ref('data')
const newStyleKey = ref('')

const comp = computed(() =>
  typeof selected.value === 'number' ? items.value[selected.value] : null,
)

const styleAddOptions = computed(() =>
  Object.entries(moduleStyleCatalog)
    .filter(([key]) => !comp.value || !(key in (comp.value.style ?? {})))
    .map(([value, label]) => ({ label, value })),
)

const nowTime = computed(() => {
  const d = new Date()
  return `${d.getHours()}:${String(d.getMinutes()).padStart(2, '0')}`
})

const deviceWidthMap = {
  huaweiMate30: '360px',
  iPhoneX: '375px',
  iPhoneXmax: '414px',
  iPhone7: '375px',
  iPhone7plus: '414px',
  xiaomi9Pro: '360px',
}
const phoneWidth = computed(() => deviceWidthMap[device.value] ?? '375px')
const hasBangs = computed(() =>
  ['huaweiMate30', 'iPhoneX', 'iPhoneXmax', 'xiaomi9Pro'].includes(device.value),
)

function dataLabel(key) {
  return dataKeyLabelMap[key] ?? key
}
function paramsLabel(key) {
  return paramsKeyLabelMap[key] ?? key
}
function isHintKey(key) {
  return key === 'tips' || key === 'title'
}
function isImageKey(key) {
  return key === 'image' || key === 'iconImage'
}
function isLinkKey(key) {
  return key === 'link' || key === 'articleLink' || key === 'advertLink' || key === 'categoryLink'
}
function isColorValue(value) {
  return typeof value === 'string' && value.startsWith('#')
}

async function load() {
  loading.value = true
  try {
    const detail = await pageDetail(pageId)
    pageName.value = detail?.name ?? ''
    pageCover.value = detail?.cover ?? ''
    const def = defaultPageConfig()
    let conf = null
    try {
      conf = detail?.page ? JSON.parse(detail.page) : null
    } catch {
      conf = null
    }
    pageConf.value = {
      params: { ...def.params, ...(conf?.params ?? {}) },
      style: { ...def.style, ...(conf?.style ?? {}) },
    }
    let arr = []
    try {
      arr = detail?.item ? JSON.parse(detail.item) : []
    } catch {
      arr = []
    }
    items.value = Array.isArray(arr) ? arr : []
  } catch (e) {
    ElMessage.error(e.message || '加载页面失败')
  } finally {
    loading.value = false
  }
}

function addComponent(def) {
  items.value.push(cloneComponentDef(def))
  selected.value = items.value.length - 1
  rightTab.value = 'data'
}

function delModule(index) {
  items.value.splice(index, 1)
  selected.value = 'page'
}

function moveUp(index) {
  if (index <= 0) return
  const arr = items.value
  ;[arr[index - 1], arr[index]] = [arr[index], arr[index - 1]]
  selected.value = index - 1
}

function moveDown(index) {
  const arr = items.value
  if (index >= arr.length - 1) return
  ;[arr[index + 1], arr[index]] = [arr[index], arr[index + 1]]
  selected.value = index + 1
}

// ===== 拖拽排序 =====
let dragIndex = -1
function onDragStart(index, e) {
  dragIndex = index
  e.dataTransfer.effectAllowed = 'move'
}
function onDrop(index, e) {
  e.preventDefault()
  if (dragIndex < 0 || dragIndex === index) return
  const arr = items.value
  const [moved] = arr.splice(dragIndex, 1)
  arr.splice(index, 0, moved)
  selected.value = index
  dragIndex = -1
}

function addData() {
  if (!comp.value || comp.value.data.length === 0) return
  comp.value.data.push(structuredClone(comp.value.data[0]))
}

function delData(index) {
  if (!comp.value || comp.value.data.length <= 1) return
  comp.value.data.splice(index, 1)
}

function addStyleKey() {
  if (!comp.value || !newStyleKey.value) return
  comp.value.style = comp.value.style ?? {}
  comp.value.style[newStyleKey.value] = ''
  newStyleKey.value = ''
}

function delStyleKey(key) {
  if (!comp.value) return
  delete comp.value.style[key]
}

// ===== 链接选择 =====
const linkVisible = ref(false)
const linkInitial = ref('')
let linkTarget = null
function openLink(obj, key) {
  linkTarget = { obj, key }
  linkInitial.value = String(obj[key] ?? '')
  linkVisible.value = true
}
function onLinkConfirm(value) {
  if (linkTarget) linkTarget.obj[linkTarget.key] = value
}

async function save() {
  if (!pageName.value.trim()) {
    ElMessage.warning('请在页面配置中填写页面名称')
    selected.value = 'page'
    return
  }
  saving.value = true
  try {
    await pageSave({
      id: pageId,
      name: pageName.value,
      cover: pageCover.value,
      page: JSON.stringify(pageConf.value),
      item: JSON.stringify(items.value),
    })
    ElMessage.success('保存成功')
  } catch (e) {
    ElMessage.error(e.message)
  } finally {
    saving.value = false
  }
}

function onBack() {
  router.push('/shop/decorate')
}

onMounted(load)
</script>

<style scoped>
.diy-editor {
  position: fixed;
  inset: 0;
  z-index: 10;
  display: flex;
  flex-direction: column;
  background: #f3f4f6;
}
.diy-topbar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 8px 16px;
  background: #fff;
  border-bottom: 1px solid #e5e7eb;
}
.topbar-left {
  display: flex;
  align-items: center;
  gap: 8px;
}
.page-title {
  font-weight: 600;
  margin-right: 12px;
}
.diy-body {
  display: flex;
  flex: 1;
  overflow: hidden;
}

/* 左侧组件库 */
.diy-palette {
  width: 220px;
  overflow-y: auto;
  background: #fff;
  border-right: 1px solid #e5e7eb;
  padding: 12px;
}
.palette-title {
  font-weight: 600;
  margin-bottom: 8px;
}
.group-name {
  color: #6b7280;
  font-size: 12px;
  margin: 8px 0 4px;
}
.group-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 8px;
}
.palette-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 4px;
  padding: 10px 4px;
  border: 1px solid #e5e7eb;
  border-radius: 6px;
  font-size: 12px;
  cursor: pointer;
}
.palette-item:hover {
  border-color: #f59e0b;
  color: #f59e0b;
}
.palette-icon {
  font-size: 18px;
}

/* 中间预览 */
.diy-canvas {
  flex: 1;
  overflow: auto;
  padding: 24px;
}
.phone-frame {
  margin: 0 auto;
  background: #fff;
  border: 1px solid #d1d5db;
  border-radius: 12px;
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.1);
}
.phone-page {
  min-height: 640px;
  overflow: hidden;
  border-radius: 12px;
}
.phone-nav {
  cursor: pointer;
  background: #fff;
}
.phone-nav.active {
  outline: 2px solid #f59e0b;
  outline-offset: -2px;
}
.status-bar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  height: 30px;
  padding: 0 12px;
  font-size: 12px;
}
.bangs {
  width: 120px;
  height: 18px;
  background: #000;
  border-radius: 0 0 12px 12px;
}
.nav-bar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  height: 40px;
  padding: 0 12px;
}
.nav-title {
  font-size: 15px;
  font-weight: 500;
}
.phone-mod {
  position: relative;
  cursor: pointer;
}
.phone-mod.active {
  outline: 2px dashed #f59e0b;
  outline-offset: -2px;
}
.mod-del {
  position: absolute;
  top: 2px;
  right: 2px;
  z-index: 2;
  display: none;
  width: 18px;
  height: 18px;
  font-size: 14px;
  line-height: 18px;
  color: #fff;
  text-align: center;
  cursor: pointer;
  background: rgba(0, 0, 0, 0.45);
  border-radius: 50%;
}
.phone-mod:hover .mod-del {
  display: block;
}
.mod-placeholder {
  display: flex;
  align-items: center;
  justify-content: center;
  min-height: 60px;
  color: #9ca3af;
  font-size: 12px;
  background: #f3f4f6;
}
.mod-banner {
  position: relative;
}
.mod-banner img {
  width: 100%;
  object-fit: cover;
  display: block;
}
.indicator {
  position: absolute;
  bottom: 6px;
  left: 50%;
  display: flex;
  gap: 4px;
  transform: translateX(-50%);
}
.indicator span {
  width: 6px;
  height: 6px;
  background: rgba(255, 255, 255, 0.6);
  border-radius: 50%;
}
.indicator span.on {
  background: #ff4632;
}
.mod-image {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 2px;
}
.mod-image img {
  width: 100%;
  height: 80px;
  object-fit: cover;
  display: block;
}
.mod-video {
  position: relative;
}
.mod-video img {
  width: 100%;
  display: block;
}
.mod-video .play {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  width: 36px;
  height: 36px;
  line-height: 36px;
  text-align: center;
  color: #fff;
  background: rgba(0, 0, 0, 0.4);
  border-radius: 50%;
}
.mod-menu {
  display: flex;
  flex-wrap: wrap;
}
.menu-item {
  width: 20%;
  text-align: center;
  padding: 6px 0;
}
.menu-icon {
  width: 45px;
  height: 45px;
  margin: 0 auto;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 1000px;
  background: #fca5a5;
  overflow: hidden;
}
.menu-icon img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}
.mod-notice {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 12px;
}
.mod-article {
  display: flex;
  flex-direction: column;
  gap: 8px;
}
.article-item {
  display: flex;
  gap: 8px;
}
.article-image {
  width: 90px;
  height: 60px;
  flex-shrink: 0;
}
.article-image img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}
.article-content {
  flex: 1;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
}
.article-title {
  font-size: 13px;
}
.article-operate {
  color: #9ca3af;
  font-size: 11px;
  display: flex;
  gap: 8px;
}
.mod-headlines {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 10px;
}
.headlines-list {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: space-between;
}
.headlines-text {
  font-size: 12px;
  color: #374151;
}
.headlines-pic img {
  width: 40px;
  height: 40px;
  border-radius: 6px;
  object-fit: cover;
}
.mod-search div {
  color: #6b7280;
  font-size: 12px;
}
.mod-category {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 8px;
  padding: 8px;
}
.category-item {
  border: 1px solid #f3f4f6;
  border-radius: 8px;
  padding: 8px;
}
.category-name {
  font-size: 13px;
  font-weight: 600;
}
.category-name em {
  font-style: normal;
  font-size: 11px;
  color: #ef4444;
  margin-left: 4px;
}
.category-describe {
  font-size: 11px;
  color: #9ca3af;
  margin: 2px 0;
}
.category-goods {
  display: flex;
  gap: 4px;
}
.category-goods span {
  width: 40px;
  height: 40px;
  background: #f3f4f6;
  border-radius: 4px;
}
.mod-category-title {
  display: flex;
  justify-content: space-between;
  padding: 8px;
  font-size: 14px;
  font-weight: 600;
}
.mod-category-title .more {
  color: #9ca3af;
  font-weight: 400;
  font-size: 12px;
}
.mod-product {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 8px;
  padding: 8px;
}
.product-item {
  background: #fff;
  border-radius: 8px;
  overflow: hidden;
}
.product-pic {
  height: 80px;
  background: #e5e7eb;
}
.product-info {
  padding: 6px;
}
.product-title {
  font-size: 12px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
.product-price {
  color: #ef4444;
  font-size: 13px;
  font-weight: 600;
}
.mod-groups {
  padding: 8px;
}
.groups-head {
  display: flex;
  align-items: baseline;
  gap: 8px;
  margin-bottom: 6px;
}
.groups-body {
  display: flex;
  gap: 8px;
}
.groups-item {
  flex: 1;
}
.groups-pic {
  height: 70px;
  background: #f3f4f6;
  border-radius: 6px;
}
.groups-price {
  color: #ef4444;
  font-size: 12px;
  text-align: center;
  margin-top: 4px;
}
.mod-empty {
  min-height: 10px;
}
.mod-division {
  display: flex;
  flex-direction: column;
  align-items: center;
}
.phone-empty {
  padding: 60px 0;
  text-align: center;
  color: #9ca3af;
  font-size: 12px;
}

/* 右侧配置 */
.diy-config {
  width: 340px;
  overflow-y: auto;
  background: #fff;
  border-left: 1px solid #e5e7eb;
  padding: 12px;
}
.config-title {
  font-weight: 600;
  margin-bottom: 12px;
}
.config-toolbar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 8px;
}
.config-name {
  font-weight: 600;
}
.config-form {
  display: flex;
  flex-direction: column;
  gap: 10px;
}
.form-item {
  display: flex;
  flex-direction: column;
  gap: 4px;
}
.form-item label {
  font-size: 12px;
  color: #6b7280;
}
.color-row {
  display: flex;
  align-items: center;
  gap: 6px;
}
.config-tip {
  color: #9ca3af;
  font-size: 12px;
}
.data-panel {
  border: 1px solid #e5e7eb;
  border-radius: 6px;
  padding: 8px;
}
.data-panel-head {
  display: flex;
  justify-content: space-between;
  margin-bottom: 6px;
  font-size: 13px;
}
.data-del,
.style-del {
  cursor: pointer;
  color: #ef4444;
  width: 18px;
  height: 18px;
  text-align: center;
}
.data-panel-body {
  display: flex;
  flex-direction: column;
  gap: 8px;
}
</style>
