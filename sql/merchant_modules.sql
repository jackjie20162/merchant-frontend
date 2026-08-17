-- =====================================================================
-- 商家端业务模块扩展（阶段1）数据库变更脚本
-- 说明：
--   1. fa_wanlshop_category 增加 shop_id：0=平台类目，>0=商户自定义类目
--   2. 新建 fa_wanlshop_attachment 图片空间表（按店铺隔离）
-- 导入方式（避免 PowerShell 管道按 GBK 转码损坏中文）：
--        docker cp sql/merchant_modules.sql mysql:/tmp/merchant_modules.sql
--        docker exec mysql sh -c "mysql -uroot -p123456 --default-character-set=utf8mb4 < /tmp/merchant_modules.sql"
-- =====================================================================

USE simple_admin;

-- ----------------------------
-- 类目表增加店铺归属列
-- ----------------------------
ALTER TABLE `fa_wanlshop_category`
  ADD COLUMN `shop_id` int unsigned NOT NULL DEFAULT '0' COMMENT '店铺ID:0=平台类目' AFTER `id`,
  ADD KEY `idx_shop_id` (`shop_id`);

-- ----------------------------
-- 图片空间（附件）表
-- ----------------------------
CREATE TABLE IF NOT EXISTS `fa_wanlshop_attachment` (
  `id` int unsigned NOT NULL AUTO_INCREMENT COMMENT '附件ID',
  `shop_id` int unsigned NOT NULL DEFAULT '0' COMMENT '店铺ID',
  `name` varchar(255) NOT NULL DEFAULT '' COMMENT '原始文件名',
  `url` varchar(500) NOT NULL DEFAULT '' COMMENT '访问路径',
  `mime` varchar(100) NOT NULL DEFAULT '' COMMENT 'MIME类型',
  `size` int unsigned NOT NULL DEFAULT '0' COMMENT '字节数',
  `createtime` int unsigned DEFAULT NULL COMMENT '创建时间',
  `updatetime` int unsigned DEFAULT NULL COMMENT '更新时间',
  `deletetime` int unsigned DEFAULT NULL COMMENT '删除时间',
  `status` enum('normal','hidden') NOT NULL DEFAULT 'normal' COMMENT '状态',
  PRIMARY KEY (`id`),
  KEY `idx_shop_id` (`shop_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='店铺图片空间表';
