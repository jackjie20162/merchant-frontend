# q2 marketing/freight/bill/withdraw/settings interface walkthrough (ASCII comments only)
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
    if ($bodyObj) { $body = $bodyObj | ConvertTo-Json -Depth 8 }
    $r = Invoke-RestMethod -Uri $url -Method Post -ContentType 'application/json; charset=utf-8' -Headers @{ Authorization = "Bearer $token" } -Body ([System.Text.Encoding]::UTF8.GetBytes($body))
    return $r
}

function Check($name, $cond) {
    if ($cond) { $script:pass++; Write-Output "[PASS] $name" } else { $script:fail++; Write-Output "[FAIL] $name" }
}

$adminToken = Login 'admin'
Check 'admin login' ($adminToken -ne $null -and $adminToken -ne '')

# ---- perm codes contain new module codes ----
$r = Invoke-RestMethod -Uri "$base/merchant/perm/codes" -Headers @{ Authorization = "Bearer $adminToken" }
$codes = @()
foreach ($item in @($r.data.data)) {
    if ($item -is [string]) { $codes += $item } else { $codes += $item.code }
}
$need = @('coupon:list', 'coupon:save', 'coupon:delete', 'freight:list', 'freight:save', 'freight:delete', 'bill:list', 'withdraw:list', 'withdraw:apply', 'withdraw:delete', 'shop:config')
$missing = @()
foreach ($c in $need) { if ($codes -notcontains $c) { $missing += $c } }
Check 'perm codes contain all 11 new codes' ($missing.Count -eq 0)
if ($missing.Count -gt 0) { Write-Output ('[INFO] missing=' + ($missing -join ',')) }

# ================= coupon =================
$r = PostJson "$base/merchant/coupon/save" $adminToken @{
    type = 'reduction'; name = 'q2 full-10'; userlevel = '0'; usertype = 'reduction'
    price = 10.0; limit = 100.0
    rangetype = 'all'; pretype = 'fixed'; validity = 7; drawlimit = 1
    grant = 'auto'; startdate = '2026-08-01'; enddate = '2026-12-31'; status = 'normal'
}
Check 'coupon/save create code=0' ($r.code -eq 0 -and $r.data.id -gt 0)
$couponId = $r.data.id

$r = PostJson "$base/merchant/coupon/list" $adminToken @{ page = 1; page_size = 20 }
Check 'coupon/list code=0' ($r.code -eq 0)
$found = $false
foreach ($c in @($r.data.data)) { if ($c.id -eq $couponId -and $c.name -eq 'q2 full-10') { $found = $true } }
Check 'created coupon in list' $found

$r = PostJson "$base/merchant/coupon/save" $adminToken @{ id = $couponId; name = 'q2 full-10 v2'; price = 20.0 }
Check 'coupon/save update code=0' ($r.code -eq 0)
$r = PostJson "$base/merchant/coupon/list" $adminToken @{ page = 1; page_size = 20; name = 'q2 full-10 v2' }
Check 'coupon update roundtrip' ($r.code -eq 0 -and @($r.data.data).Count -ge 1)

$r = PostJson "$base/merchant/coupon/delete" $adminToken @{ ids = @($couponId) }
Check 'coupon/delete code=0' ($r.code -eq 0)

# ================= freight template =================
$freightBody = @{
    freight = @{ name = 'q2 tpl'; delivery = '2'; isdelivery = '0'; valuation = '0'; status = 'normal' }
    data = @(
        @{ province = 'Beijing'; citys = ''; first = 1; first_fee = 8.0; additional = 1; additional_fee = 2.0; status = 'normal' },
        @{ province = 'Shanghai'; citys = ''; first = 1; first_fee = 6.0; additional = 1; additional_fee = 1.5; status = 'normal' }
    )
}
$r = PostJson "$base/merchant/freight/tpl/save" $adminToken $freightBody
Check 'freight/tpl/save create code=0' ($r.code -eq 0 -and $r.data.id -gt 0)
$freightId = $r.data.id

$r = Invoke-RestMethod -Uri "$base/merchant/freight/tpl/detail/$freightId" -Headers @{ Authorization = "Bearer $adminToken" }
Check 'freight/tpl/detail code=0' ($r.code -eq 0)
Check 'detail has 2 region rows' (@($r.data.data).Count -eq 2)
$rowId = $r.data.data[0].id

# update: keep row1 (change fee), drop row2, add row3
$updBody = @{
    freight = @{ id = $freightId; name = 'q2 tpl v2' }
    data = @(
        @{ id = $rowId; province = 'Beijing'; citys = ''; first = 1; first_fee = 9.9; additional = 1; additional_fee = 3.0; status = 'normal' },
        @{ province = 'Guangdong'; citys = 'Guangzhou,Shenzhen'; first = 1; first_fee = 12.0; additional = 1; additional_fee = 4.0; status = 'normal' }
    )
}
$r = PostJson "$base/merchant/freight/tpl/save" $adminToken $updBody
Check 'freight/tpl/save update code=0' ($r.code -eq 0)
$r = Invoke-RestMethod -Uri "$base/merchant/freight/tpl/detail/$freightId" -Headers @{ Authorization = "Bearer $adminToken" }
$rows = @($r.data.data)
Check 'sync data: still 2 rows' ($rows.Count -eq 2)
$provs = ($rows | ForEach-Object { $_.province }) -join ','
Check 'sync data: provinces Beijing+Guangdong' ($provs -match 'Beijing' -and $provs -match 'Guangdong' -and $provs -notmatch 'Shanghai')
$bj = $rows | Where-Object { $_.province -eq 'Beijing' } | Select-Object -First 1
Check 'sync data: kept row fee updated' ($bj.first_fee -eq 9.9)

$r = PostJson "$base/merchant/freight/tpl/list" $adminToken @{ page = 1; page_size = 20 }
Check 'freight/tpl/list code=0' ($r.code -eq 0)

$r = PostJson "$base/merchant/freight/tpl/delete" $adminToken @{ ids = @($freightId) }
Check 'freight/tpl/delete code=0' ($r.code -eq 0)

# ================= bill =================
$r = Invoke-RestMethod -Uri "$base/merchant/bill/summary" -Headers @{ Authorization = "Bearer $adminToken" }
Check 'bill/summary code=0' ($r.code -eq 0)
Write-Output ('[INFO] summary income=' + $r.data.income_total + ' refund=' + $r.data.refund_total + ' balance=' + $r.data.balance)
$balance = [double]$r.data.balance

$r = PostJson "$base/merchant/bill/list" $adminToken @{ page = 1; page_size = 10; direction = 'income' }
Check 'bill/list income code=0' ($r.code -eq 0)
$r = PostJson "$base/merchant/bill/list" $adminToken @{ page = 1; page_size = 10; direction = 'refund' }
Check 'bill/list refund code=0' ($r.code -eq 0)

# ================= withdraw =================
$r = PostJson "$base/merchant/withdraw/apply" $adminToken @{ money = ($balance + 99999.0); type = 'alipay'; account = 'q2@test.com'; memo = 'q2 over' }
Write-Output ('[INFO] over-balance apply code=' + $r.code + ' msg=' + $r.msg)
Check 'withdraw over-balance rejected' ($r.code -ne 0)

$appliedId = 0
if ($balance -ge 1.0) {
    $r = PostJson "$base/merchant/withdraw/apply" $adminToken @{ money = 1.0; type = 'alipay'; account = 'q2@test.com'; memo = 'q2 ok' }
    Check 'withdraw apply code=0' ($r.code -eq 0 -and $r.data.id -gt 0)
    $appliedId = $r.data.id
} else {
    Write-Output '[INFO] balance<1, skip success apply case'
}

$r = PostJson "$base/merchant/withdraw/list" $adminToken @{ page = 1; page_size = 20 }
Check 'withdraw/list code=0' ($r.code -eq 0)
if ($appliedId -gt 0) {
    $found = $false
    foreach ($w in @($r.data.data)) { if ($w.id -eq $appliedId -and $w.status -eq 'created') { $found = $true } }
    Check 'applied withdraw in list with status=created' $found
    $r = PostJson "$base/merchant/withdraw/delete" $adminToken @{ ids = @($appliedId) }
    Check 'withdraw/delete(created) code=0' ($r.code -eq 0)
}

# ================= settings =================
$r = Invoke-RestMethod -Uri "$base/merchant/settings/get" -Headers @{ Authorization = "Bearer $adminToken" }
Check 'settings/get code=0' ($r.code -eq 0)

$r = PostJson "$base/merchant/settings/save" $adminToken @{
    freight = '0'; category_style = '1'; welcome = 'q2 welcome'
    send_name = 'q2 sender'; send_phone_num = '13800000001'; send_addr = 'q2 send addr'
    return_name = 'q2 returner'; return_phone_num = '13800000002'; return_addr = 'q2 return addr'
}
Check 'settings/save code=0' ($r.code -eq 0)
$r = Invoke-RestMethod -Uri "$base/merchant/settings/get" -Headers @{ Authorization = "Bearer $adminToken" }
Check 'settings roundtrip send_name' ($r.data.send_name -eq 'q2 sender')
Check 'settings roundtrip return_addr' ($r.data.return_addr -eq 'q2 return addr')
Check 'settings roundtrip welcome' ($r.data.welcome -eq 'q2 welcome')

# ================= kefu permission guard =================
$kefuToken = Login 'kefu'
Check 'kefu login' ($kefuToken -ne $null -and $kefuToken -ne '')
$r = PostJson "$base/merchant/coupon/list" $kefuToken @{ page = 1; page_size = 10 }
Check 'kefu coupon/list denied(403)' ($r.code -eq 403)
$r = PostJson "$base/merchant/withdraw/apply" $kefuToken @{ money = 1.0 }
Check 'kefu withdraw/apply denied(403)' ($r.code -eq 403)
$r = Invoke-RestMethod -Uri "$base/merchant/settings/get" -Headers @{ Authorization = "Bearer $kefuToken" }
Check 'kefu settings/get denied(403)' ($r.code -eq 403)

Write-Output ''
Write-Output "RESULT: pass=$pass fail=$fail"
