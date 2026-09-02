<template>
  <div class="page">
    <div class="head"><div><h2>旅游产品</h2><p>商户可售产品目录</p></div><el-button :loading="loading" @click="load">刷新</el-button></div>
    <el-card shadow="never" class="filter"><el-form :inline="true" @submit.prevent="search"><el-form-item label="关键词"><el-input v-model="keyword" clearable /></el-form-item><el-form-item label="目的地"><el-input v-model="destination" clearable /></el-form-item><el-button type="primary" @click="search">查询</el-button></el-form></el-card>
    <el-card shadow="never"><el-table v-loading="loading" :data="items" border><el-table-column prop="id" label="ID" width="80"/><el-table-column prop="code" label="编码" width="150"/><el-table-column prop="title" label="产品名称" min-width="250"/><el-table-column prop="destination" label="目的地" width="160"/><el-table-column prop="currency" label="币种" width="90"/><el-table-column prop="minPrice" label="起价" width="110"/><el-table-column prop="status" label="状态" width="110"/><el-table-column label="操作" width="90"><template #default="{row}"><el-button link type="primary" @click="detail(row)">详情</el-button></template></el-table-column></el-table><div class="pager"><el-pagination v-model:current-page="page" v-model:page-size="pageSize" :total="total" layout="total, prev, pager, next" @current-change="load"/></div></el-card>
    <el-drawer v-model="visible" title="旅游产品详情" size="520px"><el-descriptions v-if="selected" :column="1" border><el-descriptions-item label="ID">{{ selected.id }}</el-descriptions-item><el-descriptions-item label="名称">{{ selected.title }}</el-descriptions-item><el-descriptions-item label="目的地">{{ selected.destination }}</el-descriptions-item><el-descriptions-item label="币种">{{ selected.currency }}</el-descriptions-item><el-descriptions-item label="起价">{{ selected.minPrice }}</el-descriptions-item><el-descriptions-item label="状态">{{ selected.status }}</el-descriptions-item><el-descriptions-item label="描述">{{ selected.description || '-' }}</el-descriptions-item></el-descriptions></el-drawer>
  </div>
</template>
<script setup>
import { onMounted, ref } from 'vue'
import { ElMessage } from 'element-plus'
import { travelProductList, travelProductDetail } from '../api'
const keyword=ref(''),destination=ref(''),page=ref(1),pageSize=ref(20),total=ref(0),items=ref([]),loading=ref(false),visible=ref(false),selected=ref(null)
async function load(){loading.value=true;try{const d=await travelProductList({keyword:keyword.value,destination:destination.value,page:page.value,pageSize:pageSize.value});items.value=d?.items||[];total.value=Number(d?.total||0)}catch(e){ElMessage.error(e.message)}finally{loading.value=false}}
function search(){page.value=1;load()}
async function detail(row){try{selected.value=await travelProductDetail(row.id);visible.value=true}catch(e){ElMessage.error(e.message)}}
onMounted(load)
</script>
<style scoped>.page{padding:24px 34px}.head{display:flex;justify-content:space-between;align-items:center;margin-bottom:18px}.head h2{margin:0 0 6px;font-size:24px}.head p{margin:0;color:#6b7280}.filter{margin-bottom:12px;border:none}.pager{display:flex;justify-content:flex-end;margin-top:14px}</style>
