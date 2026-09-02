<template>
  <div class="test-page">
    <h1>🎉 数全宝网关 API Key 管理</h1>
    <p>页面加载成功!</p>
    <el-card>
      <template #header>
        <div class="card-header">
          <span>提示</span>
        </div>
      </template>
      <p>这是 Mock 数据演示，实际功能待后端接口对接后启用。</p>
    </el-card>
  </div>
</template>

<script setup>
console.log('API Key 管理页面已加载')
</script>

<style scoped>
.test-page {
  padding: 20px;
}
h1 {
  color: #409eff;
  margin-bottom: 20px;
}
</style>
