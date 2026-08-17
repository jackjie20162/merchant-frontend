$base = 'http://127.0.0.1:9108'
$body = @{ account = 'kefu'; password = '123456' } | ConvertTo-Json
$r = Invoke-RestMethod -Uri "$base/merchant/login" -Method Post -ContentType 'application/json' -Body $body
$token = $r.data.token
$jsonList = '{"page":1,"page_size":10}'
Write-Output '--- order/list body ---'
& curl.exe -s -X POST "$base/merchant/order/list" -H "Authorization: Bearer $token" -H "Content-Type: application/json" -d $jsonList
Write-Output ''
Write-Output '--- staff/list body (has perm, expect code=0) ---'
& curl.exe -s -X POST "$base/merchant/staff/list" -H "Authorization: Bearer $token" -H "Content-Type: application/json" -d $jsonList
