<template>
  <div class="page">
    <div class="head"><div><h2>旅游支付</h2><p>创建支付单并通过 PayPal Sandbox 完成付款。最终状态以 Travel 服务端确认/Webhook 为准。</p></div></div>
    <el-card shadow="never" class="card">
      <el-form :model="form" label-width="110px" @submit.prevent="create">
        <el-form-item label="旅游订单号"><el-input v-model="form.orderNo" placeholder="TRV..." clearable /></el-form-item>
        <el-form-item label="支付方式"><el-select v-model="form.provider"><el-option label="PayPal Sandbox" value="paypal" /></el-select></el-form-item>
        <el-form-item label="幂等键"><el-input v-model="form.idempotencyKey" placeholder="不重复的支付请求标识" clearable><template #append><el-button @click="newKey">生成</el-button></template></el-input></el-form-item>
        <el-button type="primary" :loading="loading" @click="create">创建 PayPal 支付</el-button>
      </el-form>
    </el-card>
    <el-card v-if="payment" shadow="never" class="card">
      <template #header><div class="card-title"><span>支付状态</span><el-tag :type="statusType(payment.status)">{{ statusText(payment.status) }}</el-tag></div></template>
      <el-descriptions :column="2" border>
        <el-descriptions-item label="支付单号">{{ payment.paymentNo }}</el-descriptions-item><el-descriptions-item label="订单号">{{ payment.orderNo }}</el-descriptions-item>
        <el-descriptions-item label="支付方式">{{ payment.provider }}</el-descriptions-item><el-descriptions-item label="金额">{{ payment.amount }} {{ payment.currency }}</el-descriptions-item>
        <el-descriptions-item label="第三方支付号">{{ payment.providerPaymentId || '-' }}</el-descriptions-item><el-descriptions-item label="状态">{{ statusText(payment.status) }}</el-descriptions-item>
      </el-descriptions>
      <div class="actions">
        <el-button v-if="payment.checkoutUrl" type="primary" @click="openPayPal">前往 PayPal 支付</el-button>
        <el-button :loading="refreshing" @click="refresh">刷新状态</el-button>
        <el-button v-if="payment.status === 'CREATED' || payment.status === 'PROCESSING'" @click="startPolling">自动轮询</el-button>
        <el-button v-if="payment.status === 'PAID'" type="success" disabled>支付成功</el-button>
      </div>
    </el-card>
  </div>
</template>
<script setup>
import { onBeforeUnmount, ref } from 'vue'
import { useRoute } from 'vue-router'
import { ElMessage } from 'element-plus'
import { travelPaymentCreate, travelPaymentDetail } from '../api'
const route=useRoute(),form=ref({orderNo:String(route.query.orderNo||''),provider:'paypal',idempotencyKey:''}),payment=ref(null),loading=ref(false),refreshing=ref(false)
let timer=null
function newKey(){form.value.idempotencyKey=`travel-pay-${Date.now()}-${Math.random().toString(36).slice(2,8)}`}
function statusText(s){return {CREATED:'待前往 PayPal',PROCESSING:'支付处理中',PAID:'已支付',FAILED:'支付失败',CANCELLED:'已取消',REFUNDED:'已退款'}[s]||s||'-'}
function statusType(s){return {PAID:'success',FAILED:'danger',CANCELLED:'info',REFUNDED:'info',PROCESSING:'warning'}[s]||'warning'}
function openPayPal(){if(payment.value?.checkoutUrl)window.location.href=payment.value.checkoutUrl}
async function create(){if(!form.value.orderNo)return ElMessage.warning('请输入旅游订单号');if(!form.value.idempotencyKey)newKey();loading.value=true;try{payment.value=await travelPaymentCreate(form.value);ElMessage.success('PayPal 支付单已创建');startPolling()}catch(e){ElMessage.error(e.message)}finally{loading.value=false}}
async function refresh(){if(!payment.value?.paymentNo)return;refreshing.value=true;try{payment.value=await travelPaymentDetail(payment.value.paymentNo);if(payment.value.status==='PAID')stopPolling()}catch(e){ElMessage.error(e.message)}finally{refreshing.value=false}}
function startPolling(){stopPolling();timer=window.setInterval(refresh,5000);refresh()}
function stopPolling(){if(timer){window.clearInterval(timer);timer=null}}
onBeforeUnmount(stopPolling)
</script>
<style scoped>.page{padding:24px 34px}.head{margin-bottom:18px}.head h2{margin:0 0 6px;font-size:24px}.head p{margin:0;color:#6b7280}.card{max-width:900px;margin-bottom:18px}.card-title{display:flex;justify-content:space-between;align-items:center;font-weight:600}.actions{margin-top:18px;display:flex;gap:10px;flex-wrap:wrap}</style>
