# q3 probe4: dump coupon/freight related type defs from types.go (ASCII only)
$out = 'D:\go_work\simple-admin\merchant-frontend\sql\dbg_q3probe4.txt'
'' | Out-File $out -Encoding UTF8
$f = 'D:\go_work\simple-admin\zzhshopR2-api\internal\types\types.go'

Write-Output '===== all type names containing Coupon/Freight/Withdraw/Settings/Bill =====' | Out-File $out -Append -Encoding UTF8
$names = Select-String -Path $f -Pattern '^type (\w*(Coupon|Freight|Withdraw|Settings|Bill)\w*)' -Encoding UTF8
foreach ($n in $names) { Write-Output $n.Line | Out-File $out -Append -Encoding UTF8 }

Write-Output '===== full defs =====' | Out-File $out -Append -Encoding UTF8
$lines = Get-Content $f -Encoding UTF8
$grab = $false
$keep = @('CouponListReq','CouponSaveReq','CouponDeleteReq','CouponInfoResp','CouponListResp',
          'FreightTplListReq','FreightTplSaveReq','FreightTplDetailResp','FreightTplDeleteReq',
          'FreightListReq','FreightDataInfo','ShopSettingsInfo','BillListReq','BillListResp','BillSummaryResp',
          'WithdrawApplyReq','WithdrawListReq','WithdrawListResp','WithdrawDeleteReq')
for ($i = 0; $i -lt $lines.Count; $i++) {
    if ($lines[$i] -match '^type (\w+) struct') {
        $tn = $matches[1]
        if ($keep -contains $tn) {
            Write-Output ('-- ' + $tn) | Out-File $out -Append -Encoding UTF8
            $j = $i
            while ($j -lt $lines.Count -and $lines[$j] -notmatch '^\}') {
                Write-Output $lines[$j] | Out-File $out -Append -Encoding UTF8
                $j++
            }
            Write-Output $lines[$j] | Out-File $out -Append -Encoding UTF8
            Write-Output '' | Out-File $out -Append -Encoding UTF8
        }
    }
}
Write-Output 'DONE' | Out-File $out -Append -Encoding UTF8
