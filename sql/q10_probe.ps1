# probe occurrences of 'zzhshopR2' (case-insensitive) across workspace
$root = 'D:\go_work\simple-admin'
$out = Join-Path $root 'merchant-frontend\sql\dbg_q10.txt'
'' | Out-File $out -Encoding UTF8

$excludeDirs = @('node_modules', '.git', 'dist', '.idea', 'target')

Write-Output '===== files containing zzhshopR2 (case-insensitive)' | Out-File $out -Append -Encoding UTF8
$files = Get-ChildItem $root -Recurse -File -ErrorAction SilentlyContinue |
    Where-Object {
        $p = $_.FullName
        $skip = $false
        foreach ($d in $excludeDirs) { if ($p -match ('\\' + $d + '\\')) { $skip = $true; break } }
        (-not $skip) -and $_.Length -lt 2MB
    }

$total = 0
foreach ($f in $files) {
    try {
        $m = Select-String -Path $f.FullName -Pattern 'zzhshopR2' -Encoding UTF8 -ErrorAction SilentlyContinue
    } catch { $m = $null }
    if ($m) {
        $rel = $f.FullName.Substring($root.Length)
        $count = @($m).Count
        $total += $count
        ($rel + ' :: ' + $count) | Out-File $out -Append -Encoding UTF8
    }
}
('TOTAL MATCH LINES: ' + $total) | Out-File $out -Append -Encoding UTF8

Write-Output '===== case variants' | Out-File $out -Append -Encoding UTF8
foreach ($f in $files) {
    try {
        $m = Select-String -Path $f.FullName -Pattern 'WanShop|ZzhshopR2|WANSHOP|zzhshopR2' -CaseSensitive -Encoding UTF8 -ErrorAction SilentlyContinue
    } catch { $m = $null }
    if ($m) {
        foreach ($x in @($m)) {
            if ($x.Line -match 'WanShop|ZzhshopR2|WANSHOP') {
                ($f.FullName.Substring($root.Length) + ':' + $x.LineNumber + ' ' + $x.Line.Trim().Substring(0, [Math]::Min(120, $x.Line.Trim().Length))) | Out-File $out -Append -Encoding UTF8
            }
        }
    }
}
Write-Output 'DONE' | Out-File $out -Append -Encoding UTF8
