# q4 probe: bill/withdraw handlers + PayInfo/WithdrawInfo proto fields (ASCII only)
$out = 'D:\go_work\simple-admin\merchant-frontend\sql\dbg_q4.txt'
'' | Out-File $out -Encoding UTF8

Write-Output '===== handlers bill/withdraw' | Out-File $out -Append -Encoding UTF8
$hits = Select-String -Path 'D:\go_work\simple-admin\zzhshopR2-api\internal\handler\merchant_biz_handlers.go' -Pattern 'Bill|Withdraw'
foreach ($h in $hits) {
    Write-Output ($h.LineNumber.ToString() + ': ' + $h.Line.Trim()) | Out-File $out -Append -Encoding UTF8
}

Write-Output '===== logic bill/withdraw' | Out-File $out -Append -Encoding UTF8
$hits2 = Select-String -Path 'D:\go_work\simple-admin\zzhshopR2-api\internal\logic\merchant\merchant_biz_logic.go' -Pattern 'Bill|Withdraw'
foreach ($h in $hits2) {
    Write-Output ($h.LineNumber.ToString() + ': ' + $h.Line.Trim()) | Out-File $out -Append -Encoding UTF8
}

Write-Output '===== proto files' | Out-File $out -Append -Encoding UTF8
Get-ChildItem 'D:\go_work\simple-admin\zzhshopR2-rpc\desc' -Filter *.proto | ForEach-Object { Write-Output $_.FullName } | Out-File $out -Append -Encoding UTF8

Write-Output '===== Pay message fields' | Out-File $out -Append -Encoding UTF8
$pay = Select-String -Path 'D:\go_work\simple-admin\zzhshopR2-rpc\desc\*.proto' -Pattern 'message PayInfo|message ShopFinanceSummaryResp|message WithdrawInfo|message PayListReq|message BillListReq|message WithdrawApplyReq|message WithdrawListReq'
foreach ($h in $pay) {
    Write-Output ('--- ' + $h.Filename + ':' + $h.LineNumber) | Out-File $out -Append -Encoding UTF8
    $lines = Get-Content $h.Path -Encoding UTF8
    $j = $h.LineNumber - 1
    while ($j -lt $lines.Count -and $lines[$j] -notmatch '^\}') {
        Write-Output $lines[$j] | Out-File $out -Append -Encoding UTF8
        $j++
    }
    Write-Output $lines[$j] | Out-File $out -Append -Encoding UTF8
}
Write-Output 'DONE' | Out-File $out -Append -Encoding UTF8
