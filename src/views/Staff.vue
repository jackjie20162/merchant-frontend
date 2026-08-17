<template>
  <el-card>
    <template #header>
      <div class="card-header">
        <span>员工管理</span>
        <el-button
          v-if="hasPerm('staff:create')"
          type="primary"
          @click="openCreate"
        >
          新增员工
        </el-button>
      </div>
    </template>

    <el-table :data="list" v-loading="loading" stripe>
      <el-table-column prop="id" label="ID" width="70" />
      <el-table-column prop="username" label="账号" />
      <el-table-column prop="nickname" label="昵称" />
      <el-table-column prop="mobile" label="手机号" />
      <el-table-column prop="role_name" label="角色">
        <template #default="{ row }">
          {{ row.role_name || '-' }}
        </template>
      </el-table-column>
      <el-table-column label="状态" width="90">
        <template #default="{ row }">
          <el-tag :type="row.status === 'normal' ? 'success' : 'info'" size="small">
            {{ row.status === 'normal' ? '正常' : '禁用' }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column label="最后登录" width="170">
        <template #default="{ row }">{{ fmtTime(row.logintime) }}</template>
      </el-table-column>
      <el-table-column label="操作" width="220" fixed="right">
        <template #default="{ row }">
          <el-button
            v-if="hasPerm('staff:update')"
            link
            type="primary"
            @click="openEdit(row)"
          >
            编辑
          </el-button>
          <el-button
            v-if="hasPerm('staff:resetpwd')"
            link
            type="warning"
            @click="openResetPwd(row)"
          >
            重置密码
          </el-button>
          <el-button
            v-if="hasPerm('staff:delete')"
            link
            type="danger"
            @click="onDelete(row)"
          >
            删除
          </el-button>
        </template>
      </el-table-column>
    </el-table>

    <el-pagination
      v-model:current-page="query.page"
      v-model:page-size="query.page_size"
      :total="total"
      layout="total, prev, pager, next"
      style="margin-top: 12px"
      @current-change="load"
    />

    <!-- 新增/编辑弹窗 -->
    <el-dialog v-model="dialog.visible" :title="dialog.id ? '编辑员工' : '新增员工'" width="440px">
      <el-form :model="form" label-width="80px">
        <el-form-item label="账号" required>
          <el-input v-model="form.username" :disabled="!!dialog.id" placeholder="登录账号" />
        </el-form-item>
        <el-form-item v-if="!dialog.id" label="密码" required>
          <el-input v-model="form.password" type="password" show-password placeholder="初始密码" />
        </el-form-item>
        <el-form-item label="昵称">
          <el-input v-model="form.nickname" />
        </el-form-item>
        <el-form-item label="手机号">
          <el-input v-model="form.mobile" />
        </el-form-item>
        <el-form-item label="角色">
          <el-select v-model="form.role_id" clearable placeholder="不选则无权限" style="width: 100%">
            <el-option v-for="r in roles" :key="r.id" :label="r.name" :value="r.id" />
          </el-select>
        </el-form-item>
        <el-form-item v-if="dialog.id" label="状态">
          <el-radio-group v-model="form.status">
            <el-radio value="normal">正常</el-radio>
            <el-radio value="hidden">禁用</el-radio>
          </el-radio-group>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialog.visible = false">取消</el-button>
        <el-button type="primary" :loading="saving" @click="onSave">保存</el-button>
      </template>
    </el-dialog>

    <!-- 重置密码弹窗 -->
    <el-dialog v-model="pwdDialog.visible" title="重置密码" width="400px">
      <el-form label-width="80px">
        <el-form-item label="员工">
          <span>{{ pwdDialog.username }}</span>
        </el-form-item>
        <el-form-item label="新密码" required>
          <el-input v-model="pwdDialog.password" type="password" show-password />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="pwdDialog.visible = false">取消</el-button>
        <el-button type="primary" :loading="saving" @click="onResetPwd">确定</el-button>
      </template>
    </el-dialog>
  </el-card>
</template>

<script setup>
import { onMounted, reactive, ref } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { request } from '../utils/request'
import { hasPerm } from '../store/auth'

const loading = ref(false)
const saving = ref(false)
const list = ref([])
const total = ref(0)
const roles = ref([])
const query = reactive({ page: 1, page_size: 10, username: '' })

const dialog = reactive({ visible: false, id: 0 })
const form = reactive({
  username: '',
  password: '',
  nickname: '',
  mobile: '',
  role_id: undefined,
  status: 'normal',
})

const pwdDialog = reactive({ visible: false, id: 0, username: '', password: '' })

function fmtTime(ts) {
  if (!ts) return '-'
  return new Date(ts * 1000).toLocaleString()
}

async function load() {
  loading.value = true
  try {
    const data = await request('/merchant/staff/list', {
      method: 'POST',
      body: { page: query.page, page_size: query.page_size },
    })
    list.value = data.data || []
    total.value = Number(data.total || 0)
  } catch (e) {
    ElMessage.error(e.message)
  } finally {
    loading.value = false
  }
}

async function loadRoles() {
  try {
    roles.value = (await request('/merchant/role/list')) || []
  } catch {
    // 无角色权限时忽略
  }
}

function openCreate() {
  dialog.id = 0
  Object.assign(form, {
    username: '',
    password: '',
    nickname: '',
    mobile: '',
    role_id: undefined,
    status: 'normal',
  })
  dialog.visible = true
}

function openEdit(row) {
  dialog.id = row.id
  Object.assign(form, {
    username: row.username,
    password: '',
    nickname: row.nickname || '',
    mobile: row.mobile || '',
    role_id: row.role_id || undefined,
    status: row.status || 'normal',
  })
  dialog.visible = true
}

async function onSave() {
  saving.value = true
  try {
    if (dialog.id) {
      await request('/merchant/staff/update', {
        method: 'POST',
        body: {
          id: dialog.id,
          nickname: form.nickname,
          mobile: form.mobile,
          role_id: form.role_id || 0,
          status: form.status,
        },
      })
    } else {
      if (!form.username || !form.password) {
        ElMessage.warning('账号和密码为必填项')
        saving.value = false
        return
      }
      await request('/merchant/staff/create', {
        method: 'POST',
        body: {
          username: form.username,
          password: form.password,
          nickname: form.nickname,
          mobile: form.mobile,
          role_id: form.role_id || 0,
        },
      })
    }
    ElMessage.success('保存成功')
    dialog.visible = false
    load()
  } catch (e) {
    ElMessage.error(e.message)
  } finally {
    saving.value = false
  }
}

async function onDelete(row) {
  try {
    await ElMessageBox.confirm(`确定删除员工「${row.username}」？`, '提示', { type: 'warning' })
    await request('/merchant/staff/delete', { method: 'POST', body: { ids: [row.id] } })
    ElMessage.success('删除成功')
    load()
  } catch (e) {
    if (e !== 'cancel') ElMessage.error(e.message)
  }
}

function openResetPwd(row) {
  Object.assign(pwdDialog, { visible: true, id: row.id, username: row.username, password: '' })
}

async function onResetPwd() {
  if (!pwdDialog.password) {
    ElMessage.warning('请输入新密码')
    return
  }
  saving.value = true
  try {
    await request('/merchant/staff/resetpwd', {
      method: 'POST',
      body: { id: pwdDialog.id, password: pwdDialog.password },
    })
    ElMessage.success('密码已重置')
    pwdDialog.visible = false
  } catch (e) {
    ElMessage.error(e.message)
  } finally {
    saving.value = false
  }
}

onMounted(() => {
  load()
  loadRoles()
})
</script>

<style scoped>
.card-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
}
</style>
