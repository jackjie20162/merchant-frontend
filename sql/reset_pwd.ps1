function Get-MD5($s) {
    $m = [System.Security.Cryptography.MD5]::Create()
    -join ($m.ComputeHash([Text.Encoding]::UTF8.GetBytes($s)) | ForEach-Object { $_.ToString('x2') })
}
$salt1 = 'a1b2c3'
$salt2 = 'd4e5f6'
$h1 = Get-MD5 ((Get-MD5 '123456') + $salt1)
$h2 = Get-MD5 ((Get-MD5 '123456') + $salt2)

$sqlPath = 'D:\go_work\simple-admin\merchant-frontend\sql\reset_pwd.sql'
@"
USE simple_admin;
UPDATE fa_wanlshop_merchant SET password='$h1', salt='$salt1' WHERE id=1;
UPDATE fa_wanlshop_shop_staff SET password='$h2', salt='$salt2' WHERE id=1;
SELECT id, username, password, salt FROM fa_wanlshop_merchant;
SELECT id, nickname, password, salt FROM fa_wanlshop_shop_staff;
"@ | Set-Content -Encoding ascii -Path $sqlPath

docker cp $sqlPath mysql:/tmp/reset_pwd.sql
docker exec mysql sh -c "mysql -uroot -p123456 --default-character-set=utf8mb4 < /tmp/reset_pwd.sql" 2>$null
Write-Output "DONE merchant=$h1 staff=$h2"
