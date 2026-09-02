$out = 'D:\go_work\simple-admin\merchant-frontend\sql\dbg_q2db.txt'
'' | Out-File -Encoding utf8 $out

Add-Content $out '===== DESCRIBE fa_wanlshop_coupon ====='
docker exec mysql mysql -uroot -p123456 simple_admin -e "DESCRIBE fa_wanlshop_coupon;" 2>$null | ForEach-Object { Add-Content $out $_ }

Add-Content $out '===== DESCRIBE fa_wanlshop_shop_freight_data ====='
docker exec mysql mysql -uroot -p123456 simple_admin -e "DESCRIBE fa_wanlshop_shop_freight_data;" 2>$null | ForEach-Object { Add-Content $out $_ }

Add-Content $out '===== DESCRIBE fa_wanlshop_shop_freight ====='
docker exec mysql mysql -uroot -p123456 simple_admin -e "DESCRIBE fa_wanlshop_shop_freight;" 2>$null | ForEach-Object { Add-Content $out $_ }

Add-Content $out '===== freight rows ====='
docker exec mysql mysql -uroot -p123456 simple_admin -e "SELECT id,shop_id,name,deletetime FROM fa_wanlshop_shop_freight;" 2>$null | ForEach-Object { Add-Content $out $_ }
docker exec mysql mysql -uroot -p123456 simple_admin -e "SELECT id,shop_id,freight_id,province FROM fa_wanlshop_shop_freight_data;" 2>$null | ForEach-Object { Add-Content $out $_ }

Add-Content $out '===== ent coupon schema fields ====='
Select-String -Path 'D:\go_work\simple-admin\zzhshopR2-rpc\ent\schema\coupon.go' -Pattern 'field\.' | ForEach-Object { Add-Content $out $_.Line.Trim() }

Add-Content $out '===== ent shopfreightdata schema fields ====='
Select-String -Path 'D:\go_work\simple-admin\zzhshopR2-rpc\ent\schema\shopfreightdata.go' -Pattern 'field\.' | ForEach-Object { Add-Content $out $_.Line.Trim() }
