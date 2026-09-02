# q3 probe3: api types req defs + delivery enum values (ASCII only)
$out = 'D:\go_work\simple-admin\merchant-frontend\sql\dbg_q3probe3.txt'
'' | Out-File $out -Encoding UTF8
$api = 'D:\go_work\simple-admin\zzhshopR2-api'

Write-Output '===== coupon/freight req types in internal/types =====' | Out-File $out -Append -Encoding UTF8
$typesFile = Get-ChildItem -Recurse $api -Filter 'types.go' -ErrorAction SilentlyContinue | Select-Object -First 3
foreach ($t in $typesFile) {
    Write-Output ('FILE ' + $t.FullName) | Out-File $out -Append -Encoding UTF8
    $hits = Select-String -Path $t.FullName -Pattern 'CouponListReq|CouponSaveReq|FreightTplListReq|FreightTplSaveReq|FreightSaveReq' -Context 0,18 -Encoding UTF8
    foreach ($h in $hits) {
        Write-Output ('-- line ' + $h.LineNumber + ' ' + $h.Line) | Out-File $out -Append -Encoding UTF8
        ($h.Context.PostContext -join "`n") | Out-File $out -Append -Encoding UTF8
    }
}

Write-Output '===== delivery enum candidates (PHP source) =====' | Out-File $out -Append -Encoding UTF8
$php = Get-ChildItem -Recurse 'D:\go_work\simple-admin\php源码' -Filter '*.php' -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -match 'freight' } | Select-Object -First 10
foreach ($p in $php) { Write-Output ('PHPFILE ' + $p.FullName) | Out-File $out -Append -Encoding UTF8 }

Write-Output '===== freight controller/logic in PHP =====' | Out-File $out -Append -Encoding UTF8
$hits2 = Select-String -Path 'D:\go_work\simple-admin\php源码\wanlshop-1.2.2-extended-php\application\admin\controller\shop\*.php' -Pattern 'delivery' -Context 2,2 -Encoding UTF8 -ErrorAction SilentlyContinue
foreach ($h in $hits2) {
    Write-Output ($h.Path + ':' + $h.LineNumber + ' ' + $h.Line.Trim()) | Out-File $out -Append -Encoding UTF8
}
Write-Output 'DONE' | Out-File $out -Append -Encoding UTF8
