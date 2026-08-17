# verify freight.vue transform (ASCII only)
$out = 'D:\go_work\simple-admin\store-console-frontend\sql\dbg_freight_verify.txt'
try {
    $r = Invoke-WebRequest -Uri 'http://localhost:5174/src/views/freight/Freight.vue' -UseBasicParsing -TimeoutSec 15
    ('OK ' + $r.StatusCode + ' len=' + $r.Content.Length) | Out-File $out -Encoding UTF8
} catch {
    ('FAIL ' + $_.Exception.Message) | Out-File $out -Encoding UTF8
}
