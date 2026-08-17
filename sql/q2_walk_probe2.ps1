$out = 'D:\go_work\simple-admin\store-console-frontend\sql\dbg_q2walk2.txt'
'' | Out-File -Encoding utf8 $out
$files = @{
    'coupon' = 'D:\go_work\simple-admin\wanshop-rpc\desc\coupon.proto'
    'shop_freight' = 'D:\go_work\simple-admin\wanshop-rpc\desc\shop_freight.proto'
    'shop_freight_data' = 'D:\go_work\simple-admin\wanshop-rpc\desc\shop_freight_data.proto'
    'withdraw' = 'D:\go_work\simple-admin\wanshop-rpc\desc\withdraw.proto'
    'shopsettings' = 'D:\go_work\simple-admin\wanshop-rpc\desc\shopsettings.proto'
    'finance' = 'D:\go_work\simple-admin\wanshop-rpc\desc\finance.proto'
}
foreach ($k in $files.Keys) {
    Add-Content $out ('===== ' + $k + ' =====')
    if (Test-Path $files[$k]) {
        Get-Content $files[$k] -Encoding UTF8 | ForEach-Object { Add-Content $out $_ }
    } else {
        Add-Content $out 'NOT FOUND'
        Get-ChildItem 'D:\go_work\simple-admin\wanshop-rpc\desc' -Name | ForEach-Object { Add-Content $out $_ }
        break
    }
}
