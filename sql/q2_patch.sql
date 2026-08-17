-- q2 DB patch: fa_wanlshop_coupon 补 status 列（ent schema 定义有该字段，PHP 遗留表缺失）
ALTER TABLE fa_wanlshop_coupon
    ADD COLUMN status enum('normal','hidden') NOT NULL DEFAULT 'normal' COMMENT '状态' AFTER invalid;
