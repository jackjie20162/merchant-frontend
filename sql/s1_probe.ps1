# s1 probe: find content references to merchant-frontend + processes using the dir
$root = 'D:\go_work\simple-admin'
$out = Join-Path $root 'merchant-frontend\sql\dbg_s1.txt'
'' | Out-File -Encoding utf8 $out

# 1. content references (text files, exclude heavy dirs)
$excludeSegs = @('\node_modules\', '\.git\', '\dist\', '\q1_backup\', '\target\', '\.idea\')
$exts = @('.go', '.mod', '.api', '.yaml', '.yml', '.md', '.js', '.ts', '.mts', '.vue', '.json', '.sql', '.ps1', '.toml', '.config')
$names = @('Makefile', 'Dockerfile')
$scanRoots = @(
    (Join-Path $root 'merchant-frontend'),
    (Join-Path $root 'zzhshopR2-api'),
    (Join-Path $root 'zzhshopR2-rpc'),
    (Join-Path $root 'zzhshopR2-app'),
    (Join-Path $root 'zzhshopR2'),
    (Join-Path $root 'simple-admin-vben5-ui-main\apps\simple-admin-core')
)
$hits = 0
foreach ($r in $scanRoots) {
    if (-not (Test-Path $r)) { continue }
    $files = Get-ChildItem $r -Recurse -File -ErrorAction SilentlyContinue
    foreach ($f in $files) {
        $p = $f.FullName
        $skip = $false
        foreach ($seg in $excludeSegs) { if ($p.Contains($seg)) { $skip = $true; break } }
        if ($skip) { continue }
        $ok = $names -contains $f.Name
        if (-not $ok) { $ok = $exts -contains $f.Extension.ToLower() }
        if (-not $ok) { continue }
        if ($f.Length -gt 2MB) { continue }
        $m = Select-String -LiteralPath $p -Pattern 'merchant-frontend' -SimpleMatch -List
        if ($m) {
            $hits++
            Add-Content $out ('REF: ' + $p.Substring($root.Length))
        }
    }
}
Add-Content $out ('REF-FILES: ' + $hits)

# 2. processes with command line referencing the dir
$procs = Get-CimInstance Win32_Process | Where-Object { $_.CommandLine -and $_.CommandLine -match 'merchant-frontend' }
foreach ($p in $procs) {
    $cl = $p.CommandLine
    if ($cl.Length -gt 180) { $cl = $cl.Substring(0, 180) }
    Add-Content $out ('PROC pid=' + $p.ProcessId + ' name=' + $p.Name + ' cmd=' + $cl)
}

# 3. port 5173 listener
$c = Get-NetTCPConnection -LocalPort 5173 -State Listen -ErrorAction SilentlyContinue | Select-Object -First 1
if ($c) { Add-Content $out ('PORT5173 pid=' + $c.OwningProcess) } else { Add-Content $out 'PORT5173 none' }
Write-Output 'S1-DONE'
