# q4 probe2: withdraw schema type values + WithdrawApply logic (ASCII only)
$out = 'D:\go_work\simple-admin\merchant-frontend\sql\dbg_q4b.txt'
'' | Out-File $out -Encoding UTF8

Write-Output '===== withdraw schema' | Out-File $out -Append -Encoding UTF8
Get-Content 'D:\go_work\simple-admin\zzhshopR2-rpc\ent\schema\withdraw.go' -Encoding UTF8 | Out-File $out -Append -Encoding UTF8

Write-Output '===== WithdrawApply logic' | Out-File $out -Append -Encoding UTF8
$lines = Get-Content 'D:\go_work\simple-admin\zzhshopR2-api\internal\logic\merchant\merchant_biz_logic.go' -Encoding UTF8
for ($i = 0; $i -lt $lines.Count; $i++) {
    if ($lines[$i] -match 'func \(l \*MerchantLogic\) (WithdrawApply|BillSummary|SettingsSave)') {
        $j = $i; $depth = 0; $started = $false
        Write-Output ('===== L' + ($i + 1)) | Out-File $out -Append -Encoding UTF8
        while ($j -lt $lines.Count -and $j -lt $i + 50) {
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
