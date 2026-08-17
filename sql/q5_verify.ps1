# q5 verify: vite transforms settings page (ASCII only)
$out = 'D:\go_work\simple-admin\store-console-frontend\sql\dbg_q5verify.txt'
'' | Out-File $out -Encoding UTF8

foreach ($p in @('/src/views/shop/Settings.vue', '/src/api/shop.js', '/src/router/index.js', '/src/views/Layout.vue')) {
    try {
        $r = Invoke-WebRequest -Uri ('http://localhost:5174' + $p) -UseBasicParsing -TimeoutSec 15
        Write-Output ('OK ' + $r.StatusCode + ' ' + $p + ' len=' + $r.Content.Length) | Out-File $out -Append -Encoding UTF8
    } catch {
        Write-Output ('FAIL ' + $p + ' ' + $_.Exception.Message) | Out-File $out -Append -Encoding UTF8
    }
}
Write-Output 'DONE' | Out-File $out -Append -Encoding UTF8
