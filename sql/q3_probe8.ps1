# q3 enum probe: delivery field comment in ent schema (ASCII only)
$out = 'D:\go_work\simple-admin\merchant-frontend\sql\dbg_q3enum.txt'
'' | Out-File $out -Encoding UTF8
$dir = 'D:\go_work\simple-admin\zzhshopR2-rpc\ent\schema'
Get-ChildItem $dir -Filter '*.go' | ForEach-Object { Write-Output $_.Name } | Out-File $out -Append -Encoding UTF8
Write-Output '-----' | Out-File $out -Append -Encoding UTF8
$hits = Select-String -Path "$dir\*.go" -Pattern 'delivery|Delivery|isdelivery|valuation' -Context 3,1 -Encoding UTF8
foreach ($h in $hits) {
    Write-Output ($h.Filename + ' L' + $h.LineNumber) | Out-File $out -Append -Encoding UTF8
    ($h.Context.PreContext -join "`n") | Out-File $out -Append -Encoding UTF8
    Write-Output $h.Line | Out-File $out -Append -Encoding UTF8
    Write-Output '' | Out-File $out -Append -Encoding UTF8
}
Write-Output 'DONE' | Out-File $out -Append -Encoding UTF8
