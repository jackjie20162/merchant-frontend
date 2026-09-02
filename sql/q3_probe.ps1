$out = 'D:\go_work\simple-admin\merchant-frontend\sql\dbg_q3files.txt'
'' | Out-File -Encoding utf8 $out
Get-ChildItem D:\go_work\simple-admin\merchant-frontend\src -Recurse -File | Where-Object { $_.FullName -notmatch 'node_modules' } | ForEach-Object {
    Add-Content $out ($_.FullName.Replace('D:\go_work\simple-admin\merchant-frontend\src\', ''))
}
