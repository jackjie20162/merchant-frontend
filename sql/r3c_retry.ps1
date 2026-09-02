# final retry for wanshop-api rename
$root = 'D:\go_work\simple-admin'
$src = Join-Path $root 'wanshop-api'
$dst = Join-Path $root 'zzhshopR2-api'

# list potential lock holders
Get-Process | Where-Object { $_.Name -match 'fsnotifier|gopls|dlv|goland' } | ForEach-Object {
    Write-Output ('IDE-PROC pid=' + $_.Id + ' name=' + $_.Name)
}
# fsnotifier (JetBrains dir watcher) holds dir handles; GoLand restarts it on demand
Get-Process -Name 'fsnotifier*' -ErrorAction SilentlyContinue | ForEach-Object {
    Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue
    Write-Output ('killed fsnotifier pid=' + $_.Id)
}
Get-Process -Name 'gopls*', 'dlv*' -ErrorAction SilentlyContinue | ForEach-Object {
    Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue
    Write-Output ('killed ' + $_.Name + ' pid=' + $_.Id)
}
Start-Sleep -Seconds 3

if (-not (Test-Path $src)) { Write-Output 'GONE-ALREADY' }
else {
    $ok = $false
    for ($i = 1; $i -le 8; $i++) {
        try {
            [System.IO.Directory]::Move($src, $dst)
            Write-Output ('MOVED: wanshop-api -> zzhshopR2-api')
            $ok = $true
            break
        } catch {
            Write-Output ('RETRY' + $i + ' FAIL: ' + $_.Exception.Message)
            Start-Sleep -Seconds 3
        }
    }
    if (-not $ok) {
        Write-Output 'FALLBACK-ROBOCOPY'
        & robocopy $src $dst /MOVE /E /NFL /NDL /NJH /NP
        Write-Output ('robocopy exit=' + $LASTEXITCODE)
        if (Test-Path $src) { Write-Output 'SRC-STILL-EXISTS' } else { Write-Output 'SRC-REMOVED' }
    }
}

# verify
Write-Output ('--- top level ---')
Get-ChildItem $root -Directory | Where-Object { $_.Name -match 'zzhshopR2|wanshop' } | ForEach-Object { Write-Output $_.Name }

# rename files inside zzhshopR2-api that still carry wanshop in name
$excludeSegs = @('\node_modules\', '\.git\', '\dist\', '\q1_backup\', '\target\', '\.idea\')
foreach ($r in @($dst, (Join-Path $root 'zzhshopR2'), (Join-Path $root 'zzhshopR2-rpc'), (Join-Path $root 'zzhshopR2-app'))) {
    if (-not (Test-Path $r)) { continue }
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
            Write-Output ('RENAMED: ' + $p.Substring($root.Length) + ' -> ' + $newName)
        } catch {
            Write-Output ('RENAME-FAIL: ' + $p + ' :: ' + $_.Exception.Message)
        }
    }
}

# leftovers
$left = Get-ChildItem $dst -Recurse -Force -ErrorAction SilentlyContinue | Where-Object { $_.Name -like '*wanshop*' }
foreach ($l in $left) { Write-Output ('LEFT: ' + $l.FullName) }
Write-Output 'R3C-DONE'
