$out = 'D:\go_work\simple-admin\merchant-frontend\sql\dbg_q2walk1.txt'
'' | Out-File -Encoding utf8 $out
Add-Content $out '===== logic methods ====='
Select-String -Path 'D:\go_work\simple-admin\zzhshopR2-api\internal\logic\merchant\merchant_biz_logic.go' -Pattern 'func \(l \*MerchantLogic\)' | ForEach-Object {
    Add-Content $out ($_.LineNumber.ToString() + ': ' + $_.Line.Trim())
}
Add-Content $out '===== handlers ====='
Select-String -Path 'D:\go_work\simple-admin\zzhshopR2-api\internal\handler\merchant_biz_handlers.go' -Pattern 'func Merchant|type merchant' | ForEach-Object {
    Add-Content $out ($_.LineNumber.ToString() + ': ' + $_.Line.Trim())
}
Add-Content $out '===== routes tail ====='
$lines = Get-Content 'D:\go_work\simple-admin\zzhshopR2-api\internal\handler\routes.go' -Encoding UTF8
$lines[440..($lines.Count - 1)] | ForEach-Object { Add-Content $out $_ }
