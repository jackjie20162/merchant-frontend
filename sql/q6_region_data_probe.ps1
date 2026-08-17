# probe region data source in php and frontend (ASCII only)
$out = 'D:\go_work\simple-admin\store-console-frontend\sql\dbg_region_data.txt'
'' | Out-File $out -Encoding UTF8

# find php source dir
$phpDir = Get-ChildItem 'D:\go_work\simple-admin' -Directory | Where-Object { $_.Name -like 'php*' } | Select-Object -First 1
if ($phpDir) {
    $phpRoot = $phpDir.FullName
    # search for area/config files
    $candidates = Get-ChildItem $phpRoot -Recurse -File | Where-Object { $_.Name -match 'area|region|city|config' -and $_.Extension -in @('.js','.json','.php') } | Select-Object -First 30
    foreach ($f in $candidates) {
        Write-Output ('FILE ' + $f.FullName.Substring($phpRoot.Length)) | Out-File $out -Append -Encoding UTF8
    }
    # search Config.area assignment
    $hits = Get-ChildItem $phpRoot -Recurse -File | Where-Object { $_.Extension -in @('.html','.js','.php') } | ForEach-Object {
        Select-String -Path $_.FullName -Pattern 'Config\.area|area:|regions:|citys:' -Encoding UTF8 | Select-Object -First 3
    }
    foreach ($h in $hits) {
        Write-Output ($h.Path.Substring($phpRoot.Length) + ':' + $h.LineNumber + ' ' + $h.Line.Trim()) | Out-File $out -Append -Encoding UTF8
    }
} else {
    Write-Output 'php source path not found' | Out-File $out -Append -Encoding UTF8
}

# check frontend for any region json
$feDir = 'D:\go_work\simple-admin\store-console-frontend'
if (Test-Path $feDir) {
    $feFiles = Get-ChildItem $feDir -Recurse -File | Where-Object { $_.Name -match 'region|city|area' -and $_.Extension -in @('.js','.json') } | Select-Object -First 20
    foreach ($f in $feFiles) {
        Write-Output ('FE ' + $f.FullName.Substring($feDir.Length)) | Out-File $out -Append -Encoding UTF8
    }
}
Write-Output 'DONE' | Out-File $out -Append -Encoding UTF8
