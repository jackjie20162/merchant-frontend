# r5: update simple_admin db rows containing wanshop -> zzhshopR2
$out = 'D:\go_work\simple-admin\merchant-frontend\sql\dbg_r5db.txt'
'' | Out-File -Encoding utf8 $out
function Sql([string]$q) {
    $r = docker exec mysql mysql -uroot -p123456 simple_admin -e $q 2>&1
    foreach ($line in $r) { Add-Content $out ([string]$line) }
}

Add-Content $out '===== BEFORE ====='
Sql "SELECT COUNT(*) AS menu_cnt FROM sys_menus WHERE path LIKE '%wanshop%' OR component LIKE '%wanshop%' OR name LIKE '%wanshop%' OR permission LIKE '%wanshop%';"
Sql "SELECT COUNT(*) AS api_cnt FROM sys_api WHERE path LIKE '%wanshop%';"
Sql "SELECT COUNT(*) AS casbin_cnt FROM casbin_rule WHERE v1 LIKE '%wanshop%';"
Add-Content $out '--- sample menus ---'
Sql "SELECT id, path, component, name FROM sys_menus WHERE path LIKE '%wanshop%' OR name LIKE '%wanshop%' LIMIT 6;"

# update menus: path/component/permission use lowercase form, name uses capitalized form
Sql "UPDATE sys_menus SET path = REPLACE(path, 'wanshop', 'zzhshopR2') WHERE path LIKE '%wanshop%';"
Sql "UPDATE sys_menus SET component = REPLACE(component, 'wanshop', 'zzhshopR2') WHERE component LIKE '%wanshop%';"
Sql "UPDATE sys_menus SET permission = REPLACE(permission, 'wanshop', 'zzhshopR2') WHERE permission LIKE '%wanshop%';"
Sql "UPDATE sys_menus SET name = REPLACE(name, 'Wanshop', 'ZzhshopR2') WHERE name LIKE '%wanshop%';"
# update sys_api + casbin rules
Sql "UPDATE sys_api SET path = REPLACE(path, 'wanshop', 'zzhshopR2') WHERE path LIKE '%wanshop%';"
Sql "UPDATE casbin_rule SET v1 = REPLACE(v1, 'wanshop', 'zzhshopR2') WHERE v1 LIKE '%wanshop%';"

Add-Content $out '===== AFTER ====='
Sql "SELECT COUNT(*) AS menu_left FROM sys_menus WHERE path LIKE '%wanshop%' OR component LIKE '%wanshop%' OR name LIKE '%wanshop%' OR permission LIKE '%wanshop%';"
Sql "SELECT COUNT(*) AS api_left FROM sys_api WHERE path LIKE '%wanshop%';"
Sql "SELECT COUNT(*) AS casbin_left FROM casbin_rule WHERE v1 LIKE '%wanshop%';"
Add-Content $out '--- sample menus after ---'
Sql "SELECT id, path, component, name FROM sys_menus WHERE path LIKE '%zzhshopR2%' OR name LIKE '%zzhshopR2%' LIMIT 6;"
Write-Output 'R5-DB-DONE'
