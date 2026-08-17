-- 商家提现表（WanlShop 遗留结构 + shop_id 扩展）
-- 注意：fa_withdraw 在原库中不存在，此处按 ent schema withdraw.go 建表
CREATE TABLE IF NOT EXISTS `fa_withdraw` (
  `id` int unsigned NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `user_id` int unsigned NOT NULL DEFAULT '0' COMMENT '会员ID',
  `shop_id` int unsigned NOT NULL DEFAULT '0' COMMENT '店铺ID:0=用户提现',
  `money` double NOT NULL DEFAULT '0' COMMENT '金额',
  `handingfee` double NOT NULL DEFAULT '0' COMMENT '手续费',
  `taxes` double NOT NULL DEFAULT '0' COMMENT '税费',
  `type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '' COMMENT '类型:alipay=支付宝,wechat=微信,bank=银行卡',
  `account` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '' COMMENT '提现账户',
  `memo` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '备注',
  `orderid` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '' COMMENT '订单号',
  `transactionid` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '' COMMENT '流水号',
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT 'created' COMMENT '状态:created=申请中,successed=成功,rejected=已拒绝',
  `transfertime` bigint DEFAULT NULL COMMENT '转账时间',
  `createtime` bigint DEFAULT NULL COMMENT '添加时间',
  `updatetime` bigint DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_user_id` (`user_id`) USING BTREE,
  KEY `idx_shop_id` (`shop_id`) USING BTREE,
  KEY `idx_status` (`status`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC COMMENT='提现表';
