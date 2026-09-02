# s2: rename merchant-frontend -> merchant-frontend (content + dir)
$root = 'D:\go_work\simple-admin'
$oldDir = Join-Path $root 'merchant-frontend'
$newDir = Join-Path $root 'merchant-frontend'
$utf8 = New-Object System.Text.UTF8Encoding($false)

# 1. replace content inside the project dir
$excludeSegs = @('\node_modules\', '\.git\', '\dist\', '\q1_backup\', '\target\', '\.idea\')
$exts = @('.go', '.mod', '.api', '.yaml', '.yml', '.md', '.js', '.ts', '.mts', '.vue', '.json', '.sql', '.ps1', '.toml', '.rs', '.config')
$names = @('Makefile', 'Dockerfile')
$changed = 0
$files = Get-ChildItem $oldDir -Recurse -File -ErrorAction SilentlyContinue
foreach ($f in $files) {
    $p = $f.FullName
    $skip = $false
    foreach ($seg in $excludeSegs) { if ($p.Contains($seg)) { $skip = $true; break } }
    if ($skip) { continue }
    $ok = $names -contains $f.Name
    if (-not $ok) { $ok = $exts -contains $f.Extension.ToLower() }
    if (-not $ok) { continue }
    if ($f.Length -gt 2MB) { continue }
    $text = [System.IO.File]::ReadAllText($p)
    if ($text.Contains('merchant-frontend')) {
        $text = $text.Replace('merchant-frontend', 'merchant-frontend')
        [System.IO.File]::WriteAllText($p, $text, $utf8)
        $changed++
    }
}
Write-Output ('CONTENT-CHANGED: ' + $changed)

# 2. kill vite dev servers holding the dir
Get-CimInstance Win32_Process | Where-Object { $_.Name -eq 'node.exe' -and $_.CommandLine -match 'merchant-frontend' } | ForEach-Object {
    Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue
    Write-Output ('killed node pid=' + $_.ProcessId)
}
Start-Sleep -Seconds 3

# 3. rename dir (retry + robocopy fallback)
$ok = $false
if (Test-Path $newDir) { Write-Output 'NEW-DIR-EXISTS-ABORT' }
else {
    for ($i = 1; $i -le 6; $i++) {
        try {
            [System.IO.Directory]::Move($oldDir, $newDir)
            Write-Output 'DIR-MOVED'
            $ok = $true
            break
        } catch {
            Write-Output ('RETRY' + $i + ' FAIL: ' + $_.Exception.Message)
            Start-Sleep -Seconds 3
        }
    }
    if (-not $ok) {
        Write-Output 'FALLBACK-ROBOCOPY'
        & robocopy $oldDir $newDir /MOVE /E /NFL /NDL /NJH /NP
        Write-Output ('robocopy exit=' + $LASTEXITCODE)
        if (Test-Path $oldDir) { Write-Output 'SRC-STILL-EXISTS' } else { Write-Output 'SRC-REMOVED' }
    }
}

# 4. verify
Write-Output ('newDir exists: ' + (Test-Path $newDir))
Write-Output ('oldDir exists: ' + (Test-Path $oldDir))
if (Test-Path $newDir) {
    Get-ChildItem $newDir | Select-Object -ExpandProperty Name | ForEach-Object { Write-Output ('  ' + $_) }
}
Write-Output 'S2-DONE'
