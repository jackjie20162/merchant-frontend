# r5 fix: correct name column update + find real api/casbin table names
$out = 'D:\go_work\simple-admin\merchant-frontend\sql\dbg_r5b.txt'
'' | Out-File -Encoding utf8 $out
function Sql([string]$q) {
    $r = docker exec mysql mysql -uroot -p123456 simple_admin -e $q 2>&1
    foreach ($line in $r) { Add-Content $out ([string]$line) }
}

Add-Content $out '===== candidate tables ====='
Sql "SHOW TABLES LIKE '%api%';"
Sql "SHOW TABLES LIKE '%casbin%';"

Add-Content $out '===== fix name column (cs: match lowercase) ====='
Sql "UPDATE sys_menus SET name = REPLACE(name, 'Wanshop', 'ZzhshopR2') WHERE name LIKE '%anshop%';"
Sql "SELECT COUNT(*) AS name_left FROM sys_menus WHERE name LIKE '%anshop%' AND name LIKE '%W%';"

Add-Content $out '===== menus after ====='
Sql "SELECT COUNT(*) AS menu_left FROM sys_menus WHERE path LIKE '%wanshop%' OR component LIKE '%wanshop%' OR name LIKE '%wanshop%' OR permission LIKE '%wanshop%';"
Sql "SELECT id, path, component, name FROM sys_menus WHERE path LIKE '%zzhshopR2%' LIMIT 6;"
Write-Output 'R5B-DONE'
