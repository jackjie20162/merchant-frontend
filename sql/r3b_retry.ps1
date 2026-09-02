# retry failed renames: wanshop-api, plugin\wanshop; then rescan remaining entries
$root = 'D:\go_work\simple-admin'

# 1. find processes referencing our dirs
$procs = Get-CimInstance Win32_Process | Where-Object { $_.CommandLine -and ($_.CommandLine -match 'wanshop|zzhshopR2|vben5') }
foreach ($p in $procs) {
    $cl = $p.CommandLine
    if ($cl.Length -gt 200) { $cl = $cl.Substring(0, 200) }
    Write-Output ('PROC pid=' + $p.ProcessId + ' name=' + $p.Name + ' cmd=' + $cl)
}
# kill node dev servers that may watch the dirs
foreach ($p in $procs) {
    if ($p.Name -eq 'node.exe') {
        Stop-Process -Id $p.ProcessId -Force -ErrorAction SilentlyContinue
        Write-Output ('killed node pid=' + $p.ProcessId)
    }
}
Start-Sleep -Seconds 2

function MoveDir([string]$src, [string]$dstName) {
    if (-not (Test-Path $src)) { Write-Output ('GONE: ' + $src); return }
    $parent = Split-Path $src
    $dst = Join-Path $parent $dstName
    for ($i = 1; $i -le 6; $i++) {
        try {
            [System.IO.Directory]::Move($src, $dst)
            Write-Output ('MOVED: ' + $src + ' -> ' + $dstName)
            return
        } catch {
            Write-Output ('RETRY' + $i + ' FAIL: ' + $_.Exception.Message)
            Start-Sleep -Seconds 2
        }
    }
    Write-Output ('FAILED: ' + $src)
}

MoveDir (Join-Path $root 'wanshop-api') 'zzhshopR2-api'
MoveDir (Join-Path $root 'simple-admin-vben5-ui-main\apps\simple-admin-core\src\plugin\wanshop') 'zzhshopR2'

# rescan rename remaining files/dirs (deepest first)
$excludeSegs = @('\node_modules\', '\.git\', '\dist\', '\q1_backup\', '\target\', '\.idea\')
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
        try {
            Rename-Item -LiteralPath $p -NewName $newName
            $renamed++
            Write-Output ('RENAMED: ' + $p.Substring($root.Length) + ' -> ' + $newName)
        } catch {
            Write-Output ('RENAME-FAIL: ' + $p + ' :: ' + $_.Exception.Message)
        }
    }
}
Write-Output ('TOTAL RENAMED: ' + $renamed)

# verify leftovers
$left = @()
foreach ($r in $scanRoots) {
    if (Test-Path $r) {
        $left += Get-ChildItem $r -Recurse -Force -ErrorAction SilentlyContinue | Where-Object { $_.Name -like '*wanshop*' }
    }
}
$leftTop = Get-ChildItem $root | Where-Object { $_.Name -like '*wanshop*' }
foreach ($l in $leftTop) { Write-Output ('LEFT-TOP: ' + $l.FullName) }
foreach ($l in $left) { Write-Output ('LEFT: ' + $l.FullName) }
Write-Output 'R3B-DONE'
