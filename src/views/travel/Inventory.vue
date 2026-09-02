<template>
  <el-card>
    <template #header>旅游库存检查</template>
    <el-form :model="form" label-width="110px" @submit.prevent="check">
      <el-form-item label="Package ID"><el-input-number v-model="form.packageId" :min="1" /></el-form-item>
      <el-form-item label="服务日期"><el-input v-model="form.date" placeholder="YYYY-MM-DD" /></el-form-item>
      <el-form-item label="时间段"><el-input v-model="form.timeSlot" placeholder="可选，如 09:00-12:00" /></el-form-item>
      <el-form-item label="数量"><el-input-number v-model="form.quantity" :min="1" /></el-form-item>
      <el-button type="primary" :loading="loading" @click="check">检查库存</el-button>
    </el-form>
    <el-alert v-if="result" :title="result.available ? `可预订，剩余 ${result.remaining}` : `不可预订，剩余 ${result.remaining}`" :type="result.available ? 'success' : 'warning'" show-icon class="result" />
    <div v-if="result" class="price">服务端价格：{{ result.unitPrice }} {{ result.currency }}</div>
  </el-card>
</template>

<script setup>
import { reactive, ref } from 'vue'
import { ElMessage } from 'element-plus'
import { checkTravelInventory } from '../../api/travel'

const form = reactive({ packageId: 1, date: '', timeSlot: '', quantity: 1 })
const result = ref(null)
const loading = ref(false)

async function check() {
  loading.value = true
  try { result.value = await checkTravelInventory(form) } catch (e) { ElMessage.error(e.message) } finally { loading.value = false }
}
</script>

<style scoped>
.result { margin-top: 24px; }
.price { margin-top: 12px; font-weight: 600; }
</style>
