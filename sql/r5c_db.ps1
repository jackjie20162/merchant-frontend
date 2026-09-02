# r5c: update sys_apis + casbin_rules/casbin_rules2
$out = 'D:\go_work\simple-admin\merchant-frontend\sql\dbg_r5c.txt'
'' | Out-File -Encoding utf8 $out
function Sql([string]$q) {
    $r = docker exec mysql mysql -uroot -p123456 simple_admin -e $q 2>&1
    foreach ($line in $r) { Add-Content $out ([string]$line) }
}

Add-Content $out '===== BEFORE ====='
Sql "SELECT COUNT(*) AS apis_cnt FROM sys_apis WHERE path LIKE '%wanshop%' OR service_name LIKE '%wanshop%';"
Sql "SELECT COUNT(*) AS cb1_cnt FROM casbin_rules WHERE v1 LIKE '%wanshop%' OR p_type LIKE '%wanshop%';"
Sql "SELECT COUNT(*) AS cb2_cnt FROM casbin_rules2 WHERE v1 LIKE '%wanshop%';"

Sql "UPDATE sys_apis SET path = REPLACE(path, 'wanshop', 'zzhshopR2') WHERE path LIKE '%wanshop%';"
Sql "UPDATE casbin_rules SET v1 = REPLACE(v1, 'wanshop', 'zzhshopR2') WHERE v1 LIKE '%wanshop%';"
Sql "UPDATE casbin_rules2 SET v1 = REPLACE(v1, 'wanshop', 'zzhshopR2') WHERE v1 LIKE '%wanshop%';"

Add-Content $out '===== AFTER ====='
Sql "SELECT COUNT(*) AS apis_left FROM sys_apis WHERE path LIKE '%wanshop%' OR service_name LIKE '%wanshop%';"
Sql "SELECT COUNT(*) AS cb1_left FROM casbin_rules WHERE v1 LIKE '%wanshop%';"
Sql "SELECT COUNT(*) AS cb2_left FROM casbin_rules2 WHERE v1 LIKE '%wanshop%';"
Sql "SELECT path FROM sys_apis WHERE path LIKE '%zzhshopR2%' LIMIT 5;"
Write-Output 'R5C-DONE'
