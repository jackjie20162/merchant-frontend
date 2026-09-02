$out = 'D:\go_work\simple-admin\merchant-frontend\sql\dbg_q2walk3.txt'
'' | Out-File -Encoding utf8 $out
foreach ($f in @('coupon.proto', 'shop_freight_data.proto', 'shop_settings.proto', 'finance.proto')) {
    Add-Content $out ('===== ' + $f + ' =====')
    Get-Content ('D:\go_work\simple-admin\zzhshopR2-rpc\desc\' + $f) -Encoding UTF8 | ForEach-Object { Add-Content $out $_ }
}
