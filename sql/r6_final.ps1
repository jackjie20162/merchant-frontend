# r6 final: port check + leftover content scan
Start-Sleep -Seconds 8
foreach ($port in @(5173, 9108, 9201)) {
    $c = Get-NetTCPConnection -LocalPort $port -State Listen -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($c) { Write-Output ('LISTEN ' + $port) } else { Write-Output ('DOWN ' + $port) }
}

$root = 'D:\go_work\simple-admin'
$excludeSegs = @('\node_modules\', '\.git\', '\dist\', '\q1_backup\', '\target\', '\.idea\')
$exts = @('.go', '.mod', '.api', '.yaml', '.yml', '.js', '.ts', '.mts', '.vue', '.json', '.sql', '.ps1')
$scanRoots = @(
    (Join-Path $root 'zzhshopR2'),
    (Join-Path $root 'zzhshopR2-api'),
    (Join-Path $root 'zzhshopR2-rpc'),
    (Join-Path $root 'zzhshopR2-app'),
    (Join-Path $root 'merchant-frontend\src'),
    (Join-Path $root 'simple-admin-vben5-ui-main\apps\simple-admin-core\src')
)
$leftover = 0
foreach ($r in $scanRoots) {
    if (-not (Test-Path $r)) { continue }
    $files = Get-ChildItem $r -Recurse -File -ErrorAction SilentlyContinue
    foreach ($f in $files) {
        $p = $f.FullName
        $skip = $false
        foreach ($seg in $excludeSegs) { if ($p.Contains($seg)) { $skip = $true; break } }
        if ($skip) { continue }
        if ($exts -notcontains $f.Extension.ToLower()) { continue }
        if ($f.Length -gt 2MB) { continue }
        $m = Select-String -LiteralPath $p -Pattern 'wanshop', 'Wanshop' -SimpleMatch -List
        if ($m) {
            $leftover++
            if ($leftover -le 20) { Write-Output ('LEFTOVER: ' + $p.Substring($root.Length)) }
        }
    }
}
Write-Output ('LEFTOVER-FILES: ' + $leftover)
Write-Output 'R6-FINAL-DONE'
