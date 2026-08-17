<template>
  <el-card>
    <template #header>
      <div class="card-header">
        <span>角色权限</span>
        <el-button v-if="hasPerm('role:save')" type="primary" @click="openCreate">
          新增角色
        </el-button>
      </div>
    </template>

    <el-table :data="roles" v-loading="loading" stripe>
      <el-table-column prop="id" label="ID" width="70" />
      <el-table-column prop="name" label="角色名称" />
      <el-table-column prop="remark" label="备注" />
      <el-table-column label="权限">
        <template #default="{ row }">
          <el-tag
            v-for="p in row.perms || []"
            :key="p"
            size="small"
            style="margin: 2px"
          >
            {{ permNameMap[p] || p }}
          </el-tag>
          <span v-if="!(row.perms || []).length">-</span>
        </template>
      </el-table-column>
      <el-table-column label="类型" width="90">
        <template #default="{ row }">
          <el-tag v-if="row.builtin === 1" type="warning" size="small">内置</el-tag>
          <el-tag v-else type="info" size="small">自建</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="操作" width="150" fixed="right">
        <template #default="{ row }">
          <el-button
            v-if="hasPerm('role:save')"
            link
            type="primary"
            @click="openEdit(row)"
          >
            编辑
          </el-button>
          <el-button
            v-if="hasPerm('role:delete') && row.builtin !== 1"
            link
            type="danger"
            @click="onDelete(row)"
          >
            删除
          </el-button>
        </template>
      </el-table-column>
    </el-table>

    <!-- 新增/编辑弹窗 -->
    <el-dialog v-model="dialog.visible" :title="dialog.id ? '编辑角色' : '新增角色'" width="520px">
      <el-form :model="form" label-width="80px">
        <el-form-item label="角色名称" required>
          <el-input v-model="form.name" placeholder="如：客服、运营" />
        </el-form-item>
        <el-form-item label="备注">
          <el-input v-model="form.remark" />
        </el-form-item>
        <el-form-item label="权限">
          <div v-for="group in permGroups" :key="group.module" class="perm-group">
            <div class="perm-module">{{ group.module }}</div>
            <el-checkbox-group v-model="form.perms">
              <el-checkbox
                v-for="item in group.items"
                :key="item.code"
                :value="item.code"
              >
                {{ item.name }}
              </el-checkbox>
            </el-checkbox-group>
          </div>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialog.visible = false">取消</el-button>
        <el-button type="primary" :loading="saving" @click="onSave">保存</el-button>
      </template>
    </el-dialog>
  </el-card>
</template>

<script setup>
import { computed, onMounted, reactive, ref } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { request } from '../utils/request'
import { hasPerm } from '../store/auth'

const loading = ref(false)
const saving = ref(false)
const roles = ref([])
const permCodes = ref([]) // { code, name, module }[]

// 权限码按模块分组
const permGroups = computed(() => {
  const map = new Map()
  for (const item of permCodes.value) {
    if (!map.has(item.module)) map.set(item.module, [])
    map.get(item.module).push(item)
  }
  return [...map.entries()].map(([module, items]) => ({ module, items }))
})

const permNameMap = computed(() => {
  const m = {}
  for (const item of permCodes.value) m[item.code] = item.name
  return m
})

const dialog = reactive({ visible: false, id: 0 })
const form = reactive({ name: '', remark: '', perms: [] })

async function load() {
  loading.value = true
  try {
    roles.value = (await request('/merchant/role/list')) || []
  } catch (e) {
    ElMessage.error(e.message)
  } finally {
    loading.value = false
  }
}

async function loadPermCodes() {
  try {
    const data = await request('/merchant/perm/codes')
    permCodes.value = data?.data || []
  } catch (e) {
    ElMessage.error(e.message)
  }
}

function openCreate() {
  dialog.id = 0
  Object.assign(form, { name: '', remark: '', perms: [] })
  dialog.visible = true
}

function openEdit(row) {
  dialog.id = row.id
  Object.assign(form, {
    name: row.name,
    remark: row.remark || '',
    perms: [...(row.perms || [])],
  })
  dialog.visible = true
}

async function onSave() {
  if (!form.name) {
    ElMessage.warning('请输入角色名称')
    return
  }
  saving.value = true
  try {
    await request('/merchant/role/save', {
      method: 'POST',
      body: {
        id: dialog.id || undefined,
        name: form.name,
        remark: form.remark,
        perms: form.perms,
      },
    })
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
    await ElMessageBox.confirm(`确定删除角色「${row.name}」？`, '提示', { type: 'warning' })
    await request('/merchant/role/delete', { method: 'POST', body: { ids: [row.id] } })
    ElMessage.success('删除成功')
    load()
  } catch (e) {
    if (e !== 'cancel') ElMessage.error(e.message)
  }
}

onMounted(() => {
  load()
  loadPermCodes()
})
</script>

<style scoped>
.card-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
}
.perm-group {
  width: 100%;
  margin-bottom: 8px;
}
.perm-module {
  font-weight: 600;
  margin-bottom: 4px;
  color: #6b7280;
}
</style>
