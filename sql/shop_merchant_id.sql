-- =====================================================================
-- 店铺归属改造：fa_wanlshop_shop.user_id(会员ID) -> merchant_id(商家主账号ID)
-- 背景：一个商家主账号可拥有多个店铺，店铺不再绑定 fa_user
-- 导入方式（避免 PowerShell 管道按 GBK 转码损坏中文）：
--   docker cp sql/shop_merchant_id.sql mysql:/tmp/shop_merchant_id.sql
--   docker exec mysql sh -c "mysql -uroot -p123456 --default-character-set=utf8mb4 < /tmp/shop_merchant_id.sql"
-- =====================================================================
USE simple_admin;

ALTER TABLE `fa_wanlshop_shop`
  CHANGE `user_id` `merchant_id` int unsigned NOT NULL DEFAULT '0' COMMENT '商家主账号ID';

-- 数据回填：现有店铺统一归属到商家主账号 admin(id=1)
UPDATE `fa_wanlshop_shop` SET `merchant_id` = 1;
