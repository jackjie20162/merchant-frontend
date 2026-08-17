# q3 probe5: wanshop-api structure (ASCII only)
$out = 'D:\go_work\simple-admin\store-console-frontend\sql\dbg_q3probe5.txt'
'' | Out-File $out -Encoding UTF8
$api = 'D:\go_work\simple-admin\wanshop-api'
Get-ChildItem -Recurse $api -Filter '*.go' | Where-Object { $_.FullName -notmatch '\\(vendor|\.git)\\' } |
    ForEach-Object { $_.FullName.Substring($api.Length) } | Out-File $out -Append -Encoding UTF8
Write-Output 'DONE' | Out-File $out -Append -Encoding UTF8
