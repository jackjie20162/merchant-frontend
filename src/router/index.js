import { createRouter, createWebHistory } from 'vue-router'
import { getToken, } from '../utils/request'

const routes = [
  {
    path: '/login',
    name: 'Login',
    component: () => import('../views/Login.vue'),
  },
  {
    path: '/',
    component: () => import('../views/Layout.vue'),
    redirect: '/dashboard',
    children: [
      {
        path: 'dashboard',
        name: 'Dashboard',
        component: () => import('../views/Dashboard.vue'),
        meta: { title: '工作台', perm: 'dashboard:view' },
      },
      {
        path: 'trade/order',
        name: 'TradeOrder',
        component: () => import('../views/trade/Order.vue'),
        meta: { title: '商品订单', perm: 'order:list' },
      },
      {
        path: 'trade/groups',
        name: 'TradeGroups',
        component: () => import('../views/trade/GroupOrder.vue'),
        meta: { title: '拼团订单', perm: 'groups:list' },
      },
      {
        path: 'trade/comment',
        name: 'TradeComment',
        component: () => import('../views/trade/Comment.vue'),
        meta: { title: '商品评论', perm: 'comment:list' },
      },
      {
        path: 'trade/refund',
        name: 'TradeRefund',
        component: () => import('../views/trade/Refund.vue'),
        meta: { title: '退款管理', perm: 'refund:list' },
      },
      {
        path: 'goods/sale',
        name: 'GoodsSale',
        component: () => import('../views/goods/GoodsList.vue'),
        meta: { title: '出售中的商品', perm: 'goods:list', grounding: 1 },
      },
      {
        path: 'goods/warehouse',
        name: 'GoodsWarehouse',
        component: () => import('../views/goods/GoodsList.vue'),
        meta: { title: '仓库中的商品', perm: 'goods:list', grounding: 0 },
      },
      {
        path: 'goods/edit',
        name: 'GoodsCreate',
        component: () => import('../views/goods/GoodsEdit.vue'),
        meta: { title: '发布商品', perm: 'goods:save' },
      },
      {
        path: 'goods/edit/:id',
        name: 'GoodsEdit',
        component: () => import('../views/goods/GoodsEdit.vue'),
        meta: { title: '编辑商品', perm: 'goods:save' },
      },
      {
        path: 'category',
        name: 'Category',
        component: () => import('../views/category/Index.vue'),
        meta: { title: '自定义类目', perm: 'category:list' },
      },
      {
        path: 'marketing/coupon',
        name: 'MarketingCoupon',
        component: () => import('../views/marketing/Coupon.vue'),
        meta: { title: '优惠券', perm: 'coupon:list' },
      },
      {
        path: 'freight/template',
        name: 'FreightTemplate',
        component: () => import('../views/freight/Freight.vue'),
        meta: { title: '运费模板', perm: 'freight:list' },
      },
      {
        path: 'finance/bill',
        name: 'FinanceBill',
        component: () => import('../views/finance/Bill.vue'),
        meta: { title: '商家对账单', perm: 'bill:list' },
      },
      {
        path: 'finance/withdraw',
        name: 'FinanceWithdraw',
        component: () => import('../views/finance/Withdraw.vue'),
        meta: { title: '商家提现', perm: 'withdraw:list' },
      },
      {
        path: 'shop/info',
        name: 'ShopInfo',
        component: () => import('../views/shop/ShopInfo.vue'),
        meta: { title: '店铺资料' },
      },
      {
        path: 'shop/brand',
        name: 'ShopBrand',
        component: () => import('../views/shop/Brand.vue'),
        meta: { title: '品牌管理', perm: 'brand:list' },
      },
      {
        path: 'shop/image-space',
        name: 'ImageSpace',
        component: () => import('../views/shop/ImageSpace.vue'),
        meta: { title: '图片空间', perm: 'attach:list' },
      },
      {
        path: 'shop/decorate',
        name: 'ShopDecorate',
        component: () => import('../views/shop/Decorate.vue'),
        meta: { title: '装修店铺', perm: 'page:list' },
      },
      {
        path: 'shop/diy/:id',
        name: 'ShopDiy',
        component: () => import('../views/shop/DiyEditor.vue'),
        meta: { title: '页面装修', perm: 'page:save' },
      },
      {
        path: 'shop/settings',
        name: 'ShopSettings',
        component: () => import('../views/shop/Settings.vue'),
        meta: { title: '店铺配置', perm: 'shop:config' },
      },
      {
        path: 'staff',
        name: 'Staff',
        component: () => import('../views/Staff.vue'),
        meta: { title: '员工管理', perm: 'staff:list' },
      },
      {
        path: 'role',
        name: 'Role',
        component: () => import('../views/Role.vue'),
        meta: { title: '角色权限', perm: 'role:list' },
      },
    ],
  },
]

const router = createRouter({
  history: createWebHistory(),
  routes,
})

// 路由守卫：登录态 + 权限码
router.beforeEach((to) => {
  if (to.path === '/login') return true
  if (!getToken()) return { path: '/login', query: { redirect: to.fullPath } }
  const perm = to.meta?.perm
  if (perm) {
    // Layout 加载 profile 前放行，Layout 内部会按权限处理菜单
    return true
  }
  return true
})

export default router
