import { createRouter, createWebHistory } from 'vue-router'
import { getToken } from '../utils/request'

const routes = [
  { path: '/login', name: 'Login', component: () => import('../views/Login.vue') },
  {
    path: '/', component: () => import('../views/Layout.vue'), redirect: '/dashboard',
    children: [
      { path: 'dashboard', name: 'Dashboard', component: () => import('../views/Dashboard.vue'), meta: { title: '工作台', perm: 'dashboard:view' } },
      { path: 'trade/order', name: 'TradeOrder', component: () => import('../views/trade/Order.vue'), meta: { title: '商品订单', perm: 'order:list' } },
      { path: 'groups/goods', name: 'GroupsGoods', component: () => import('../views/groups/GroupsGoodsList.vue'), meta: { title: '拼团商品', perm: 'groups:goods:list' } },
      { path: 'groups/goods/edit', name: 'GroupsGoodsCreate', component: () => import('../views/groups/GroupsGoodsEdit.vue'), meta: { title: '发布拼团商品', perm: 'groups:goods:save' } },
      { path: 'groups/goods/edit/:id', name: 'GroupsGoodsEdit', component: () => import('../views/groups/GroupsGoodsEdit.vue'), meta: { title: '编辑拼团商品', perm: 'groups:goods:save' } },
      { path: 'groups/manage', name: 'GroupsManage', component: () => import('../views/groups/GroupsManage.vue'), meta: { title: '拼团管理', perm: 'groups:manage:list' } },
      { path: 'groups/order', name: 'GroupsOrder', component: () => import('../views/trade/GroupOrder.vue'), meta: { title: '拼团订单', perm: 'groups:list' } },
      { path: 'find', name: 'Find', component: () => import('../views/find/FindList.vue'), meta: { title: '种草短视频', perm: 'find:list' } },
      { path: 'trade/comment', name: 'TradeComment', component: () => import('../views/trade/Comment.vue'), meta: { title: '商品评论', perm: 'comment:list' } },
      { path: 'trade/refund', name: 'TradeRefund', component: () => import('../views/trade/Refund.vue'), meta: { title: '退款管理', perm: 'refund:list' } },
      { path: 'goods/sale', name: 'GoodsSale', component: () => import('../views/goods/GoodsList.vue'), meta: { title: '出售中的商品', perm: 'goods:list', grounding: 1 } },
      { path: 'goods/warehouse', name: 'GoodsWarehouse', component: () => import('../views/goods/GoodsList.vue'), meta: { title: '仓库中的商品', perm: 'goods:list', grounding: 0 } },
      { path: 'goods/edit', name: 'GoodsCreate', component: () => import('../views/goods/GoodsEdit.vue'), meta: { title: '发布商品', perm: 'goods:save' } },
      { path: 'goods/edit/:id', name: 'GoodsEdit', component: () => import('../views/goods/GoodsEdit.vue'), meta: { title: '编辑商品', perm: 'goods:save' } },
      { path: 'category', name: 'Category', component: () => import('../views/category/Index.vue'), meta: { title: '自定义类目', perm: 'category:list' } },
      { path: 'marketing/coupon', name: 'MarketingCoupon', component: () => import('../views/marketing/Coupon.vue'), meta: { title: '优惠券', perm: 'coupon:list' } },
      { path: 'freight/template', name: 'FreightTemplate', component: () => import('../views/freight/Freight.vue'), meta: { title: '运费模板', perm: 'freight:list' } },
      { path: 'finance/bill', name: 'FinanceBill', component: () => import('../views/finance/Bill.vue'), meta: { title: '商家对账单', perm: 'bill:list' } },
      { path: 'finance/withdraw', name: 'FinanceWithdraw', component: () => import('../views/finance/Withdraw.vue'), meta: { title: '商家提现', perm: 'withdraw:list' } },
      { path: 'shop/info', name: 'ShopInfo', component: () => import('../views/shop/ShopInfo.vue'), meta: { title: '店铺资料' } },
      { path: 'shop/brand', name: 'ShopBrand', component: () => import('../views/shop/Brand.vue'), meta: { title: '品牌管理', perm: 'brand:list' } },
      { path: 'shop/image-space', name: 'ImageSpace', component: () => import('../views/shop/ImageSpace.vue'), meta: { title: '图片空间', perm: 'attach:list' } },
      { path: 'shop/decorate', name: 'ShopDecorate', component: () => import('../views/shop/Decorate.vue'), meta: { title: '装修店铺', perm: 'page:list' } },
      { path: 'shop/diy/:id', name: 'ShopDiy', component: () => import('../views/shop/DiyEditor.vue'), meta: { title: '页面装修', perm: 'page:save' } },
      { path: 'shop/settings', name: 'ShopSettings', component: () => import('../views/shop/Settings.vue'), meta: { title: '店铺配置' } },
      { path: 'staff', name: 'Staff', component: () => import('../views/Staff.vue'), meta: { title: '员工管理', perm: 'staff:list' } },
      { path: 'role', name: 'Role', component: () => import('../views/Role.vue'), meta: { title: '角色权限', perm: 'role:list' } },
      { path: 'travel/products', name: 'TravelProducts', component: () => import('../views/travel/Products.vue'), meta: { title: '旅游产品', perm: 'travel:product:list' } },
      { path: 'travel/inventory', name: 'TravelInventory', component: () => import('../views/travel/Inventory.vue'), meta: { title: '旅游库存', perm: 'travel:inventory:check' } },
      { path: 'travel/orders', name: 'TravelOrders', component: () => import('../views/travel/Orders.vue'), meta: { title: '旅游订单', perm: 'travel:order:list' } },
      { path: 'plugin/travel/dashboard/index', name: 'TravelDashboard', component: () => import('../plugin/travel/dashboard/Index.vue'), meta: { title: '旅游工作台', perm: 'travel:dashboard:view' } },
      { path: 'plugin/travel/products/index', name: 'TravelPluginProducts', component: () => import('../plugin/travel/products/Index.vue'), meta: { title: '旅游产品', perm: 'travel:product:list' } },
      { path: 'plugin/travel/inventory/index', name: 'TravelPluginInventory', component: () => import('../plugin/travel/inventory/Index.vue'), meta: { title: '旅游库存', perm: 'travel:inventory:check' } },
      { path: 'plugin/travel/orders/index', name: 'TravelPluginOrders', component: () => import('../plugin/travel/orders/Index.vue'), meta: { title: '旅游订单', perm: 'travel:order:list' } },
      { path: 'plugin/travel/payment/index', name: 'TravelPluginPayment', component: () => import('../plugin/travel/payment/Index.vue'), meta: { title: '旅游支付', perm: 'travel:payment:create' } },
      { path: 'plugin/hwsj/dashboard/index', name: 'HwsjDashboard', component: () => import('../plugin/hwsj/dashboard/Index.vue'), meta: { title: '数据统计' } },
      { path: 'plugin/hwsj/profile/index', name: 'HwsjMerchantProfile', component: () => import('../plugin/hwsj/profile/Index.vue'), meta: { title: '商户信息' } },
      { path: 'plugin/hwsj/recharge/index', name: 'HwsjRecharge', component: () => import('../plugin/hwsj/recharge/Index.vue'), meta: { title: '预存款充值' } },
      { path: 'plugin/hwsj/huifu-enter/index', name: 'HwsjHuifuEnter', component: () => import('../plugin/hwsj/huifu-enter/Index.vue'), meta: { title: '汇付进件' } },
      { path: 'plugin/hwsj/messages/index', name: 'HwsjMessages', component: () => import('../plugin/hwsj/messages/Index.vue'), meta: { title: '消息提醒' } },
      { path: 'plugin/hwsj/orders/index', name: 'HwsjOrders', component: () => import('../plugin/hwsj/orders/Index.vue'), meta: { title: '订单与对账' } },
      { path: 'plugin/hwsj/reconciliation/index', name: 'HwsjReconciliation', component: () => import('../plugin/hwsj/reconciliation/Index.vue'), meta: { title: '对账差异' } },
      { path: 'plugin/hwsj/flows/index', name: 'HwsjFlows', component: () => import('../plugin/hwsj/flows/Index.vue'), meta: { title: '资金流水' } },
      { path: 'plugin/hwsj/withdraw/index', name: 'HwsjWithdraw', component: () => import('../plugin/hwsj/withdraw/Index.vue'), meta: { title: '提现管理' } },
      { path: 'plugin/hwsj/apikey/index', name: 'HwsjApiKey', component: () => import('../plugin/hwsj/apikey/Index.vue'), meta: { title: 'API Key 管理' } },
      { path: 'plugin/hwsj/member/index', name: 'HwsjMember', component: () => import('../plugin/hwsj/member/Index.vue'), meta: { title: '会员管理' } },
      { path: 'plugin/temu/key/index', name: 'TemuKey', component: () => import('../plugin/temu/key/Index.vue'), meta: { title: 'Temu 用户密钥' } },
      { path: 'plugin/temu/logs/index', name: 'TemuLogs', component: () => import('../plugin/temu/logs/Index.vue'), meta: { title: 'Temu 请求记录' } },
      { path: 'plugin/temu/debug/index', name: 'TemuDebug', component: () => import('../plugin/temu/debug/Index.vue'), meta: { title: 'Temu 接口调试' } },
    ],
  },
]

const router = createRouter({ history: createWebHistory(), routes })
router.beforeEach((to) => {
  if (to.path === '/login') return true
  if (!getToken()) return { path: '/login', query: { redirect: to.fullPath } }
  return true
})
export default router
