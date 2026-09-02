$out = 'D:\go_work\simple-admin\merchant-frontend\sql\dbg_q2perm2.txt'
'' | Out-File -Encoding utf8 $out
$files = Get-ChildItem D:\go_work\simple-admin\zzhshopR2-rpc\internal -Recurse -File -Filter *.go | Select-String -Pattern 'order:list' -List
foreach ($f in $files) { Add-Content $out ('FILE: ' + $f.Path) }
$target = $files | Select-Object -First 1
if ($target) {
    Add-Content $out '===== content ====='
    Get-Content $target.Path -Encoding UTF8 | ForEach-Object { Add-Content $out $_ }
}
