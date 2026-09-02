-- =====================================================================
-- 图片空间目录结构（阶段2）数据库变更脚本
-- 说明：
--   1. 新建 fa_wanlshop_attachment_group 图片分组（目录）表
--   2. fa_wanlshop_attachment 增加 group_id：0=未分组
-- 导入方式（避免 PowerShell 管道按 GBK 转码损坏中文）：
--        docker cp sql/image_space_group.sql mysql:/tmp/image_space_group.sql
--        docker exec mysql sh -c "mysql -uroot -p123456 --default-character-set=utf8mb4 < /tmp/image_space_group.sql"
-- =====================================================================

USE simple_admin;

-- ----------------------------
-- 图片空间分组（目录）表
-- ----------------------------
CREATE TABLE IF NOT EXISTS `fa_wanlshop_attachment_group` (
  `id` int unsigned NOT NULL AUTO_INCREMENT COMMENT '分组ID',
  `shop_id` int unsigned NOT NULL DEFAULT '0' COMMENT '店铺ID',
  `name` varchar(255) NOT NULL DEFAULT '' COMMENT '分组名称',
  `weigh` int NOT NULL DEFAULT '0' COMMENT '权重',
  `createtime` bigint DEFAULT NULL COMMENT '创建时间',
  `updatetime` bigint DEFAULT NULL COMMENT '更新时间',
  `deletetime` bigint DEFAULT NULL COMMENT '删除时间',
  `status` varchar(32) NOT NULL DEFAULT 'normal' COMMENT '状态',
  PRIMARY KEY (`id`),
  KEY `idx_shop_id` (`shop_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='店铺图片空间分组表';

-- ----------------------------
-- 附件表增加分组列
-- ----------------------------
ALTER TABLE `fa_wanlshop_attachment`
  ADD COLUMN `group_id` int unsigned NOT NULL DEFAULT '0' COMMENT '分组ID:0=未分组' AFTER `shop_id`,
  ADD KEY `idx_group_id` (`group_id`);
