$base = 'http://127.0.0.1:9108'
$body = @{ account = 'kefu'; password = '123456' } | ConvertTo-Json
$r = Invoke-RestMethod -Uri "$base/merchant/login" -Method Post -ContentType 'application/json' -Body $body
$token = $r.data.token
$jsonList = '{"page":1,"page_size":10}'
Write-Output '--- order/list ---'
& curl.exe -s -i -X POST "$base/merchant/order/list" -H "Authorization: Bearer $token" -H "Content-Type: application/json" -d $jsonList | Select-Object -First 12
Write-Output ''
Write-Output '--- staff/list (perm staff:list, should 200) ---'
& curl.exe -s -o NUL -w "%{http_code}`n" -X POST "$base/merchant/staff/list" -H "Authorization: Bearer $token" -H "Content-Type: application/json" -d $jsonList
Write-Output '--- role/list (perm role:list, should 403) ---'
& curl.exe -s -o NUL -w "%{http_code}`n" "$base/merchant/role/list" -H "Authorization: Bearer $token"
Write-Output '--- comment/list (perm comment:list, should 403) ---'
& curl.exe -s -o NUL -w "%{http_code}`n" -X POST "$base/merchant/comment/list" -H "Authorization: Bearer $token" -H "Content-Type: application/json" -d $jsonList
