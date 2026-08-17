<template>
  <div class="page">
    <el-card v-loading="loading" shadow="never" header="店铺资料">
      <el-form :model="form" label-width="110px" style="max-width: 680px">
        <RegionPicker v-model="form.city" v-model:visible="regionVisible" />
        <el-form-item label="店铺名称">
          <el-input v-model="form.shopname" maxlength="50" show-word-limit />
        </el-form-item>
        <el-form-item label="店铺头像">
          <ImagePicker v-model="form.avatar" :multiple="false" :max="1" />
        </el-form-item>
        <el-form-item label="店铺类型">
          <el-radio-group v-model="form.state">
            <el-radio value="0">个人店</el-radio>
            <el-radio value="1">企业店</el-radio>
            <el-radio value="2">旗舰店</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="关键词">
          <el-input v-model="form.keywords" placeholder="SEO 关键词，逗号分隔" maxlength="200" />
        </el-form-item>
        <el-form-item label="店铺简介">
          <el-input v-model="form.description" type="textarea" :rows="3" maxlength="500" show-word-limit />
        </el-form-item>
        <el-form-item label="店铺公告">
          <el-input v-model="form.bio" type="textarea" :rows="2" maxlength="200" show-word-limit />
        </el-form-item>
        <el-form-item label="店铺所在地">
          <div style="display: flex; gap: 8px; align-items: center">
            <el-input
              v-model="form.city"
              readonly
              placeholder="请选择省市区"
              style="flex: 1"
              @click="regionVisible = true"
            />
            <el-button @click="regionVisible = true">选择</el-button>
          </div>
        </el-form-item>
        <el-form-item label="退货地址">
          <el-input v-model="form.return_address" placeholder="退货收货地址" maxlength="200" />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" :loading="saving" @click="onSave">保存</el-button>
          <el-button @click="load">重置</el-button>
        </el-form-item>
      </el-form>
    </el-card>
  </div>
</template>

<script setup>
import { onMounted, reactive, ref } from 'vue'
import { ElMessage } from 'element-plus'
import { shopInfo, shopSave } from '../../api/shop'
import ImagePicker from '../../components/ImagePicker.vue'
import RegionPicker from '../../components/RegionPicker.vue'

const loading = ref(false)
const saving = ref(false)
const regionVisible = ref(false)

const editableKeys = [
  'shopname', 'avatar', 'state', 'keywords', 'description', 'bio', 'city', 'return_address',
]
const form = reactive(Object.fromEntries(editableKeys.map((k) => [k, ''])))
let shopId = 0

async function load() {
  loading.value = true
  try {
    const info = await shopInfo()
    shopId = info?.id || 0
    for (const k of editableKeys) {
      form[k] = info?.[k] ?? ''
    }
  } catch (e) {
    ElMessage.error(e.message)
  } finally {
    loading.value = false
  }
}

async function onSave() {
  if (!form.shopname?.trim()) {
    ElMessage.warning('请输入店铺名称')
    return
  }
  saving.value = true
  try {
    await shopSave({ id: shopId, ...form })
    ElMessage.success('保存成功')
    await load()
  } catch (e) {
    ElMessage.error(e.message)
  } finally {
    saving.value = false
  }
}

onMounted(load)
</script>

<style scoped>
.page {
  padding: 16px;
}
</style>
