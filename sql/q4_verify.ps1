# q4 verify: vite transforms finance pages (ASCII only)
$out = 'D:\go_work\simple-admin\merchant-frontend\sql\dbg_q4verify.txt'
'' | Out-File $out -Encoding UTF8

foreach ($p in @('/src/views/finance/Bill.vue', '/src/views/finance/Withdraw.vue', '/src/api/finance.js', '/src/router/index.js', '/src/views/Layout.vue')) {
    try {
        $r = Invoke-WebRequest -Uri ('http://localhost:5174' + $p) -UseBasicParsing -TimeoutSec 15
        Write-Output ('OK ' + $r.StatusCode + ' ' + $p + ' len=' + $r.Content.Length) | Out-File $out -Append -Encoding UTF8
    } catch {
        Write-Output ('FAIL ' + $p + ' ' + $_.Exception.Message) | Out-File $out -Append -Encoding UTF8
    }
}
Write-Output 'DONE' | Out-File $out -Append -Encoding UTF8
