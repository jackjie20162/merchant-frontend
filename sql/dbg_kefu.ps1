$base = 'http://127.0.0.1:9108'
$body = @{ account = 'kefu'; password = '123456' } | ConvertTo-Json
$r = Invoke-RestMethod -Uri "$base/merchant/login" -Method Post -ContentType 'application/json' -Body $body
$token = $r.data.token
Write-Output "staffId=$($r.data.staffId) merchantId=$($r.data.merchantId) shopId=$($r.data.shopId)"
$p = Invoke-RestMethod -Uri "$base/merchant/profile" -Headers @{ Authorization = "Bearer $token" }
Write-Output "perms:"
$p.data.perms | ForEach-Object { Write-Output ("  " + $_) }
