# probe goods/save with a valid admin token and print raw response
$base = 'http://127.0.0.1:9108'
$loginBody = @{ account = 'admin'; password = '123456' } | ConvertTo-Json
$lr = Invoke-RestMethod -Uri "$base/merchant/login" -Method Post -ContentType 'application/json' -Body $loginBody
$token = $lr.data.token
Write-Output ('token_ok=' + ($token -ne $null -and $token -ne ''))

$spu = @{ name = 'spec'; item = '["default"]' }
$sku = @{ difference = '{"spec":"default"}'; price = '9.90'; market_price = '12.90'; stock = 10; sn = '' }
$goods = @{ title = 'probe goods'; category_id = 1; image = '/static/t.png'; specs = 'single'; grounding = 0 }
$bodyObj = @{ goods = $goods; spus = @($spu); skus = @($sku) }
$json = $bodyObj | ConvertTo-Json -Depth 8
Write-Output '--- request body ---'
Write-Output $json

try {
    $r = Invoke-WebRequest -Uri "$base/merchant/goods/save" -Method Post -ContentType 'application/json; charset=utf-8' -Headers @{ Authorization = "Bearer $token" } -Body ([System.Text.Encoding]::UTF8.GetBytes($json))
    Write-Output ('status=' + $r.StatusCode)
    Write-Output $r.Content
} catch {
    $resp = $_.Exception.Response
    if ($resp) {
        Write-Output ('status=' + [int]$resp.StatusCode)
        $stream = $resp.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($stream)
        Write-Output $reader.ReadToEnd()
    } else {
        Write-Output ('err=' + $_.Exception.Message)
    }
}
