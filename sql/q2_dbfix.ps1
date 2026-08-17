# q2 db fix + cleanup leftover test rows
docker exec mysql mysql -uroot -p123456 simple_admin -e "ALTER TABLE fa_wanlshop_coupon ADD COLUMN status enum('normal','hidden') NOT NULL DEFAULT 'normal' COMMENT '状态' AFTER invalid;" 2>$null
docker exec mysql mysql -uroot -p123456 simple_admin -e "DELETE FROM fa_wanlshop_shop_freight_data WHERE freight_id IN (SELECT id FROM fa_wanlshop_shop_freight WHERE name LIKE 'q2%'); DELETE FROM fa_wanlshop_shop_freight WHERE name LIKE 'q2%'; DELETE FROM fa_wanlshop_coupon WHERE name LIKE 'q2%';" 2>$null
$out = 'D:\go_work\simple-admin\store-console-frontend\sql\dbg_q2fix.txt'
'' | Out-File -Encoding utf8 $out
docker exec mysql mysql -uroot -p123456 simple_admin -e "DESCRIBE fa_wanlshop_coupon;" 2>$null | ForEach-Object { Add-Content $out $_ }
Add-Content $out '===== freight rows after cleanup ====='
docker exec mysql mysql -uroot -p123456 simple_admin -e "SELECT COUNT(*) c FROM fa_wanlshop_shop_freight; SELECT COUNT(*) c FROM fa_wanlshop_shop_freight_data;" 2>$null | ForEach-Object { Add-Content $out $_ }
