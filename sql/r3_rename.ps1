# rename dirs/files: wanshop -> zzhshopR2 (deepest first)
$root = 'D:\go_work\simple-admin'
$excludeSegs = @('\node_modules\', '\.git\', '\dist\', '\q1_backup\', '\target\', '\.idea\')

# 0. ensure services stopped (file locks would break rename)
foreach ($port in @(9108, 9201)) {
    $c = Get-NetTCPConnection -LocalPort $port -State Listen -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($c) {
        Stop-Process -Id $c.OwningProcess -Force -ErrorAction SilentlyContinue
        Write-Output ('killed port=' + $port + ' pid=' + $c.OwningProcess)
    }
}
Start-Sleep -Seconds 1

# 1. list top-level dirs containing wanshop (sanity check)
$top = Get-ChildItem $root -Directory | Where-Object { $_.Name -like '*wanshop*' }
foreach ($d in $top) { Write-Output ('TOPDIR: ' + $d.Name) }

# 2. rename top-level project dirs
$topRenames = @(
    @('wanshop', 'zzhshopR2'),
    @('wanshop-api', 'zzhshopR2-api'),
    @('wanshop-rpc', 'zzhshopR2-rpc'),
    @('wanshop-app', 'zzhshopR2-app')
)
foreach ($t in $topRenames) {
    $src = Join-Path $root $t[0]
    if (Test-Path $src) {
        Rename-Item -Path $src -NewName $t[1]
        Write-Output ('DIR: ' + $t[0] + ' -> ' + $t[1])
    } else {
        Write-Output ('SKIP-MISSING: ' + $t[0])
    }
}

# vben5 plugin dir
$plg = Join-Path $root 'simple-admin-vben5-ui-main\apps\simple-admin-core\src\plugin\wanshop'
if (Test-Path $plg) {
    Rename-Item -Path $plg -NewName 'zzhshopR2'
    Write-Output 'DIR: plugin\wanshop -> plugin\zzhshopR2'
} else {
    Write-Output 'SKIP-MISSING: plugin\wanshop'
}

# 3. scan remaining files/dirs with wanshop in name, rename deepest first
$scanRoots = @(
    (Join-Path $root 'zzhshopR2'),
    (Join-Path $root 'zzhshopR2-api'),
    (Join-Path $root 'zzhshopR2-rpc'),
    (Join-Path $root 'zzhshopR2-app'),
    (Join-Path $root 'merchant-frontend'),
    (Join-Path $root 'simple-admin-vben5-ui-main\apps\simple-admin-core')
)
$renamed = 0
foreach ($r in $scanRoots) {
    if (-not (Test-Path $r)) { Write-Output ('SCAN-MISSING: ' + $r); continue }
    $items = Get-ChildItem $r -Recurse -Force -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -like '*wanshop*' } |
        Sort-Object { $_.FullName.Length } -Descending
    foreach ($it in $items) {
        $p = $it.FullName
        $skip = $false
        foreach ($seg in $excludeSegs) { if ($p.Contains($seg)) { $skip = $true; break } }
        if ($skip) { continue }
        $newName = $it.Name -creplace 'wanshop', 'zzhshopR2' -creplace 'Wanshop', 'ZzhshopR2'
        Rename-Item -LiteralPath $p -NewName $newName
        $renamed++
        Write-Output ('RENAMED: ' + $p.Substring($root.Length) + ' -> ' + $newName)
    }
}
Write-Output ('TOTAL RENAMED: ' + $renamed)

# 4. final verify: any filesystem entry still containing wanshop
$left = @()
foreach ($r in $scanRoots) {
    if (Test-Path $r) {
        $left += Get-ChildItem $r -Recurse -Force -ErrorAction SilentlyContinue | Where-Object { $_.Name -like '*wanshop*' }
    }
}
foreach ($l in $left) { Write-Output ('LEFT: ' + $l.FullName) }
Write-Output 'RENAME-DONE'
