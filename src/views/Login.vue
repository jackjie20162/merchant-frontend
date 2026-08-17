<template>
  <div class="login-page">
    <el-card class="login-card">
      <h2 class="login-title">商家控制台</h2>
      <p class="login-sub">店铺主账号 / 员工账号统一登录</p>
      <el-form :model="form" @submit.prevent="onSubmit">
        <el-form-item>
          <el-input
            v-model="form.account"
            placeholder="账号 / 手机号"
            size="large"
            clearable
          />
        </el-form-item>
        <el-form-item>
          <el-input
            v-model="form.password"
            type="password"
            placeholder="密码"
            size="large"
            show-password
            @keyup.enter="onSubmit"
          />
        </el-form-item>
        <el-form-item>
          <el-button
            type="primary"
            size="large"
            style="width: 100%"
            :loading="loading"
            @click="onSubmit"
          >
            登 录
          </el-button>
        </el-form-item>
      </el-form>
    </el-card>
  </div>
</template>

<script setup>
import { reactive, ref } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { ElMessage } from 'element-plus'
import { login } from '../store/auth'

const router = useRouter()
const route = useRoute()
const loading = ref(false)
const form = reactive({ account: '', password: '' })

async function onSubmit() {
  if (!form.account || !form.password) {
    ElMessage.warning('请输入账号和密码')
    return
  }
  loading.value = true
  try {
    await login(form.account.trim(), form.password)
    ElMessage.success('登录成功')
    router.push(route.query.redirect || '/')
  } catch (e) {
    ElMessage.error(e.message || '登录失败')
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
.login-page {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #1f2937, #111827);
}
.login-card {
  width: 380px;
  padding: 8px;
}
.login-title {
  margin: 0;
  text-align: center;
  font-size: 22px;
}
.login-sub {
  margin: 6px 0 20px;
  text-align: center;
  color: #9ca3af;
  font-size: 13px;
}
</style>
