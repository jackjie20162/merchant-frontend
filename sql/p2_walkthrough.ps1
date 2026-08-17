# p2 frontend interface-level walkthrough (same pattern as smoke.ps1, ASCII only)
$base = 'http://127.0.0.1:9108'
$pass = 0
$fail = 0

function Login($account) {
    $body = @{ account = $account; password = '123456' } | ConvertTo-Json
    $r = Invoke-RestMethod -Uri "$base/merchant/login" -Method Post -ContentType 'application/json' -Body $body
    return $r.data.token
}

function PostJson($url, $token, $bodyObj) {
    $body = '{}'
    if ($bodyObj) { $body = $bodyObj | ConvertTo-Json -Depth 5 }
    $r = Invoke-RestMethod -Uri $url -Method Post -ContentType 'application/json; charset=utf-8' -Headers @{ Authorization = "Bearer $token" } -Body ([System.Text.Encoding]::UTF8.GetBytes($body))
    return $r
}

function Check($name, $cond) {
    if ($cond) { $script:pass++; Write-Output "[PASS] $name" } else { $script:fail++; Write-Output "[FAIL] $name" }
}

# admin: four trade list endpoints + tab filters + detail
$adminToken = Login 'admin'
Check 'admin login' ($adminToken -ne $null -and $adminToken -ne '')

$r = PostJson "$base/merchant/order/list" $adminToken @{ page = 1; page_size = 10 }
Check 'admin order/list code=0' ($r.code -eq 0)
Write-Output ('[INFO] order total=' + $r.data.total)

$r = PostJson "$base/merchant/order/list" $adminToken @{ page = 1; page_size = 10; state = '2' }
Check 'admin order/list tab state=2' ($r.code -eq 0)

$r = PostJson "$base/merchant/groups/list" $adminToken @{ page = 1; page_size = 10 }
Check 'admin groups/list code=0' ($r.code -eq 0)

$r = PostJson "$base/merchant/comment/list" $adminToken @{ page = 1; page_size = 10 }
Check 'admin comment/list code=0' ($r.code -eq 0)

$r = PostJson "$base/merchant/comment/list" $adminToken @{ page = 1; page_size = 10; state = '0' }
Check 'admin comment/list tab state=0' ($r.code -eq 0)

$r = PostJson "$base/merchant/refund/list" $adminToken @{ page = 1; page_size = 10 }
Check 'admin refund/list code=0' ($r.code -eq 0)

$r = PostJson "$base/merchant/refund/list" $adminToken @{ page = 1; page_size = 10; state = '0' }
Check 'admin refund/list tab state=0' ($r.code -eq 0)

# order detail if any data
$orders = (PostJson "$base/merchant/order/list" $adminToken @{ page = 1; page_size = 10 }).data.data
if ($orders -and $orders.Count -gt 0) {
    $oid = $orders[0].id
    $d = Invoke-RestMethod -Uri "$base/merchant/order/detail/$oid" -Headers @{ Authorization = "Bearer $adminToken" }
    Check "admin order/detail/$oid has order" (($d.code -eq 0) -and ($d.data.order -ne $null))
} else {
    Write-Output '[INFO] no orders, skip detail'
}

# refund audit/receive precondition guards (no pending data expected, just route reachable)
$r = PostJson "$base/merchant/refund/audit" $adminToken @{ refund_id = 999999; agree = $false; refuse_content = 'test' }
Check 'admin refund/audit route reachable (non-zero code not 403)' ($r.code -ne 403)

# kefu: four list endpoints denied (body code 403), profile ok
$kefuToken = Login 'kefu'
Check 'kefu login' ($kefuToken -ne $null -and $kefuToken -ne '')

foreach ($ep in @('order/list', 'groups/list', 'comment/list', 'refund/list')) {
    $r = PostJson "$base/merchant/$ep" $kefuToken @{ page = 1; page_size = 10 }
    Check "kefu $ep denied(403)" ($r.code -eq 403)
}

$code = & curl.exe -s -o NUL -w "%{http_code}" "$base/merchant/profile" -H "Authorization: Bearer $kefuToken"
Check 'kefu profile 200' ($code -eq '200')

Write-Output ''
Write-Output "===== RESULT: PASS=$pass FAIL=$fail ====="
