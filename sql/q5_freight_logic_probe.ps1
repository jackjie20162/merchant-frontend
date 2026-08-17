# probe how freight data is matched in order logic (ASCII only)
$out = 'D:\go_work\simple-admin\store-console-frontend\sql\dbg_freight_logic.txt'
'' | Out-File $out -Encoding UTF8

$hits = Get-ChildItem 'D:\go_work\simple-admin\wanshop-rpc\internal' -Recurse -File -Filter *.go | ForEach-Object {
    $content = Get-Content $_.FullName -Encoding UTF8 -Raw
    if ($content -match 'ShopFreightData|freight|province|citys') {
        $rel = $_.FullName.Substring('D:\go_work\simple-admin\wanshop-rpc\internal'.Length)
        $lineHits = Select-String -Path $_.FullName -Pattern 'ShopFreightData|GetShopFreightDataList|province|citys' -Encoding UTF8
        foreach ($h in $lineHits) {
            Write-Output ($rel + ':' + $h.LineNumber + ' ' + $h.Line.Trim()) | Out-File $out -Append -Encoding UTF8
        }
    }
}
Write-Output 'DONE' | Out-File $out -Append -Encoding UTF8
