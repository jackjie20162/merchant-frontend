# q3 probe9: FreightDetail/FreightSave logic impl (ASCII only)
$out = 'D:\go_work\simple-admin\merchant-frontend\sql\dbg_q3probe9.txt'
'' | Out-File $out -Encoding UTF8
$f = 'D:\go_work\simple-admin\zzhshopR2-api\internal\logic\merchant\merchant_biz_logic.go'
$lines = Get-Content $f -Encoding UTF8
for ($i = 0; $i -lt $lines.Count; $i++) {
    if ($lines[$i] -match 'func \(l \*MerchantLogic\) (FreightDetail|FreightSave|FreightTplList|CouponList|SettingsGet)|type FreightSaveReq|type FreightDetailResp|type freightDetailResp') {
        $j = $i
        $depth = 0
        $started = $false
        Write-Output ('===== L' + ($i + 1) + ' ' + $lines[$i]) | Out-File $out -Append -Encoding UTF8
        while ($j -lt $lines.Count -and $j -lt $i + 60) {
            Write-Output $lines[$j] | Out-File $out -Append -Encoding UTF8
            if ($lines[$j] -match '\{') { $depth++; $started = $true }
            if ($lines[$j] -match '\}') { $depth-- }
            $j++
            if ($started -and $depth -le 0) { break }
        }
        Write-Output '' | Out-File $out -Append -Encoding UTF8
    }
}
Write-Output 'DONE' | Out-File $out -Append -Encoding UTF8
