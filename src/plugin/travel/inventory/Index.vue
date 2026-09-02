<template>
  <div class="page"><div class="head"><div><h2>旅游库存</h2><p>实时检查旅游 Package / 日期 / 时段库存与服务端价格</p></div></div><el-card shadow="never"><el-form :model="form" label-width="110px" class="form" @submit.prevent="check"><el-form-item label="Package ID"><el-input-number v-model="form.packageId" :min="1"/></el-form-item><el-form-item label="服务日期"><el-date-picker v-model="form.date" type="date" value-format="YYYY-MM-DD"/></el-form-item><el-form-item label="时间段"><el-input v-model="form.timeSlot" placeholder="例如 09:00-12:00"/></el-form-item><el-form-item label="数量"><el-input-number v-model="form.quantity" :min="1"/></el-form-item><el-button type="primary" :loading="loading" @click="check">检查库存</el-button></el-form><el-alert v-if="result" :title="result.available ? `可预订，剩余 ${result.remaining}` : `不可预订，剩余 ${result.remaining}`" :type="result.available?'success':'warning'" show-icon class="result"/><el-descriptions v-if="result" :column="2" border class="result"><el-descriptions-item label="服务端单价">{{ result.unitPrice }}</el-descriptions-item><el-descriptions-item label="币种">{{ result.currency }}</el-descriptions-item><el-descriptions-item label="剩余库存">{{ result.remaining }}</el-descriptions-item><el-descriptions-item label="可预订">{{ result.available?'是':'否' }}</el-descriptions-item></el-descriptions></el-card></div>
</template>
<script setup>
import { reactive, ref } from 'vue'
import { ElMessage } from 'element-plus'
import { travelInventoryCheck } from '../api'
const form=reactive({packageId:1,date:'',timeSlot:'',quantity:1}),result=ref(null),loading=ref(false)
async function check(){if(!form.date)return ElMessage.warning('请选择服务日期');loading.value=true;try{result.value=await travelInventoryCheck(form)}catch(e){ElMessage.error(e.message)}finally{loading.value=false}}
</script>
<style scoped>.page{padding:24px 34px}.head{margin-bottom:18px}.head h2{margin:0 0 6px;font-size:24px}.head p{margin:0;color:#6b7280}.form{max-width:620px}.result{margin-top:20px}</style>
