<template>
  <el-card v-loading="initLoading">
    <template #header>
      <div class="card-header">
        <span>{{ isEdit ? '编辑拼团商品' : '发布拼团商品' }}</span>
        <el-button link @click="goBack">返回列表</el-button>
      </div>
    </template>

    <el-tabs v-model="tab">
      <!-- 基础信息 -->
      <el-tab-pane label="基础信息" name="base">
        <el-form label-width="110px" class="form-block">
          <el-form-item label="商品标题" required>
            <el-input v-model="form.title" maxlength="200" show-word-limit placeholder="请输入商品标题" />
          </el-form-item>
          <el-form-item label="商品类目" required>
            <el-cascader
              v-model="form.category_ids"
              :options="categoryOptions"
              :props="{ value: 'id', label: 'name', children: 'children', checkStrictly: true, emitPath: true }"
              clearable
              style="width: 360px"
              placeholder="请选择平台类目"
            />
          </el-form-item>
          <el-form-item label="品牌">
            <el-select v-model="form.brand_id" clearable filterable style="width: 240px" placeholder="请选择品牌">
              <el-option v-for="b in brands" :key="b.id" :label="b.name" :value="b.id" />
            </el-select>
          </el-form-item>
          <el-form-item label="商品主图" required>
            <ImagePicker v-model="form.image" :multiple="false" />
          </el-form-item>
          <el-form-item label="商品相册">
            <ImagePicker v-model="form.images" :multiple="true" :max="9" />
          </el-form-item>
          <el-form-item label="商品卖点">
            <el-input v-model="form.description" type="textarea" :rows="2" maxlength="500" show-word-limit placeholder="一句话卖点，展示在标题下方" />
          </el-form-item>
          <el-form-item label="商品详情">
            <el-input v-model="form.content" type="textarea" :rows="8" placeholder="商品详情（支持 HTML 图文）" />
          </el-form-item>
        </el-form>
      </el-tab-pane>

      <!-- 销售规格 -->
      <el-tab-pane label="销售规格" name="specs">
        <el-form label-width="110px" class="form-block">
          <el-form-item label="规格类型">
            <el-radio-group v-model="form.specs">
              <el-radio value="single">单规格</el-radio>
              <el-radio value="multi">多规格</el-radio>
            </el-radio-group>
          </el-form-item>

          <!-- 单规格 -->
          <el-form-item v-if="form.specs === 'single'" label="SKU 信息">
            <el-table :data="[singleSku]" size="small" border>
              <el-table-column label="缩略图" width="110">
                <template #default>
                  <ImagePicker v-model="singleSku.thumbnail" :multiple="false" />
                </template>
              </el-table-column>
              <el-table-column label="拼团价" width="130">
                <template #default>
                  <el-input-number v-model="singleSku.price" :min="0" :precision="2" size="small" controls-position="right" />
                </template>
              </el-table-column>
              <el-table-column label="库存" width="130">
                <template #default>
                  <el-input-number v-model="singleSku.stock" :min="0" size="small" controls-position="right" />
                </template>
              </el-table-column>
              <el-table-column label="商品编码">
                <template #default>
                  <el-input v-model="singleSku.sn" size="small" placeholder="留空自动生成" />
                </template>
              </el-table-column>
            </el-table>
          </el-form-item>

          <!-- 多规格 -->
          <template v-else>
            <el-form-item v-for="(g, gi) in specGroups" :key="gi" :label="`规格 ${gi + 1}`">
              <div class="spec-group">
                <el-input v-model="g.name" placeholder="规格名，如：颜色" style="width: 160px" size="small" />
                <div class="spec-values">
                  <el-tag
                    v-for="(v, vi) in g.values"
                    :key="vi"
                    closable
                    size="small"
                    class="spec-tag"
                    @close="removeSpecValue(gi, vi)"
                  >
                    {{ v }}
                  </el-tag>
                  <el-input
                    v-model="g.draft"
                    size="small"
                    style="width: 120px"
                    placeholder="输入规格值回车"
                    @keyup.enter="addSpecValue(gi)"
                  />
                </div>
                <el-button link type="danger" size="small" @click="removeSpecGroup(gi)">删除规格</el-button>
              </div>
            </el-form-item>
            <el-form-item>
              <el-button v-if="specGroups.length < 3" size="small" @click="addSpecGroup">+ 添加规格</el-button>
            </el-form-item>

            <el-form-item v-if="skuRows.length" label="SKU 明细">
              <el-table :data="skuRows" size="small" border max-height="480">
                <el-table-column
                  v-for="g in validGroups"
                  :key="g.name"
                  :label="g.name"
                  min-width="90"
                >
                  <template #default="{ row }">{{ row.combo[g.name] }}</template>
                </el-table-column>
                <el-table-column label="缩略图" width="100">
                  <template #default="{ row }">
                    <ImagePicker v-model="getSku(row.key).thumbnail" :multiple="false" />
                  </template>
                </el-table-column>
                <el-table-column label="拼团价" width="130">
                  <template #default="{ row }">
                    <el-input-number v-model="getSku(row.key).price" :min="0" :precision="2" size="small" controls-position="right" />
                  </template>
                </el-table-column>
                <el-table-column label="库存" width="120">
                  <template #default="{ row }">
                    <el-input-number v-model="getSku(row.key).stock" :min="0" size="small" controls-position="right" />
                  </template>
                </el-table-column>
                <el-table-column label="商品编码" min-width="140">
                  <template #default="{ row }">
                    <el-input v-model="getSku(row.key).sn" size="small" placeholder="留空自动生成" />
                  </template>
                </el-table-column>
              </el-table>
            </el-form-item>
          </template>
        </el-form>
      </el-tab-pane>

      <!-- 拼团配置 -->
      <el-tab-pane label="拼团配置" name="groups">
        <el-form label-width="110px" class="form-block">
          <el-form-item label="拼团类型">
            <el-radio-group v-model="form.is_ladder">
              <el-radio :value="0">普通拼团</el-radio>
              <el-radio :value="1">阶梯拼团</el-radio>
            </el-radio-group>
          </el-form-item>

          <template v-if="form.is_ladder === 1">
            <el-form-item label="阶梯配置">
              <el-table :data="ladderList" size="small" border style="width: 520px">
                <el-table-column label="成团人数" width="160">
                  <template #default="{ row }">
                    <el-input-number v-model="row.people_num" :min="1" size="small" controls-position="right" />
                  </template>
                </el-table-column>
                <el-table-column label="优惠折扣%" width="160">
                  <template #default="{ row }">
                    <el-input-number v-model="row.discount" :min="0" :max="100" size="small" controls-position="right" />
                  </template>
                </el-table-column>
                <el-table-column label="操作" width="120">
                  <template #default="{ $index }">
                    <el-button link type="danger" size="small" @click="removeLadder($index)">删除</el-button>
                  </template>
                </el-table-column>
              </el-table>
              <div style="margin-top: 8px">
                <el-button size="small" @click="addLadder">+ 添加阶梯</el-button>
              </div>
            </el-form-item>
          </template>

          <el-form-item v-else label="成团人数">
            <el-input-number v-model="form.people_num" :min="2" :max="100" />
          </el-form-item>

          <el-form-item label="组团限时">
            <el-input-number v-model="form.group_hour" :min="1" :max="168" />
            <span style="margin-left: 8px; color: #666">小时</span>
          </el-form-item>

          <el-form-item label="限制拼团次数">
            <el-input-number v-model="form.purchase_limit" :min="0" :max="999" />
            <span style="margin-left: 8px; color: #666">0 表示不限制</span>
          </el-form-item>

          <el-form-item label="开启单买">
            <el-switch v-model="form.is_alone" :active-value="1" :inactive-value="0" />
            <span style="margin-left: 8px; color: #666">允许用户不参与拼团直接购买</span>
          </el-form-item>
        </el-form>
      </el-tab-pane>

      <!-- 售后与运费 -->
      <el-tab-pane label="售后与运费" name="freight">
        <el-form label-width="110px" class="form-block">
          <el-form-item label="运费模板">
            <el-select v-model="form.freight_id" clearable style="width: 280px" placeholder="请选择运费模板">
              <el-option
                v-for="f in freights"
                :key="f.id"
                :label="`${f.name}（${f.isdelivery === '1' ? '卖家包邮' : '自定义运费'}）`"
                :value="f.id"
              />
            </el-select>
          </el-form-item>
        </el-form>
      </el-tab-pane>

      <!-- 店铺类目 -->
      <el-tab-pane label="店铺类目" name="shopcat">
        <el-form label-width="110px" class="form-block">
          <el-form-item label="本店类目">
            <el-select v-model="form.shop_category_ids" multiple clearable style="width: 360px" placeholder="选择本店自定义类目（可多选）">
              <el-option v-for="c in shopCategoryOptions" :key="c.id" :label="c.label" :value="c.id" />
            </el-select>
          </el-form-item>
          <el-form-item label="上架状态">
            <el-switch v-model="form.groundingOn" active-text="保存后上架" inactive-text="存入仓库" />
          </el-form-item>
        </el-form>
      </el-tab-pane>
    </el-tabs>

    <div class="footer">
      <el-button @click="goBack">取消</el-button>
      <el-button type="primary" :loading="saving" @click="onSave">保存商品</el-button>
    </div>
  </el-card>
</template>

<script setup>
import { computed, onMounted, reactive, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import {
  groupsGoodsDetail,
  groupsGoodsSave,
} from '../../api/groups'
import {
  freightList,
  platformCategoryTree,
  shopCategoryTree,
  brandList,
} from '../../api/goods'
import { hasPerm } from '../../store/auth'
import ImagePicker from '../../components/ImagePicker.vue'

const route = useRoute()
const router = useRouter()

const goodsId = computed(() => Number(route.params.id || 0))
const isEdit = computed(() => goodsId.value > 0)

const initLoading = ref(false)
const saving = ref(false)
const tab = ref('base')

// ===== 表单数据 =====
const form = reactive({
  title: '',
  category_ids: [],
  brand_id: undefined,
  image: '',
  images: '',
  description: '',
  content: '',
  specs: 'single',
  freight_id: undefined,
  shop_category_ids: [],
  groundingOn: false,
  is_ladder: 0,
  people_num: 2,
  group_hour: 24,
  purchase_limit: 0,
  is_alone: 0,
})

// 单规格 SKU
const singleSku = reactive({ thumbnail: '', price: 0, stock: 0, sn: '' })

// 多规格
const specGroups = ref([])
const skuMap = reactive({})

// 阶梯配置
const ladderList = reactive([])

const validGroups = computed(() =>
  specGroups.value.filter((g) => g.name && g.values.length > 0),
)

const skuRows = computed(() => {
  const groups = validGroups.value
  if (!groups.length) return []
  let rows = [{ combo: {}, key: '' }]
  for (const g of groups) {
    const next = []
    for (const r of rows) {
      for (const v of g.values) {
        const combo = { ...r.combo, [g.name]: v }
        next.push({ combo, key: comboKey(groups, combo) })
      }
    }
    rows = next
  }
  return rows
})

function comboKey(groups, combo) {
  const obj = {}
  for (const g of groups) obj[g.name] = combo[g.name]
  return JSON.stringify(obj)
}

function getSku(key) {
  if (!skuMap[key]) {
    skuMap[key] = { thumbnail: '', price: 0, stock: 0, sn: '' }
  }
  return skuMap[key]
}

function addSpecGroup() {
  specGroups.value.push({ name: '', values: [], draft: '' })
}

function removeSpecGroup(gi) {
  specGroups.value.splice(gi, 1)
}

function addSpecValue(gi) {
  const g = specGroups.value[gi]
  const v = (g.draft || '').trim()
  if (!v) return
  if (g.values.includes(v)) {
    ElMessage.warning('该规格值已存在')
    return
  }
  g.values.push(v)
  g.draft = ''
}

function removeSpecValue(gi, vi) {
  specGroups.value[gi].values.splice(vi, 1)
}

function addLadder() {
  ladderList.push({ people_num: 2, discount: 0 })
}

function removeLadder(idx) {
  ladderList.splice(idx, 1)
}

// ===== 下拉数据 =====
const categoryOptions = ref([])
const brands = ref([])
const freights = ref([])
const shopCategoryOptions = ref([])

function cleanTree(nodes) {
  return (nodes || []).map((n) => {
    const children = n.children && n.children.length ? cleanTree(n.children) : undefined
    return { ...n, children }
  })
}

function flattenTree(nodes, prefix = '') {
  const out = []
  for (const n of nodes || []) {
    const label = prefix ? `${prefix} / ${n.name}` : n.name
    out.push({ id: n.id, label })
    if (n.children && n.children.length) {
      out.push(...flattenTree(n.children, label))
    }
  }
  return out
}

function findPath(nodes, id, path = []) {
  for (const n of nodes || []) {
    const next = [...path, n.id]
    if (n.id === id) return next
    if (n.children && n.children.length) {
      const found = findPath(n.children, id, next)
      if (found) return found
    }
  }
  return null
}

async function loadOptions() {
  try {
    const [catTree, brandResp, freightResp] = await Promise.all([
      platformCategoryTree(),
      brandList({ page: 1, page_size: 200 }),
      freightList({ page: 1, page_size: 100 }),
    ])
    categoryOptions.value = cleanTree(Array.isArray(catTree) ? catTree : [])
    brands.value = brandResp?.data || []
    freights.value = freightResp?.data || []
  } catch (e) {
    ElMessage.error(e.message)
  }
  if (hasPerm('category:list')) {
    try {
      const tree = await shopCategoryTree()
      shopCategoryOptions.value = flattenTree(Array.isArray(tree) ? tree : [])
    } catch (e) {
      // ignore
    }
  }
}

// ===== 编辑回填 =====
async function loadDetail() {
  initLoading.value = true
  try {
    const resp = await groupsGoodsDetail(goodsId.value)
    const g = resp.goods || {}
    form.title = g.title || ''
    form.category_ids = g.category_id
      ? findPath(categoryOptions.value, g.category_id) || [g.category_id]
      : []
    form.brand_id = g.brand_id || undefined
    form.image = g.image || ''
    form.images = g.images || ''
    form.description = g.description || ''
    form.content = g.content || ''
    form.specs = g.specs === 'multi' ? 'multi' : 'single'
    form.freight_id = g.freight_id || undefined
    form.shop_category_ids = (g.shop_category_id || '')
      .split(',')
      .filter(Boolean)
      .map(Number)
    form.groundingOn = g.grounding === 1
    form.is_ladder = g.is_ladder === 1 ? 1 : 0
    form.people_num = g.people_num || 2
    form.group_hour = g.group_hour || 24
    form.purchase_limit = g.purchase_limit || 0
    form.is_alone = g.is_alone === 1 ? 1 : 0

    // SPU
    const groups = []
    for (const spu of resp.spus || []) {
      let values = []
      try {
        const arr = JSON.parse(spu.item || '[]')
        if (Array.isArray(arr)) values = arr.map(String)
      } catch (e) {
        values = []
      }
      groups.push({ name: spu.name || '', values, draft: '' })
    }
    if (form.specs === 'multi' && groups.length) {
      specGroups.value = groups
    }

    // SKU
    const skus = resp.skus || []
    if (form.specs === 'single' && skus.length) {
      const s = skus[0]
      Object.assign(singleSku, {
        thumbnail: s.thumbnail || '',
        price: Number(s.price || 0),
        stock: Number(s.stock || 0),
        sn: s.sn || '',
      })
    } else if (groups.length) {
      for (const s of skus) {
        let combo = {}
        try {
          combo = JSON.parse(s.difference || '{}')
        } catch (e) {
          combo = {}
        }
        const key = comboKey(groups, combo)
        skuMap[key] = {
          thumbnail: s.thumbnail || '',
          price: Number(s.price || 0),
          stock: Number(s.stock || 0),
          sn: s.sn || '',
        }
      }
      specGroups.value = groups
    }

    // Ladder
    ladderList.length = 0
    for (const l of resp.ladder || []) {
      ladderList.push({
        id: l.id,
        people_num: l.people_num || 2,
        discount: l.discount || 0,
      })
    }
  } catch (e) {
    ElMessage.error(e.message)
  } finally {
    initLoading.value = false
  }
}

// ===== 保存 =====
function validate() {
  if (!form.title.trim()) {
    tab.value = 'base'
    return '请输入商品标题'
  }
  if (!form.image) {
    tab.value = 'base'
    return '请上传商品主图'
  }
  if (form.specs === 'multi') {
    if (!validGroups.value.length) {
      tab.value = 'specs'
      return '请至少添加一个规格（含规格名和规格值）'
    }
    for (const g of specGroups.value) {
      if (!g.name.trim() || !g.values.length) {
        tab.value = 'specs'
        return '存在未填写完整的规格组'
      }
    }
  }
  if (form.is_ladder === 1) {
    if (!ladderList.length) {
      tab.value = 'groups'
      return '请至少配置一条阶梯'
    }
  } else if (!form.people_num || form.people_num < 2) {
    tab.value = 'groups'
    return '普通拼团成团人数至少为 2'
  }
  if (!form.group_hour || form.group_hour < 1) {
    tab.value = 'groups'
    return '请设置组团限时'
  }
  return ''
}

function buildPayload() {
  let spus
  let skus
  if (form.specs === 'single') {
    spus = [{ name: '规格', item: JSON.stringify(['默认']) }]
    skus = [
      {
        thumbnail: singleSku.thumbnail,
        difference: JSON.stringify({ 规格: '默认' }),
        price: Number(singleSku.price || 0),
        stock: Number(singleSku.stock || 0),
        sn: singleSku.sn || undefined,
      },
    ]
  } else {
    spus = validGroups.value.map((g) => ({ name: g.name, item: JSON.stringify(g.values) }))
    skus = skuRows.value.map((r) => {
      const s = getSku(r.key)
      return {
        thumbnail: s.thumbnail,
        difference: r.key,
        price: Number(s.price || 0),
        stock: Number(s.stock || 0),
        sn: s.sn || undefined,
      }
    })
  }

  const ladder = ladderList.map((l) => ({
    id: l.id || undefined,
    people_num: Number(l.people_num || 0),
    discount: Number(l.discount || 0),
  }))

  const goods = {
    title: form.title.trim(),
    category_id: form.category_ids.length ? form.category_ids[form.category_ids.length - 1] : undefined,
    brand_id: form.brand_id || undefined,
    image: form.image,
    images: form.images,
    description: form.description,
    content: form.content,
    specs: form.specs,
    freight_id: form.freight_id || undefined,
    shop_category_id: form.shop_category_ids.join(','),
    grounding: form.groundingOn ? 1 : 0,
    is_ladder: form.is_ladder,
    people_num: form.is_ladder === 1 ? undefined : form.people_num,
    group_hour: form.group_hour,
    purchase_limit: form.purchase_limit,
    is_alone: form.is_alone,
  }
  if (isEdit.value) goods.id = goodsId.value
  return { goods, spus, skus, ladder }
}

async function onSave() {
  const msg = validate()
  if (msg) {
    ElMessage.warning(msg)
    return
  }
  saving.value = true
  try {
    await groupsGoodsSave(buildPayload())
    ElMessage.success(isEdit.value ? '保存成功' : '发布成功')
    goBack()
  } catch (e) {
    ElMessage.error(e.message)
  } finally {
    saving.value = false
  }
}

function goBack() {
  router.push('/groups/goods')
}

onMounted(async () => {
  await loadOptions()
  if (isEdit.value) {
    await loadDetail()
  }
})
</script>

<style scoped>
.card-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
}
.form-block {
  max-width: 960px;
}
.spec-group {
  display: flex;
  align-items: center;
  gap: 10px;
  flex-wrap: wrap;
}
.spec-values {
  display: flex;
  align-items: center;
  gap: 6px;
  flex-wrap: wrap;
}
.spec-tag {
  margin-right: 2px;
}
.footer {
  display: flex;
  justify-content: center;
  gap: 12px;
  padding-top: 16px;
  border-top: 1px solid #e5e7eb;
}
</style>
