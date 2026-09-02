<template>
  <div class="page"><div class="head"><div><h2>旅游订单</h2><p>按订单号查询当前商户的旅游订单</p></div></div><el-card shadow="never"><el-form :inline="true" @submit.prevent="query"><el-form-item label="订单号"><el-input v-model="orderNo" placeholder="TRV..." clearable/></el-form-item><el-button type="primary" :loading="loading" @click="query">查询</el-button></el-form><el-empty v-if="!order" description="请输入订单号查询"/><el-descriptions v-else :column="2" border class="result"><el-descriptions-item label="订单 ID">{{ order.id }}</el-descriptions-item><el-descriptions-item label="订单号">{{ order.orderNo }}</el-descriptions-item><el-descriptions-item label="状态"><el-tag :type="statusType(order.status)">{{ statusText(order.status) }}</el-tag></el-descriptions-item><el-descriptions-item label="金额">{{ order.totalAmount }} {{ order.currency }}</el-descriptions-item></el-descriptions></el-card></div>
</template>
<script setup>
import { ref } from 'vue'
import { ElMessage } from 'element-plus'
import { travelOrderDetail } from '../api'
const orderNo=ref(''),order=ref(null),loading=ref(false)
async function query(){if(!orderNo.value)return ElMessage.warning('请输入订单号');loading.value=true;try{order.value=await travelOrderDetail(orderNo.value)}catch(e){order.value=null;ElMessage.error(e.message)}finally{loading.value=false}}
function statusText(s){return {PENDING_PAYMENT:'待支付',PAYMENT_PROCESSING:'支付处理中',PAID:'已支付',CONFIRMED:'已确认',COMPLETED:'已完成',CANCELLED:'已取消',REFUNDED:'已退款'}[s]||s||'-'}
function statusType(s){return {PAID:'success',CONFIRMED:'success',COMPLETED:'success',CANCELLED:'danger',REFUNDED:'info'}[s]||'warning'}
</script>
<style scoped>.page{padding:24px 34px}.head{margin-bottom:18px}.head h2{margin:0 0 6px;font-size:24px}.head p{margin:0;color:#6b7280}.result{margin-top:20px}</style>
