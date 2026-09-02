<template>
  <el-card>
    <template #header>旅游订单</template>
    <el-form :inline="true" :model="form" @submit.prevent="getOrder">
      <el-form-item label="订单号"><el-input v-model="form.orderNo" placeholder="TRV..." /></el-form-item>
      <el-button type="primary" :loading="loading" @click="getOrder">查询</el-button>
    </el-form>
    <el-descriptions v-if="order" :column="2" border>
      <el-descriptions-item label="订单号">{{ order.orderNo }}</el-descriptions-item>
      <el-descriptions-item label="状态">{{ order.status }}</el-descriptions-item>
      <el-descriptions-item label="金额">{{ order.totalAmount }} {{ order.currency }}</el-descriptions-item>
      <el-descriptions-item label="ID">{{ order.id }}</el-descriptions-item>
    </el-descriptions>
  </el-card>
</template>

<script setup>
import { reactive, ref } from 'vue'
import { ElMessage } from 'element-plus'
import { getTravelOrder } from '../../api/travel'

const form = reactive({ orderNo: '' })
const order = ref(null)
const loading = ref(false)

async function getOrder() {
  if (!form.orderNo) return ElMessage.warning('请输入订单号')
  loading.value = true
  try { order.value = await getTravelOrder(form.orderNo) } catch (e) { order.value = null; ElMessage.error(e.message) } finally { loading.value = false }
}
</script>
