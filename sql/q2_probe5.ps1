$out = 'D:\go_work\simple-admin\store-console-frontend\sql\dbg_q2dirs.txt'
'' | Out-File -Encoding utf8 $out
Get-ChildItem D:\go_work\simple-admin\wanshop-rpc\internal\logic -Directory | ForEach-Object {
    $todo = 0
    Get-ChildItem $_.FullName -File | ForEach-Object { $todo += (Select-String -Path $_.FullName -Pattern 'TODO: add your logic' -SimpleMatch).Count }
    Add-Content $out ($_.Name + ' todo=' + $todo)
}
