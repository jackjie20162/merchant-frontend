$base = 'http://127.0.0.1:9108'
$out = 'D:\go_work\simple-admin\store-console-frontend\sql\dbg_q2fail.txt'
'' | Out-File -Encoding utf8 $out

function PostJson($url, $token, $bodyObj) {
    $body = '{}'
    if ($bodyObj) { $body = $bodyObj | ConvertTo-Json -Depth 8 }
    try {
        $r = Invoke-RestMethod -Uri $url -Method Post -ContentType 'application/json; charset=utf-8' -Headers @{ Authorization = "Bearer $token" } -Body ([System.Text.Encoding]::UTF8.GetBytes($body))
        return ($r | ConvertTo-Json -Depth 10)
    } catch {
        return ('EX: ' + $_.Exception.Message)
    }
}

function GetJson($url, $token) {
    try {
        $r = Invoke-RestMethod -Uri $url -Headers @{ Authorization = "Bearer $token" }
        return ($r | ConvertTo-Json -Depth 10)
    } catch {
        return ('EX: ' + $_.Exception.Message)
    }
}

$lb = @{ account = 'admin'; password = '123456' } | ConvertTo-Json
$r = Invoke-RestMethod -Uri "$base/merchant/login" -Method Post -ContentType 'application/json' -Body $lb
$token = $r.data.token

Add-Content $out '===== GET /merchant/perm/codes ====='
Add-Content $out (GetJson "$base/merchant/perm/codes" $token)

Add-Content $out '===== POST /merchant/coupon/list ====='
Add-Content $out (PostJson "$base/merchant/coupon/list" $token @{ page = 1; page_size = 5 })

Add-Content $out '===== POST /merchant/coupon/save ====='
Add-Content $out (PostJson "$base/merchant/coupon/save" $token @{ type = 'reduction'; name = 'q2 dbg coupon'; price = 10.0; limit = 100.0; rangetype = 'all'; pretype = 'fixed'; validity = 7; drawlimit = 1; grant = 'auto'; startdate = '2026-08-01'; enddate = '2026-12-31'; status = 'normal' })

Add-Content $out '===== POST /merchant/freight/tpl/save create ====='
Add-Content $out (PostJson "$base/merchant/freight/tpl/save" $token @{ freight = @{ name = 'q2 dbg tpl'; delivery = '48'; isdelivery = '0'; valuation = '0'; status = 'normal' }; data = @(@{ province = 'Beijing'; citys = ''; first = 1; first_fee = 8.0; additional = 1; additional_fee = 2.0; status = 'normal' }) })

Add-Content $out '===== POST /merchant/freight/tpl/list ====='
Add-Content $out (PostJson "$base/merchant/freight/tpl/list" $token @{ page = 1; page_size = 5 })
