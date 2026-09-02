# q1 DB：建 fa_withdraw 表并验证
$ErrorActionPreference = 'Continue'
Get-Content 'D:\go_work\simple-admin\merchant-frontend\sql\merchant_finance.sql' -Raw -Encoding UTF8 |
  docker exec -i mysql mysql -uroot -p123456 --default-character-set=utf8mb4 simple_admin
docker exec mysql mysql -uroot -p123456 simple_admin -e "DESCRIBE fa_withdraw;" |
  Out-File 'D:\go_work\simple-admin\merchant-frontend\sql\dbg_withdraw.txt' -Encoding utf8
Write-Output "db done"
