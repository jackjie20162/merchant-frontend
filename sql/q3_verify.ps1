# q3 verify: vite dev server transforms new pages (ASCII only)
$out = 'D:\go_work\simple-admin\store-console-frontend\sql\dbg_q3verify.txt'
'' | Out-File $out -Encoding UTF8

$listen = Get-NetTCPConnection -LocalPort 5174 -State Listen -ErrorAction SilentlyContinue
Write-Output ('vite 5174 listening: ' + ($listen.Count -gt 0)) | Out-File $out -Append -Encoding UTF8

if ($true) {
    foreach ($p in @('/src/views/marketing/Coupon.vue', '/src/views/freight/Freight.vue', '/src/router/index.js', '/src/views/Layout.vue', '/src/api/marketing.js', '/src/api/freight.js')) {
        try {
            $r = Invoke-WebRequest -Uri ('http://localhost:5174' + $p) -UseBasicParsing -TimeoutSec 15
            Write-Output ('OK ' + $r.StatusCode + ' ' + $p + ' len=' + $r.Content.Length) | Out-File $out -Append -Encoding UTF8
        } catch {
            Write-Output ('FAIL ' + $p + ' ' + $_.Exception.Message) | Out-File $out -Append -Encoding UTF8
        }
    }
}
Write-Output 'DONE' | Out-File $out -Append -Encoding UTF8
