<template>
  <div class="page">
    <el-card v-loading="loading" shadow="never">
      <el-tabs v-model="activeTab">
        <el-tab-pane label="商家店铺配置" name="shop" />
        <el-tab-pane label="寄件人信息" name="send" />
        <el-tab-pane label="退货信息" name="return" />
      </el-tabs>

      <!-- 商家店铺配置 -->
      <el-form v-show="activeTab === 'shop'" :model="form" label-width="110px" class="settings-form">
        <el-form-item label="类目样式">
          <el-radio-group v-model="form.category_style">
            <el-radio value="1">一级类目 - 大图</el-radio>
            <el-radio value="2">一级类目 - 九宫格</el-radio>
            <el-radio value="3">二级类目</el-radio>
            <el-radio value="4">多级类目</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="运费组合策略">
          <el-radio-group v-model="form.freight">
            <el-radio value="0">运费叠加</el-radio>
            <el-radio value="1">以最低结算</el-radio>
            <el-radio value="2">以最高结算</el-radio>
          </el-radio-group>
          <div class="hint-block">多件商品使用不同运费模板时的结算方式</div>
        </el-form-item>
        <el-form-item label="IM 欢迎语">
          <el-input
            v-model="form.welcome"
            type="textarea"
            :rows="3"
            maxlength="200"
            show-word-limit
            placeholder="顾客进入会话时自动发送，留空不启用"
          />
        </el-form-item>
      </el-form>

      <!-- 寄件人信息 -->
      <el-form v-show="activeTab === 'send'" :model="form" label-width="110px" class="settings-form">
        <el-form-item label="寄件人姓名">
          <el-input v-model="form.send_name" maxlength="20" placeholder="发货联系人姓名" />
        </el-form-item>
        <el-form-item label="联系电话">
          <el-input v-model="form.send_phone_num" maxlength="20" placeholder="发货联系电话" />
        </el-form-item>
        <el-form-item label="发货地址">
          <el-input v-model="form.send_addr" maxlength="200" placeholder="如：广东省深圳市南山区 xx 路 xx 号" />
        </el-form-item>
      </el-form>

      <!-- 退货信息 -->
      <el-form v-show="activeTab === 'return'" :model="form" label-width="110px" class="settings-form">
        <el-form-item label="退货联系人">
          <el-input v-model="form.return_name" maxlength="20" placeholder="收货退货联系人姓名" />
        </el-form-item>
        <el-form-item label="联系电话">
          <el-input v-model="form.return_phone_num" maxlength="20" placeholder="退货联系电话" />
        </el-form-item>
        <el-form-item label="退货地址">
          <el-input v-model="form.return_addr" maxlength="200" placeholder="如：广东省深圳市南山区 xx 路 xx 号" />
        </el-form-item>
      </el-form>

      <div class="footer">
        <el-button type="primary" :loading="saving" @click="onSave">保存配置</el-button>
      </div>
    </el-card>
  </div>
</template>

<script setup>
import { onMounted, ref } from 'vue'
import { ElMessage } from 'element-plus'
import { shopSettingsGet, shopSettingsSave } from '../../api/shop'

const loading = ref(false)
const saving = ref(false)
const activeTab = ref('shop')
const form = ref(emptyForm())

function emptyForm() {
  return {
    category_style: '1',
    freight: '0',
    welcome: '',
    send_name: '',
    send_phone_num: '',
    send_addr: '',
    return_name: '',
    return_phone_num: '',
    return_addr: '',
  }
}

// 枚举值回退：非法/空值落到默认选项
function normalize(v, allowed, fallback) {
  return allowed.includes(v) ? v : fallback
}

async function load() {
  loading.value = true
  try {
    const resp = (await shopSettingsGet()) || {}
    form.value = {
      category_style: normalize(resp.category_style, ['1', '2', '3', '4'], '1'),
      freight: normalize(resp.freight, ['0', '1', '2'], '0'),
      welcome: resp.welcome || '',
      send_name: resp.send_name || '',
      send_phone_num: resp.send_phone_num || '',
      send_addr: resp.send_addr || '',
      return_name: resp.return_name || '',
      return_phone_num: resp.return_phone_num || '',
      return_addr: resp.return_addr || '',
    }
  } catch (e) {
    ElMessage.error(e.message)
  } finally {
    loading.value = false
  }
}

async function onSave() {
  saving.value = true
  try {
    await shopSettingsSave({ ...form.value })
    ElMessage.success('保存成功')
  } catch (e) {
    ElMessage.error(e.message)
  } finally {
    saving.value = false
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
.settings-form {
  max-width: 640px;
  padding-top: 8px;
}
.hint-block {
  color: #9ca3af;
  font-size: 12px;
  line-height: 1.4;
}
.footer {
  padding: 12px 0 4px 110px;
}
</style>
