$out = 'D:\go_work\simple-admin\store-console-frontend\sql\dbg_q2rpc.txt'
'' | Out-File -Encoding utf8 $out
$cli = Get-Content D:\go_work\simple-admin\wanshop-rpc\wssclient\wss.go
Add-Content $out '===== wssclient methods ====='
$cli | Select-String -Pattern 'func \(m \*defaultWss\)' | ForEach-Object { Add-Content $out $_.Line }
Add-Content $out '===== merchant_biz_handlers head 120 ====='
Get-Content D:\go_work\simple-admin\wanshop-api\internal\handler\merchant_biz_handlers.go -TotalCount 120 | ForEach-Object { Add-Content $out $_ }
