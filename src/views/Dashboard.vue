<template>
  <div>
    <el-card v-if="auth.profile">
      <el-descriptions :column="2" border>
        <el-descriptions-item label="店铺">
          {{ auth.profile.shop?.shopname || '-' }}
        </el-descriptions-item>
        <el-descriptions-item label="登录身份">
          {{ isOwner() ? '商家主账号' : '员工账号' }}
        </el-descriptions-item>
        <el-descriptions-item label="账号">
          {{ auth.profile.staff?.username || auth.profile.merchant?.username }}
        </el-descriptions-item>
        <el-descriptions-item label="昵称">{{ nickname }}</el-descriptions-item>
        <el-descriptions-item label="角色">
          {{ auth.profile.staff?.role_name || (isOwner() ? '店主（全部权限）' : '-') }}
        </el-descriptions-item>
        <el-descriptions-item label="权限数量">
          {{ (auth.profile.perms || []).length }} 项
        </el-descriptions-item>
      </el-descriptions>
    </el-card>
    <el-card style="margin-top: 16px">
      <template #header>当前权限码</template>
      <el-tag
        v-for="p in auth.profile?.perms || []"
        :key="p"
        style="margin: 4px"
        size="small"
      >
        {{ p }}
      </el-tag>
    </el-card>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { auth, isOwner } from '../store/auth'

const nickname = computed(() =>
  auth.profile?.staff?.nickname || auth.profile?.merchant?.nickname || '-',
)
</script>
