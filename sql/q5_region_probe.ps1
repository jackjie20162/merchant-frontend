# probe region source (ASCII only)
$out = 'D:\go_work\simple-admin\store-console-frontend\sql\dbg_region.txt'
'' | Out-File $out -Encoding UTF8

# address schema
Write-Output '===== address schema' | Out-File $out -Append -Encoding UTF8
Get-Content 'D:\go_work\simple-admin\wanshop-rpc\ent\schema\address.go' -Encoding UTF8 | Out-File $out -Append -Encoding UTF8

# address proto
Write-Output '===== address proto' | Out-File $out -Append -Encoding UTF8
Get-Content 'D:\go_work\simple-admin\wanshop-rpc\desc\address.proto' -Encoding UTF8 | Out-File $out -Append -Encoding UTF8

# find php source dir dynamically to avoid Chinese path in script
Write-Output '===== php region select list' | Out-File $out -Append -Encoding UTF8
$phpDir = Get-ChildItem 'D:\go_work\simple-admin' -Directory | Where-Object { $_.Name -like 'php*' } | Select-Object -First 1
if ($phpDir) {
    $phpRoot = $phpDir.FullName
    Write-Output ('phpRoot=' + $phpRoot) | Out-File $out -Append -Encoding UTF8
    $files = Get-ChildItem $phpRoot -Recurse -File | Where-Object { $_.Extension -in @('.js','.html','.php') }
    $count = 0
    foreach ($f in $files) {
        $hits = Select-String -Path $f.FullName -Pattern 'province|citys|Zhejiang|Beijing' -Encoding UTF8 | Select-Object -First 5
        foreach ($h in $hits) {
            Write-Output ($f.FullName.Substring($phpRoot.Length) + ':' + $h.LineNumber + ' ' + $h.Line.Trim()) | Out-File $out -Append -Encoding UTF8
            $count++
            if ($count -gt 80) { break }
        }
        if ($count -gt 80) { break }
    }
} else {
    Write-Output 'php source path not found' | Out-File $out -Append -Encoding UTF8
}
Write-Output 'DONE' | Out-File $out -Append -Encoding UTF8
