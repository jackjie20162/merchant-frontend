# add status column without comment (avoid encoding issue)
docker exec mysql mysql -uroot -p123456 simple_admin -e "ALTER TABLE fa_wanlshop_coupon ADD COLUMN status enum('normal','hidden') NOT NULL DEFAULT 'normal' AFTER invalid;" 2>$null
$out = 'D:\go_work\simple-admin\merchant-frontend\sql\dbg_q2fix2.txt'
docker exec mysql mysql -uroot -p123456 simple_admin -e "SHOW COLUMNS FROM fa_wanlshop_coupon LIKE 'status';" 2>$null | Out-File -Encoding utf8 $out
