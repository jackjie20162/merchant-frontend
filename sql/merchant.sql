-- =====================================================================
-- 商家端（租户模式）建表与初始化脚本
-- 说明：
--   1. 店铺即租户：fa_wanlshop_merchant.shop_id 绑定 fa_wanlshop_shop.id
--   2. 商家主账号登录后可新增员工账号（fa_wanlshop_shop_staff），
--      员工权限由店铺角色（fa_wanlshop_shop_role.perms 逗号分隔权限码）控制
--   3. 密码规则与 fa_user 一致：md5(md5(明文) + salt)
--   4. 种子数据默认绑定 shop_id=2（当前库中实际存在的店铺），若实际店铺ID不同请自行调整
--   5. 导入方式（避免 PowerShell 管道按 GBK 转码损坏中文）：
--        docker cp sql/merchant.sql mysql:/tmp/merchant.sql
--        docker exec mysql sh -c "mysql -uroot -p123456 --default-character-set=utf8mb4 < /tmp/merchant.sql"
-- =====================================================================

USE simple_admin;

-- ----------------------------
-- 商家主账号表
-- ----------------------------
CREATE TABLE IF NOT EXISTS `fa_wanlshop_merchant` (
  `id` int unsigned NOT NULL AUTO_INCREMENT COMMENT '商家ID',
  `shop_id` int unsigned NOT NULL DEFAULT '0' COMMENT '店铺ID:0=未开店',
  `username` varchar(64) NOT NULL DEFAULT '' COMMENT '登录账号',
  `password` varchar(64) NOT NULL DEFAULT '' COMMENT '密码',
  `salt` varchar(30) NOT NULL DEFAULT '' COMMENT '密码盐',
  `nickname` varchar(64) NOT NULL DEFAULT '' COMMENT '昵称',
  `mobile` varchar(20) NOT NULL DEFAULT '' COMMENT '手机号',
  `avatar` varchar(255) NOT NULL DEFAULT '' COMMENT '头像',
  `prevtime` int unsigned NOT NULL DEFAULT '0' COMMENT '上次登录时间',
  `logintime` int unsigned NOT NULL DEFAULT '0' COMMENT '登录时间',
  `createtime` int unsigned DEFAULT NULL COMMENT '创建时间',
  `updatetime` int unsigned DEFAULT NULL COMMENT '更新时间',
  `deletetime` int unsigned DEFAULT NULL COMMENT '删除时间',
  `status` enum('normal','hidden') NOT NULL DEFAULT 'normal' COMMENT '状态',
  PRIMARY KEY (`id`),
  KEY `idx_shop_id` (`shop_id`),
  KEY `idx_username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='商家主账号表';

-- ----------------------------
-- 店铺员工账号表
-- ----------------------------
CREATE TABLE IF NOT EXISTS `fa_wanlshop_shop_staff` (
  `id` int unsigned NOT NULL AUTO_INCREMENT COMMENT '员工ID',
  `shop_id` int unsigned NOT NULL DEFAULT '0' COMMENT '店铺ID',
  `merchant_id` int unsigned NOT NULL DEFAULT '0' COMMENT '商家主账号ID',
  `username` varchar(64) NOT NULL DEFAULT '' COMMENT '登录账号',
  `password` varchar(64) NOT NULL DEFAULT '' COMMENT '密码',
  `salt` varchar(30) NOT NULL DEFAULT '' COMMENT '密码盐',
  `nickname` varchar(64) NOT NULL DEFAULT '' COMMENT '昵称',
  `mobile` varchar(20) NOT NULL DEFAULT '' COMMENT '手机号',
  `avatar` varchar(255) NOT NULL DEFAULT '' COMMENT '头像',
  `role_id` int unsigned NOT NULL DEFAULT '0' COMMENT '角色ID',
  `logintime` int unsigned NOT NULL DEFAULT '0' COMMENT '最后登录时间',
  `createtime` int unsigned DEFAULT NULL COMMENT '创建时间',
  `updatetime` int unsigned DEFAULT NULL COMMENT '更新时间',
  `deletetime` int unsigned DEFAULT NULL COMMENT '删除时间',
  `status` enum('normal','hidden') NOT NULL DEFAULT 'normal' COMMENT '状态',
  PRIMARY KEY (`id`),
  KEY `idx_shop_id` (`shop_id`),
  KEY `idx_username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='店铺员工账号表';

-- ----------------------------
-- 店铺角色表（perms 存逗号分隔的权限码）
-- ----------------------------
CREATE TABLE IF NOT EXISTS `fa_wanlshop_shop_role` (
  `id` int unsigned NOT NULL AUTO_INCREMENT COMMENT '角色ID',
  `shop_id` int unsigned NOT NULL DEFAULT '0' COMMENT '店铺ID',
  `name` varchar(64) NOT NULL DEFAULT '' COMMENT '角色名称',
  `remark` varchar(255) NOT NULL DEFAULT '' COMMENT '备注',
  `perms` text COMMENT '权限码(逗号分隔)',
  `builtin` tinyint unsigned NOT NULL DEFAULT '0' COMMENT '是否内置:0=自建,1=内置不可删除',
  `createtime` int unsigned DEFAULT NULL COMMENT '创建时间',
  `updatetime` int unsigned DEFAULT NULL COMMENT '更新时间',
  `status` enum('normal','hidden') NOT NULL DEFAULT 'normal' COMMENT '状态',
  PRIMARY KEY (`id`),
  KEY `idx_shop_id` (`shop_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='店铺角色表';

-- =====================================================================
-- 种子数据（演示用，生产环境请删除或修改）
-- =====================================================================

-- 商家主账号：admin / 123456（绑定店铺2）
INSERT INTO `fa_wanlshop_merchant` (`id`, `shop_id`, `username`, `password`, `salt`, `nickname`, `createtime`, `updatetime`)
VALUES (1, 2, 'admin', 'a4a942d189f8ef654712d609bf8fd0e3', 'zzhshopR21', '店主', UNIX_TIMESTAMP(), UNIX_TIMESTAMP())
ON DUPLICATE KEY UPDATE `shop_id` = 2, `updatetime` = UNIX_TIMESTAMP();

-- 内置角色：客服（员工管理只读 + 工作台）
INSERT INTO `fa_wanlshop_shop_role` (`id`, `shop_id`, `name`, `remark`, `perms`, `builtin`, `createtime`, `updatetime`)
VALUES (1, 2, '客服', '内置角色：仅工作台与员工查看权限', 'dashboard:view,staff:list', 1, UNIX_TIMESTAMP(), UNIX_TIMESTAMP())
ON DUPLICATE KEY UPDATE `shop_id` = 2, `updatetime` = UNIX_TIMESTAMP();

-- 演示员工：kefu / 123456（角色=客服）
INSERT INTO `fa_wanlshop_shop_staff` (`id`, `shop_id`, `merchant_id`, `username`, `password`, `salt`, `nickname`, `role_id`, `createtime`, `updatetime`)
VALUES (1, 2, 1, 'kefu', '591b36401fe92a36592aad4831084a2d', 'zzhshopR22', '客服小王', 1, UNIX_TIMESTAMP(), UNIX_TIMESTAMP())
ON DUPLICATE KEY UPDATE `shop_id` = 2, `updatetime` = UNIX_TIMESTAMP();
