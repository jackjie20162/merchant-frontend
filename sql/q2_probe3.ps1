$out = 'D:\go_work\simple-admin\store-console-frontend\sql\dbg_q2tail.txt'
'' | Out-File -Encoding utf8 $out
Add-Content $out '===== delete_withdraw_logic.go ====='
Get-Content D:\go_work\simple-admin\wanshop-rpc\internal\logic\withdraw\delete_withdraw_logic.go -Encoding UTF8 | ForEach-Object { Add-Content $out $_ }
Add-Content $out '===== merchant_biz_handlers.go tail (550-649) ====='
Get-Content D:\go_work\simple-admin\wanshop-api\internal\handler\merchant_biz_handlers.go -Encoding UTF8 | Select-Object -Skip 549 | ForEach-Object { Add-Content $out $_ }
Add-Content $out '===== parseJsonBody definition ====='
Get-ChildItem D:\go_work\simple-admin\wanshop-api\internal\handler -File -Filter *.go | Select-String -Pattern 'func parseJsonBody\(' | ForEach-Object { Add-Content $out ('{0}:{1}: {2}' -f ($_.Path -replace '.*\\',''), $_.LineNumber, $_.Line.Trim()) }
Add-Content $out '===== response funcs ====='
Select-String -Path D:\go_work\simple-admin\wanshop-api\internal\response\response.go -Pattern '^func ' | ForEach-Object { Add-Content $out $_.Line }
