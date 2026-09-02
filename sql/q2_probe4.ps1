$out = 'D:\go_work\simple-admin\merchant-frontend\sql\dbg_q2stub.txt'
'' | Out-File -Encoding utf8 $out
$dirs = @('D:\go_work\simple-admin\zzhshopR2-rpc\internal\logic\shopfreightdata', 'D:\go_work\simple-admin\zzhshopR2-rpc\internal\logic\shopfreight', 'D:\go_work\simple-admin\zzhshopR2-rpc\internal\logic\coupon')
foreach ($d in $dirs) {
    Add-Content $out ('===== ' + $d + ' =====')
    Get-ChildItem $d -File -ErrorAction SilentlyContinue | ForEach-Object {
        $todo = (Select-String -Path $_.FullName -Pattern 'TODO: add your logic' -SimpleMatch).Count
        Add-Content $out ($_.Name + ' lines=' + (Get-Content $_.FullName).Count + ' todo=' + $todo)
    }
}
