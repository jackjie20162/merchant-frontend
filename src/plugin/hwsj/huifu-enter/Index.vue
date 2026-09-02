<template>
  <div class="huifu-enter-page">
    <div class="page-head">
      <div>
        <h2>汇付进件（个人商户）</h2>
        <span>提交个人（小微/对私）进件资料，审核通过后可用于结算打款</span>
      </div>
      <el-breadcrumb separator="/">
        <el-breadcrumb-item :to="{ path: '/dashboard' }">主页</el-breadcrumb-item>
        <el-breadcrumb-item>Merchant</el-breadcrumb-item>
        <el-breadcrumb-item>Huifu-Enter</el-breadcrumb-item>
      </el-breadcrumb>
    </div>

    <el-alert
      title="汇付进件"
      description="请按实际填写个人资料与银行卡信息"
      type="info"
      show-icon
      :closable="false"
      class="notice"
    />

    <el-card shadow="never" class="form-card">
      <el-form
        ref="formRef"
        :model="form"
        :rules="rules"
        label-position="top"
        class="enter-form"
      >
        <section class="form-section">
          <h3>身份信息</h3>
          <el-form-item label="真实姓名" prop="realName">
            <el-input v-model="form.realName" maxlength="30" />
          </el-form-item>
          <el-form-item label="证件号码" prop="certNo">
            <el-input v-model="form.certNo" maxlength="30" />
          </el-form-item>
          <el-form-item label="法人手机号" prop="legalMobile">
            <el-input v-model="form.legalMobile" maxlength="20" placeholder="法人负责人手机号" />
          </el-form-item>
          <el-form-item label="负责人邮箱">
            <el-input v-model="form.contactEmail" maxlength="80" placeholder="可选" />
          </el-form-item>
          <div class="two-col">
            <el-form-item label="证件有效期起" prop="certBeginDate">
              <el-date-picker
                v-model="form.certBeginDate"
                type="date"
                value-format="YYYY-MM-DD"
                placeholder="年-月-日"
                style="width: 100%"
              />
            </el-form-item>
            <el-form-item label="证件有效期止" prop="certEndDate">
              <el-date-picker
                v-model="form.certEndDate"
                type="date"
                value-format="YYYY-MM-DD"
                placeholder="年-月-日"
                :disabled="form.certLongTerm"
                style="width: 100%"
              />
            </el-form-item>
          </div>
          <el-checkbox v-model="form.certLongTerm" @change="onLongTermChange">
            证件长期有效
          </el-checkbox>
        </section>

        <section class="form-section">
          <h3>经营信息（省 / 市 / 区）</h3>
          <el-form-item label="经营地区" prop="businessArea">
            <div class="region-line">
              <el-input
                v-model="form.businessArea"
                readonly
                placeholder="请选择省市区"
                @click="businessRegionVisible = true"
              />
              <el-button @click="businessRegionVisible = true">选择经营省市区</el-button>
            </div>
          </el-form-item>
          <el-form-item label="经营类目（mcc）" prop="mcc">
            <el-input v-model="form.mcc" placeholder="输入中文关键字搜索，如：超市 / 餐饮" />
          </el-form-item>
          <el-form-item label="进件场景 scene_type" prop="sceneType">
            <el-select v-model="form.sceneType" style="width: 100%">
              <el-option label="ONLINE（线上场景）" value="ONLINE" />
              <el-option label="OFFLINE（线下场景）" value="OFFLINE" />
            </el-select>
            <div class="form-tip">
              示例：ALL（线上线下），线下需提供详细经营地址。
            </div>
          </el-form-item>
          <el-form-item label="详细经营地址 detail_addr" prop="detailAddr">
            <el-input
              v-model="form.detailAddr"
              maxlength="120"
              placeholder="4-256个字符，如：浙江省杭州市xx区xx路xx号（线上可填运营联系地址）"
            />
          </el-form-item>
          <el-form-item label="证件地址">
            <el-input v-model="form.certAddress" maxlength="120" />
          </el-form-item>
        </section>

        <section class="form-section">
          <h3>银行账户（省 / 市）</h3>
          <el-form-item label="银行类型" prop="bankAccountType">
            <el-select v-model="form.bankAccountType" style="width: 100%">
              <el-option label="对私账户" value="personal" />
              <el-option label="对公账户" value="company" />
            </el-select>
          </el-form-item>
          <el-form-item label="开户人姓名（须与上方真实姓名一致）" prop="bankAccountName">
            <el-input v-model="form.bankAccountName" placeholder="姓名需与个人商户姓名一致" />
          </el-form-item>
          <el-form-item label="银行卡号" prop="bankCardNo">
            <el-input v-model="form.bankCardNo" maxlength="32" />
          </el-form-item>
          <el-form-item label="银行支行" prop="bankBranch">
            <el-input v-model="form.bankBranch" placeholder="请输入银行支行名称" />
          </el-form-item>
          <el-form-item label="开户地址" prop="bankArea">
            <div class="region-line">
              <el-input
                v-model="form.bankArea"
                readonly
                placeholder="请选择开户行所在地区"
                @click="bankRegionVisible = true"
              />
              <el-button @click="bankRegionVisible = true">选择开户地址</el-button>
            </div>
          </el-form-item>
        </section>

        <section class="form-section upload-section">
          <h3>资料照片</h3>
          <div class="upload-grid">
            <el-form-item label="身份证正面照片">
              <ImagePicker v-model="form.idCardFront" :multiple="false" :max="1" />
            </el-form-item>
            <el-form-item label="身份证反面照片">
              <ImagePicker v-model="form.idCardBack" :multiple="false" :max="1" />
            </el-form-item>
            <el-form-item label="银行卡照片">
              <ImagePicker v-model="form.bankCardImage" :multiple="false" :max="1" />
            </el-form-item>
          </div>
        </section>

        <div class="actions">
          <el-button type="primary" :loading="submitting" @click="submitEnter">
            提交进件
          </el-button>
          <el-button @click="resetForm">重置</el-button>
        </div>
      </el-form>
    </el-card>

    <RegionPicker v-model="form.businessArea" v-model:visible="businessRegionVisible" />
    <RegionPicker v-model="form.bankArea" v-model:visible="bankRegionVisible" />
  </div>
</template>

<script setup>
import { reactive, ref, watch } from 'vue'
import { ElMessage } from 'element-plus'
import ImagePicker from '../../../components/ImagePicker.vue'
import RegionPicker from '../../../components/RegionPicker.vue'
import { gatewayHuifuPersonalEnterSubmit } from '../api'

const formRef = ref(null)
const submitting = ref(false)
const businessRegionVisible = ref(false)
const bankRegionVisible = ref(false)

function emptyForm() {
  return {
    realName: '',
    certNo: '',
    legalMobile: '',
    contactEmail: '',
    certBeginDate: '',
    certEndDate: '',
    certLongTerm: false,
    businessArea: '',
    mcc: '',
    sceneType: 'ONLINE',
    detailAddr: '',
    certAddress: '',
    bankAccountType: 'personal',
    bankAccountName: '',
    bankCardNo: '',
    bankBranch: '',
    bankArea: '',
    idCardFront: '',
    idCardBack: '',
    bankCardImage: '',
  }
}

const form = reactive(emptyForm())

const rules = {
  realName: [{ required: true, message: '请输入真实姓名', trigger: 'blur' }],
  certNo: [{ required: true, message: '请输入证件号码', trigger: 'blur' }],
  legalMobile: [{ required: true, message: '请输入法人手机号', trigger: 'blur' }],
  certBeginDate: [{ required: true, message: '请选择证件有效期起始日期', trigger: 'change' }],
  certEndDate: [
    {
      validator: (_, value, callback) => {
        if (form.certLongTerm || value) {
          callback()
          return
        }
        callback(new Error('请选择证件有效期截止日期'))
      },
      trigger: 'change',
    },
  ],
  businessArea: [{ required: true, message: '请选择经营地区', trigger: 'change' }],
  mcc: [{ required: true, message: '请输入经营类目', trigger: 'blur' }],
  sceneType: [{ required: true, message: '请选择进件场景', trigger: 'change' }],
  detailAddr: [{ required: true, message: '请输入详细经营地址', trigger: 'blur' }],
  bankAccountType: [{ required: true, message: '请选择银行类型', trigger: 'change' }],
  bankAccountName: [{ required: true, message: '请输入开户人姓名', trigger: 'blur' }],
  bankCardNo: [{ required: true, message: '请输入银行卡号', trigger: 'blur' }],
  bankBranch: [{ required: true, message: '请输入银行支行', trigger: 'blur' }],
  bankArea: [{ required: true, message: '请选择开户地址', trigger: 'change' }],
}

watch(
  () => form.realName,
  (name) => {
    if (!form.bankAccountName || form.bankAccountName === name.slice(0, -1)) {
      form.bankAccountName = name
    }
  },
)

function onLongTermChange(value) {
  if (value) {
    form.certEndDate = ''
    formRef.value?.clearValidate('certEndDate')
  } else {
    form.certEndDate = ''
  }
}

function validateImages() {
  const missing = []
  if (!form.idCardFront) missing.push('身份证正面照片')
  if (!form.idCardBack) missing.push('身份证反面照片')
  if (!form.bankCardImage) missing.push('银行卡照片')
  if (missing.length) {
    ElMessage.warning(`请上传${missing.join('、')}`)
    return false
  }
  return true
}

async function submitEnter() {
  if (!formRef.value) return
  const valid = await formRef.value.validate().catch(() => false)
  if (!valid || !validateImages()) return

  submitting.value = true
  try {
    await gatewayHuifuPersonalEnterSubmit({
      ...form,
      certEndDate: form.certLongTerm ? '长期' : form.certEndDate,
    })
    ElMessage.success('进件资料已提交')
  } catch (e) {
    ElMessage.error(e.message || '提交进件失败')
  } finally {
    submitting.value = false
  }
}

function resetForm() {
  Object.assign(form, emptyForm())
  formRef.value?.clearValidate()
}
</script>

<style scoped>
.huifu-enter-page {
  padding: 24px 34px;
}

.page-head {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 16px;
}

.page-head h2 {
  margin: 0 0 6px;
  color: #111827;
  font-size: 24px;
  font-weight: 500;
}

.page-head span {
  color: #6b7280;
  font-size: 14px;
}

.notice {
  margin-bottom: 12px;
}

.form-card {
  border: none;
}

.enter-form {
  width: 100%;
}

.form-section {
  padding: 14px 10px 6px;
  border-bottom: 1px solid #ebeef5;
}

.form-section:last-of-type {
  border-bottom: none;
}

.form-section h3 {
  margin: 0 0 12px;
  color: #303133;
  font-size: 15px;
  font-weight: 600;
}

.two-col {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 12px;
}

.region-line {
  display: flex;
  width: 100%;
  gap: 8px;
}

.region-line .el-input {
  flex: 1;
}

.form-tip {
  margin-top: 6px;
  color: #909399;
  font-size: 12px;
  line-height: 1.5;
}

.upload-grid {
  display: grid;
  grid-template-columns: repeat(3, minmax(0, 1fr));
  gap: 18px;
}

.actions {
  display: flex;
  gap: 8px;
  padding: 18px 10px 4px;
}

@media (max-width: 768px) {
  .huifu-enter-page {
    padding: 16px;
  }

  .page-head {
    align-items: flex-start;
    flex-direction: column;
    gap: 12px;
  }

  .two-col,
  .upload-grid {
    grid-template-columns: 1fr;
  }

  .region-line {
    flex-direction: column;
  }
}
</style>
