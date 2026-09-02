# q3 probe7: merchant biz handler req structs (ASCII only)
$out = 'D:\go_work\simple-admin\merchant-frontend\sql\dbg_q3probe7.txt'
'' | Out-File $out -Encoding UTF8

$hf = 'D:\go_work\simple-admin\zzhshopR2-api\internal\handler\merchant_biz_handlers.go'
Write-Output '===== handler parse snippets =====' | Out-File $out -Append -Encoding UTF8
$lines = Get-Content $hf -Encoding UTF8
for ($i = 0; $i -lt $lines.Count; $i++) {
    if ($lines[$i] -match 'func Merchant(CouponList|CouponSave|FreightTplList|FreightSave|BillList|WithdrawApply|SettingsSave)Handler') {
        $end = [Math]::Min($i + 22, $lines.Count - 1)
        Write-Output ('-- L' + ($i + 1)) | Out-File $out -Append -Encoding UTF8
        for ($j = $i; $j -le $end; $j++) { Write-Output $lines[$j] | Out-File $out -Append -Encoding UTF8 }
        Write-Output '' | Out-File $out -Append -Encoding UTF8
    }
}

# struct defs referenced: search struct names in same file and types files
Write-Output '===== struct defs in merchant_biz files =====' | Out-File $out -Append -Encoding UTF8
$lf = 'D:\go_work\simple-admin\zzhshopR2-api\internal\logic\merchant\merchant_biz_logic.go'
$srcs = @($hf, $lf)
foreach ($f in $srcs) {
    $ln = Get-Content $f -Encoding UTF8
    for ($i = 0; $i -lt $ln.Count; $i++) {
        if ($ln[$i] -match '^type \w+ struct \{') {
            Write-Output ($f.Substring(55) + ' L' + ($i + 1) + ' ' + $ln[$i]) | Out-File $out -Append -Encoding UTF8
        }
    }
}
Write-Output 'DONE' | Out-File $out -Append -Encoding UTF8
