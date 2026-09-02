<template>
  <div class="page">
    <div class="head"><div><h2>旅游商户中心</h2><p>Dubai Travel · 产品、库存、订单运营</p></div><el-button :loading="loading" @click="load">刷新</el-button></div>
    <el-row :gutter="16">
      <el-col :xs="24" :sm="8"><el-card shadow="never"><div class="stat"><span>可售产品</span><strong>{{ products.length }}</strong></div></el-card></el-col>
      <el-col :xs="24" :sm="8"><el-card shadow="never"><div class="stat"><span>当前商户</span><strong>{{ merchantName }}</strong></div></el-card></el-col>
      <el-col :xs="24" :sm="8"><el-card shadow="never"><div class="stat"><span>服务架构</span><strong>travel-api → travel-rpc</strong></div></el-card></el-col>
    </el-row>
    <el-card shadow="never" class="panel">
      <template #header><div class="card-head"><span>旅游产品</span><el-button link type="primary" @click="$router.push('/plugin/travel/products/index')">查看全部</el-button></div></template>
      <el-table v-loading="loading" :data="products.slice(0, 8)" border>
        <el-table-column prop="id" label="ID" width="80" />
        <el-table-column prop="title" label="产品名称" min-width="240" />
        <el-table-column prop="destination" label="目的地" width="150" />
        <el-table-column prop="currency" label="币种" width="90" />
        <el-table-column prop="minPrice" label="起价" width="110" />
        <el-table-column prop="status" label="状态" width="100"><template #default="{row}"><el-tag size="small" :type="row.status === 'ACTIVE' ? 'success' : 'info'">{{ row.status }}</el-tag></template></el-table-column>
      </el-table>
    </el-card>
  </div>
</template>
<script setup>
import { computed, onMounted, ref } from 'vue'
import { ElMessage } from 'element-plus'
import { auth } from '../../../store/auth'
import { travelProductList } from '../api'
const loading = ref(false)
const products = ref([])
const merchantName = computed(() => auth.profile?.shop?.shopname || auth.profile?.merchant?.nickname || '-')
async function load() {
  loading.value = true
  try { const data = await travelProductList({ page: 1, pageSize: 50 }); products.value = data?.items || [] } catch (e) { ElMessage.error(e.message) } finally { loading.value = false }
}
onMounted(load)
</script>
<style scoped>
.page{padding:24px 34px}.head,.card-head{display:flex;justify-content:space-between;align-items:center}.head{margin-bottom:18px}.head h2{margin:0 0 6px;font-size:24px}.head p{margin:0;color:#6b7280}.stat{padding:8px 0}.stat span{display:block;color:#6b7280;font-size:13px;margin-bottom:8px}.stat strong{font-size:22px}.panel{margin-top:16px;border:none}
</style>
