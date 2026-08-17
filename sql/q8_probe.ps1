# probe category tree / goods list usage in views (ASCII only)
$out = 'D:\go_work\simple-admin\store-console-frontend\sql\dbg_q8.txt'
'' | Out-File $out -Encoding UTF8

$root = 'D:\go_work\simple-admin\store-console-frontend\src'
Write-Output '===== categoryTree usage' | Out-File $out -Append -Encoding UTF8
Get-ChildItem $root -Recurse -File -Filter *.vue | ForEach-Object {
    Select-String -Path $_.FullName -Pattern 'CategoryTree|category/tree|categoryTree' -Encoding UTF8 | ForEach-Object {
        ($_.Path.Substring($root.Length) + ':' + $_.LineNumber + ' ' + $_.Line.Trim()) | Out-File $out -Append -Encoding UTF8
    }
}

Write-Output '===== goodsList usage' | Out-File $out -Append -Encoding UTF8
Get-ChildItem $root -Recurse -File -Filter *.vue | ForEach-Object {
    Select-String -Path $_.FullName -Pattern 'goodsList' -Encoding UTF8 | ForEach-Object {
        ($_.Path.Substring($root.Length) + ':' + $_.LineNumber + ' ' + $_.Line.Trim()) | Out-File $out -Append -Encoding UTF8
    }
}
Write-Output 'DONE' | Out-File $out -Append -Encoding UTF8
