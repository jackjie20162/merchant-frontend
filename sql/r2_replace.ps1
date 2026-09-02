# global replace zzhshopR2 -> zzhshopR2 in source files (UTF-8 no BOM, preserve line endings)
$root = 'D:\go_work\simple-admin'
$roots = @(
    (Join-Path $root 'zzhshopR2'),
    (Join-Path $root 'zzhshopR2-api'),
    (Join-Path $root 'zzhshopR2-rpc'),
    (Join-Path $root 'zzhshopR2-app'),
    (Join-Path $root 'merchant-frontend'),
    (Join-Path $root 'simple-admin-vben5-ui-main\apps\simple-admin-core')
)
$excludeSegs = @('\node_modules\', '\.git\', '\dist\', '\q1_backup\', '\target\', '\.idea\')
$exts = @('.go', '.mod', '.api', '.yaml', '.yml', '.md', '.py', '.js', '.ts', '.mts', '.vue', '.json', '.sql', '.rs', '.toml', '.ps1', '.txt.disabled')
$names = @('Makefile', 'Dockerfile')
$utf8 = New-Object System.Text.UTF8Encoding($false)
$changed = 0
foreach ($r in $roots) {
    if (-not (Test-Path $r)) { Write-Output ('MISSING: ' + $r); continue }
    $files = Get-ChildItem $r -Recurse -File -ErrorAction SilentlyContinue
    foreach ($f in $files) {
        $p = $f.FullName
        $skip = $false
        foreach ($seg in $excludeSegs) { if ($p.Contains($seg)) { $skip = $true; break } }
        if ($skip) { continue }
        $ok = $names -contains $f.Name
        if (-not $ok) { $ok = $exts -contains $f.Extension.ToLower() }
        if (-not $ok) { continue }
        if ($f.Length -gt 4MB) { continue }
        $text = [System.IO.File]::ReadAllText($p)
        if ($text.Contains('zzhshopR2') -or $text.Contains('ZzhshopR2')) {
            $text = $text.Replace('zzhshopR2', 'zzhshopR2').Replace('ZzhshopR2', 'ZzhshopR2')
            [System.IO.File]::WriteAllText($p, $text, $utf8)
            $changed++
            Write-Output ('CHANGED: ' + $p.Substring($root.Length))
        }
    }
}
Write-Output ('TOTAL CHANGED: ' + $changed)
