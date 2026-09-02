# probe region data source in php (ASCII only)
$out = 'D:\go_work\simple-admin\merchant-frontend\sql\dbg_region_data.txt'
'' | Out-File $out -Encoding UTF8

$phpRoot = (Get-ChildItem 'D:\go_work\simple-admin' -Directory | Where-Object { $_.Name -like 'php*' } | Select-Object -First 1).FullName
if (!$phpRoot) { exit }

# candidate files
$candidates = Get-ChildItem $phpRoot -Recurse -File | Where-Object { $_.Name -match 'area|region|city|province|district' -and $_.Extension -in @('.js','.json','.php') } | Select-Object -First 50
foreach ($f in $candidates) {
    Write-Output ('FILE ' + $f.FullName.Substring($phpRoot.Length)) | Out-File $out -Append -Encoding UTF8
}

# search for Config.area assignment or region arrays in HTML/JS
$exts = @('.html','.js','.php','.vue')
$hits = Get-ChildItem $phpRoot -Recurse -File | Where-Object { $exts -contains $_.Extension } | ForEach-Object {
    Select-String -Path $_.FullName -Pattern 'area|province|city|district|region' -Encoding UTF8 -CaseSensitive:$false | ForEach-Object {
        $rel = $_.Path.Substring($phpRoot.Length)
        Write-Output ($rel + ':' + $_.LineNumber + ' ' + $_.Line.Trim())
    }
}
$hits | Select-Object -First 200 | Out-File $out -Append -Encoding UTF8

Write-Output 'DONE' | Out-File $out -Append -Encoding UTF8
