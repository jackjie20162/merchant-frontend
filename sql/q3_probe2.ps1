# q3 probe: locate zzhshopR2-api and inspect coupon/freight list filters (ASCII only)
$out = 'D:\go_work\simple-admin\merchant-frontend\sql\dbg_q3probe.txt'
'' | Out-File $out -Encoding UTF8

$root = 'D:\go_work\simple-admin'
$dirs = Get-ChildItem $root -Directory | Where-Object { $_.Name -like 'zzhshopR2*' }
foreach ($d in $dirs) { Write-Output ("DIR " + $d.FullName) | Out-File $out -Append -Encoding UTF8 }

$apiRoot = $null
foreach ($d in $dirs) { if ($d.Name -eq 'zzhshopR2-api') { $apiRoot = $d.FullName } }
if (-not $apiRoot) { Write-Output 'zzhshopR2-api NOT FOUND' | Out-File $out -Append -Encoding UTF8; exit }

# coupon list logic
Write-Output '===== coupon list logic =====' | Out-File $out -Append -Encoding UTF8
$f = Get-ChildItem -Recurse $apiRoot -Filter 'get_coupon_list_logic.go' -ErrorAction SilentlyContinue | Select-Object -First 1
if ($f) { Get-Content $f.FullName -Encoding UTF8 | Out-File $out -Append -Encoding UTF8 } else { Write-Output 'coupon list logic not found' | Out-File $out -Append -Encoding UTF8 }

# freight tpl list logic
Write-Output '===== freight tpl list logic =====' | Out-File $out -Append -Encoding UTF8
$fs = Get-ChildItem -Recurse $apiRoot -Filter '*freight*list*logic.go' -ErrorAction SilentlyContinue
foreach ($x in $fs) { Write-Output ('FILE ' + $x.FullName) | Out-File $out -Append -Encoding UTF8; Get-Content $x.FullName -Encoding UTF8 | Out-File $out -Append -Encoding UTF8 }

# proto req fields for coupon list / freight tpl list
Write-Output '===== proto list reqs =====' | Out-File $out -Append -Encoding UTF8
$proto = Get-ChildItem -Recurse 'D:\go_work\simple-admin\zzhshopR2-rpc' -Filter '*.proto' -ErrorAction SilentlyContinue
foreach ($p in $proto) {
    $hits = Select-String -Path $p.FullName -Pattern 'CouponListReq|ShopFreightListReq|ShopFreightTplListReq' -Context 0,12 -Encoding UTF8
    foreach ($h in $hits) { Write-Output ($p.Name + ':' + $h.LineNumber) | Out-File $out -Append -Encoding UTF8; ($h.Context.PostContext -join "`n") | Out-File $out -Append -Encoding UTF8 }
}
Write-Output 'DONE' | Out-File $out -Append -Encoding UTF8
