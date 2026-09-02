<template>
  <el-container class="layout"><el-aside width="210px" class="layout-aside"><div class="logo">商户控制台</div><el-menu :default-active="$route.path" router class="layout-menu"><template v-for="item in visibleMenus" :key="item.title"><el-sub-menu v-if="item.children" :index="item.title"><template #title><span>{{ item.title }}</span></template><el-menu-item v-for="child in item.children" :key="child.path" :index="child.path"><span>{{ child.title }}</span></el-menu-item></el-sub-menu><el-menu-item v-else :index="item.path"><span>{{ item.title }}</span></el-menu-item></template></el-menu></el-aside><el-container><el-header class="layout-header"><div class="shop-name">{{ shopName }}</div><div class="user-area"><el-tag v-if="isOwner()" type="warning" size="small">主账号</el-tag><el-tag v-else type="info" size="small">员工</el-tag><span class="nickname">{{ nickname }}</span><el-button link type="danger" @click="onLogout">退出</el-button></div></el-header><el-main class="layout-main"><router-view v-if="ready" /></el-main></el-container></el-container>
</template>
<script setup>
import { computed, onMounted, ref } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { auth, fetchProfile, hasPerm, isOwner, logout } from '../store/auth'
const router=useRouter(),ready=ref(false)
const menus=[
 {path:'/dashboard',title:'工作台',perm:'dashboard:view'},
 {title:'旅游管理',children:[{path:'/plugin/travel/dashboard/index',title:'旅游工作台',perm:'travel:dashboard:view'},{path:'/plugin/travel/products/index',title:'旅游产品',perm:'travel:product:list'},{path:'/plugin/travel/inventory/index',title:'旅游库存',perm:'travel:inventory:check'},{path:'/plugin/travel/orders/index',title:'旅游订单',perm:'travel:order:list'},{path:'/plugin/travel/payment/index',title:'旅游支付',perm:'travel:payment:create'}]},
 {title:'数全宝商户中心',children:[{path:'/plugin/hwsj/dashboard/index',title:'数据统计'},{path:'/plugin/hwsj/member/index',title:'会员管理'},{path:'/plugin/hwsj/orders/index',title:'订单与对账'},{path:'/plugin/hwsj/reconciliation/index',title:'对账差异'},{path:'/plugin/hwsj/flows/index',title:'资金流水'},{path:'/plugin/hwsj/messages/index',title:'消息提醒'},{path:'/plugin/hwsj/profile/index',title:'商户信息'},{path:'/plugin/hwsj/recharge/index',title:'预存款充值'},{path:'/plugin/hwsj/huifu-enter/index',title:'汇付进件'},{path:'/plugin/hwsj/withdraw/index',title:'提现管理'},{path:'/plugin/hwsj/apikey/index',title:'API Key 管理'}]},
 {title:'Temu 网关',children:[{path:'/plugin/temu/key/index',title:'用户密钥'},{path:'/plugin/temu/logs/index',title:'请求记录'},{path:'/plugin/temu/debug/index',title:'接口调试'}]},
 {title:'交易管理',children:[{path:'/trade/order',title:'商品订单',perm:'order:list'},{path:'/trade/comment',title:'商品评论',perm:'comment:list'},{path:'/trade/refund',title:'退款管理',perm:'refund:list'}]},
 {title:'阶梯拼团',children:[{path:'/groups/goods',title:'商品列表',perm:'groups:goods:list'},{path:'/groups/manage',title:'拼团管理',perm:'groups:manage:list'},{path:'/groups/order',title:'订单管理',perm:'groups:list'}]},
 {path:'/find',title:'种草短视频',perm:'find:list'},
 {title:'商品管理',children:[{path:'/goods/sale',title:'出售中的商品',perm:'goods:list'},{path:'/goods/warehouse',title:'仓库中的商品',perm:'goods:list'},{path:'/category',title:'自定义类目',perm:'category:list'}]},
 {title:'营销活动',children:[{path:'/marketing/coupon',title:'优惠券',perm:'coupon:list'}]},
 {title:'物流运费',children:[{path:'/freight/template',title:'运费模板',perm:'freight:list'}]},
 {title:'财务管理',children:[{path:'/finance/bill',title:'商家对账单',perm:'bill:list'},{path:'/finance/withdraw',title:'商家提现',perm:'withdraw:list'}]},
 {title:'店铺管理',children:[{path:'/shop/info',title:'店铺资料'},{path:'/shop/decorate',title:'装修店铺',perm:'page:list'},{path:'/shop/brand',title:'品牌管理',perm:'brand:list'},{path:'/shop/image-space',title:'图片空间',perm:'attach:list'},{path:'/shop/settings',title:'店铺配置',perm:'shop:config'}]},
 {path:'/staff',title:'员工管理',perm:'staff:list'},{path:'/role',title:'角色权限',perm:'role:list'},
]
const visibleMenus=computed(()=>menus.map(m=>m.children?{...m,children:m.children.filter(c=>!c.perm||hasPerm(c.perm))}:m).filter(m=>m.children?m.children.length>0:!m.perm||hasPerm(m.perm)))
const firstVisiblePath=computed(()=>{for(const m of visibleMenus.value)return m.children?m.children[0]?.path:m.path;return '/login'})
const shopName=computed(()=>auth.profile?.shop?.shopname||'我的店铺'),nickname=computed(()=>auth.profile?.staff?.nickname||auth.profile?.merchant?.nickname||'')
onMounted(async()=>{try{await fetchProfile();ready.value=true;const perm=router.currentRoute.value.meta?.perm;if(perm&&!hasPerm(perm))router.replace(firstVisiblePath.value)}catch(e){ElMessage.error(e.message||'加载资料失败')}})
function onLogout(){logout();router.push('/login')}
</script>
<style scoped>.layout{height:100vh}.layout-aside{background:#1f2937;overflow-y:auto}.layout-main{background:#f3f4f6;overflow-y:auto}.logo{color:#fff;font-size:16px;font-weight:600;text-align:center;padding:18px 0}.layout-menu{border-right:none;background:transparent;--el-menu-bg-color:transparent;--el-menu-text-color:#d1d5db;--el-menu-hover-bg-color:#374151;--el-menu-active-color:#f59e0b}.layout-header{display:flex;align-items:center;justify-content:space-between;background:#fff;border-bottom:1px solid #e5e7eb}.shop-name{font-weight:600}.user-area{display:flex;align-items:center;gap:8px}.nickname{font-size:14px}</style>
