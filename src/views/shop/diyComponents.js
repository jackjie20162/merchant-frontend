/**
 * DIY 页面组件注册表（移植自后台 plugin/zzhshopR2 diyComponents.ts）
 * 组件默认值与 PHP wanlshop page.js module 定义保持一致，
 * item 结构: { name, type, style, params, data }
 */

export const diyGroups = [
  {
    key: 'Basics',
    label: '基础组件',
    items: [
      {
        name: '轮播组件',
        type: 'banner',
        icon: '🖼',
        style: { color: '#000000' },
        params: { interval: '2800', height: '115px', banstyle: '1' },
        data: [{ image: '', tips: '尽量使用高像素素材，否则可能出现虚化', link: '' }],
      },
      {
        name: '图片橱窗',
        type: 'image',
        icon: '🏞',
        params: { imgLayout: 1, imgPaddingTb: '1px', imgPaddingLf: '1px' },
        style: { margin: '-1px', padding: '12.5px' },
        data: [{ image: '', link: '' }],
      },
      {
        name: '视频组件',
        type: 'video',
        icon: '▶',
        style: {},
        data: [{ image: '', video: '' }],
      },
      {
        name: '菜单组件',
        type: 'menu',
        icon: '▦',
        params: {
          menuType: 'icon',
          colfive: '5',
          menuMarginTop: '12.5px',
          menuMarginBottom: '5px',
          menuHeightWidth: '45px',
          menuIconSize: '28px',
          menuBorderRadius: '1000px',
          menuTextSize: '12px',
        },
        style: { color: '#333333', 'padding-bottom': '12.5px' },
        data: [
          {
            text: '菜单一',
            icon: 'wlIcon-leimu',
            iconClass: 'wanl-text-white',
            iconImage: '',
            bgClass: 'wanl-bg-redorange',
            link: '',
          },
        ],
      },
      {
        name: '公告栏',
        type: 'notice',
        icon: '📢',
        params: { show: true },
        style: {
          'background-color': '#fffbe8',
          color: '#de8f1c',
          padding: '2px 12.5px',
        },
        data: [{ content: '公告内容', link: '' }],
      },
      {
        name: '文章组件',
        type: 'article',
        icon: '📄',
        params: { showTime: true, showView: true },
        style: { padding: '12.5px 12.5px', 'background-color': '#ffffff' },
        data: [{ image: '', tips: '建议尺寸750x360', articleLink: '' }],
      },
      {
        name: '头条组件',
        type: 'headlines',
        icon: '📰',
        style: {
          'background-color': '#ffffff',
          'border-radius': '8px',
          margin: '12.5px',
        },
        data: [
          {
            image: '',
            tips: '右侧图片，建议尺寸200x200',
            link: '',
            title: '温馨提示：三面三项为右侧广告位配置，新闻根据后台自动获取',
          },
        ],
      },
      {
        name: '搜索栏',
        type: 'search',
        icon: '🔍',
        params: {
          searchRadius: '2000px',
          searchBackground: '#eee',
          searchPadding: '6px 15px',
        },
        style: { padding: '12.5px' },
        data: [{ content: '关键字请用空格 隔开' }],
      },
    ],
  },
  {
    key: 'Advert',
    label: '广告组件',
    items: [
      {
        name: '轮播组件',
        type: 'advertBanner',
        icon: '🎠',
        style: { color: '#000000' },
        params: { interval: '2800', height: '115px', banstyle: '1' },
        data: [{ title: '系统自动获取-广告管理-【自定义页面广告】-轮播图' }],
      },
      {
        name: '图片组件',
        type: 'advertImage',
        icon: '📷',
        style: { height: '100px', width: '100%' },
        data: [{ advertLink: '' }],
      },
    ],
  },
  {
    key: 'Shop',
    label: '商城组件',
    items: [
      {
        name: '活动橱窗',
        type: 'activity',
        icon: '🎁',
        style: {
          'background-color': '#ffffff',
          'border-radius': '10px',
          overflow: 'hidden',
          margin: '12.5px',
        },
        params: { activityBackground: null, colStyle: 'col-2-2-4' },
        data: [
          {
            activity: 'rush',
            textColor: 'wanl-pip',
            describe: '30天包退 365天包换',
            tags: '新品尝鲜',
            title: '自动获取商品',
          },
        ],
      },
      {
        name: '类目标题',
        type: 'categoryTitle',
        icon: '🏷',
        style: { margin: '12.5px' },
        data: [
          { categoryName: '默认名', categoryIcon: 'wlIcon-huomiao2', categoryLink: '' },
        ],
      },
      {
        name: '分类橱窗',
        type: 'classify',
        icon: '🗂',
        style: {
          'background-color': '#ffffff',
          'border-radius': '10px',
          overflow: 'hidden',
          margin: '12.5px',
        },
        params: { classifyBackground: null, colStyle: 'col-2-2-4' },
        data: [
          {
            categoryId: 10,
            textColor: 'wanl-pip',
            describe: '30天包退 365天包换',
            tags: '新品尝鲜',
          },
        ],
      },
      {
        name: '猜你喜欢',
        type: 'likes',
        icon: '❤',
        style: { 'background-color': '#f5f5f5' },
        params: { colthree: '2', colmargin: '25' },
        data: [{ title: '自动获取系统猜你喜欢数据' }],
      },
      {
        name: '拼团组件',
        type: 'groups',
        icon: '👥',
        style: {
          'background-color': '#ffffff',
          'border-radius': '10px',
          overflow: 'hidden',
          margin: '12.5px',
        },
        params: {
          groupsBackground: null,
          colmargin: '25',
          titleText: '热门拼团',
          titleColor: '#333333',
          titleFontSize: '14px',
          infoText: '拼着买，更便宜~',
          infoColor: '#999999',
          infoFontSize: '12px',
        },
        data: [{ title: '自动获取商品' }],
      },
      {
        name: '商品组件',
        type: 'goods',
        icon: '🛒',
        style: { 'background-color': '#f5f5f5' },
        params: { colthree: '2', colmargin: '25' },
        data: [{ goodsLink: 1 }],
      },
    ],
  },
  {
    key: 'Tool',
    label: '辅助组件',
    items: [
      {
        name: '空白行',
        type: 'empty',
        icon: '▭',
        style: { height: '25px' },
        data: [],
      },
      {
        name: '分隔符',
        type: 'division',
        icon: '—',
        style: { width: '100%', padding: '12.5px' },
        params: {
          lineWidth: '60%',
          lineHeight: '1px',
          lineBackground: '#bababa',
          lineText: '文字内容',
          lineTextColor: '#333333',
          lineTextSize: '14px',
          lineTextBackground: '#ffffff',
          lineTextPadding: '0 9px',
        },
        data: [],
      },
    ],
  },
]

/** CSS 样式属性目录（与 PHP moduleStyle 一致），用于“CSS样式”页签追加属性 */
export const moduleStyleCatalog = {
  height: '高度（px）',
  width: '宽度（%）',
  'background-image': '背景图片（绝对路径）',
  'background-color': '背景颜色（HEX）',
  'background-repeat': '背景重复方式',
  color: '字体颜色',
  'font-size': '字体大小（px）',
  'text-align': '对齐方式',
  'line-height': '段落高度（px）',
  border: '边框',
  'border-bottom': '下边框',
  'border-left': '左边框',
  'border-right': '右边框',
  'border-top': '上边框',
  'border-radius': '圆角（px）',
  margin: '外边距',
  'margin-bottom': '下外边（px）',
  'margin-right': '右外边（px）',
  'margin-left': '左外边（px）',
  'margin-top': '上外边（px）',
  padding: '内边距',
  'padding-bottom': '下内边（px）',
  'padding-left': '左内边（px）',
  'padding-right': '右内边（px）',
  'padding-top': '上内边（px）',
  overflow: '溢出隐藏',
}

/** 数据字段中文名映射，未命中时直接展示键名 */
export const dataKeyLabelMap = {
  image: '图片',
  iconImage: '菜单图片',
  icon: '图标类名',
  categoryIcon: '图标类名',
  iconClass: 'icon颜色',
  bgClass: '背景类名',
  link: '链接',
  articleLink: '文章链接',
  advertLink: '广告链接',
  categoryLink: '分类链接',
  content: '内容',
  text: '文字',
  video: '视频地址',
  categoryName: '类目名称',
  categoryId: '分类ID',
  activity: '活动标识',
  textColor: '文字颜色类名',
  describe: '描述',
  tags: '标签',
  goodsLink: '商品ID',
}

/** params 字段中文名映射 */
export const paramsKeyLabelMap = {
  interval: '轮播间隔（ms）',
  height: '高度',
  banstyle: '轮播样式',
  imgLayout: '布局方式',
  imgPaddingTb: '上下间距',
  imgPaddingLf: '左右间距',
  menuType: '菜单类型',
  colfive: '每行列数',
  menuMarginTop: '上边距',
  menuMarginBottom: '图标下边距',
  menuHeightWidth: '图标宽高',
  menuIconSize: '图标字号',
  menuBorderRadius: '图标圆角',
  menuTextSize: '文字字号',
  show: '显示图标',
  showTime: '显示时间',
  showView: '显示浏览量',
  searchRadius: '圆角',
  searchBackground: '背景色',
  searchPadding: '内边距',
  activityBackground: '活动背景图',
  colStyle: '布局样式',
  classifyBackground: '分类背景图',
  colthree: '每行列数',
  colmargin: '列间距',
  groupsBackground: '拼团背景图',
  titleText: '标题文字',
  titleColor: '标题颜色',
  titleFontSize: '标题字号',
  infoText: '副标题文字',
  infoColor: '副标题颜色',
  infoFontSize: '副标题字号',
  lineWidth: '线宽度',
  lineHeight: '线高度',
  lineBackground: '线颜色',
  lineText: '文字内容',
  lineTextColor: '文字颜色',
  lineTextSize: '文字字号',
  lineTextBackground: '文字背景',
  lineTextPadding: '文字内边距',
}

/** 页面级默认配置（导航/页面背景） */
export function defaultPageConfig() {
  return {
    params: {
      navigationBarTitleText: '标题',
    },
    style: {
      navigationBackgroundImage: '',
      navigationBarBackgroundColor: '#ffffff',
      navigationBarTextStyle: '#000000',
      pageBackgroundImage: '',
      pageBackgroundColor: '#f5f5f5',
      pageBackgroundRepeat: 'no-repeat',
    },
  }
}

/** 深拷贝组件默认模板，作为新组件加入页面 */
export function cloneComponentDef(def) {
  return structuredClone({
    name: def.name,
    type: def.type,
    style: def.style ?? {},
    params: def.params ?? {},
    data: structuredClone(def.data),
  })
}
