# verify q7 files (ASCII only)
$out = 'D:\go_work\simple-admin\merchant-frontend\sql\dbg_q7.txt'
$urls = @(
    'http://localhost:5174/src/views/shop/ShopInfo.vue',
    'http://localhost:5174/src/components/RegionPicker.vue',
    'http://localhost:5174/src/utils/regionData.js'
)
'' | Out-File $out -Encoding UTF8
foreach ($u in $urls) {
    try {
        $r = Invoke-WebRequest -Uri $u -UseBasicParsing -TimeoutSec 15
        ('OK ' + $r.StatusCode + ' ' + $u + ' len=' + $r.Content.Length) | Out-File $out -Append -Encoding UTF8
    } catch {
        ('FAIL ' + $u + ' ' + $_.Exception.Message) | Out-File $out -Append -Encoding UTF8
    }
}
