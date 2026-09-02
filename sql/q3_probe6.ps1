# q3 probe6: request struct defs for q2 endpoints (ASCII only)
$out = 'D:\go_work\simple-admin\merchant-frontend\sql\dbg_q3probe6.txt'
'' | Out-File $out -Encoding UTF8

$files = @(
  'D:\go_work\simple-admin\zzhshopR2-api\internal\types\types.go',
  'D:\go_work\simple-admin\zzhshopR2-api\internal\types\zzhshopR2_types.go',
  'D:\go_work\simple-admin\zzhshopR2-api\internal\types\trade_types.go'
)
foreach ($f in $files) {
    $hits = Select-String -Path $f -Pattern 'type \w*(Coupon|Freight|Withdraw|Settings|Bill)\w* struct' -Encoding UTF8
    foreach ($h in $hits) { Write-Output ($f.Substring(55) + ' L' + $h.LineNumber + ' ' + $h.Line.Trim()) | Out-File $out -Append -Encoding UTF8 }
}

# dump full struct bodies found above
Write-Output '===== struct bodies =====' | Out-File $out -Append -Encoding UTF8
foreach ($f in $files) {
    $lines = Get-Content $f -Encoding UTF8
    for ($i = 0; $i -lt $lines.Count; $i++) {
        if ($lines[$i] -match 'type \w*(Coupon|Freight|Withdraw|Settings|Bill)\w* struct') {
            $j = $i
            while ($j -lt $lines.Count -and $lines[$j] -notmatch '^\}\s*$') {
                Write-Output $lines[$j] | Out-File $out -Append -Encoding UTF8
                $j++
            }
            if ($j -lt $lines.Count) { Write-Output $lines[$j] | Out-File $out -Append -Encoding UTF8 }
            Write-Output '' | Out-File $out -Append -Encoding UTF8
        }
    }
}

# handler routes for these endpoints (confirm paths/methods)
Write-Output '===== routes for coupon/freight/bill/withdraw/settings =====' | Out-File $out -Append -Encoding UTF8
$r = Select-String -Path 'D:\go_work\simple-admin\zzhshopR2-api\internal\handler\routes.go' -Pattern 'coupon|freight|bill|withdraw|settings' -Encoding UTF8
foreach ($h in $r) { Write-Output ('L' + $h.LineNumber + ' ' + $h.Line.Trim()) | Out-File $out -Append -Encoding UTF8 }
Write-Output 'DONE' | Out-File $out -Append -Encoding UTF8
