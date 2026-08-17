# Merchant phase-1 smoke test (ASCII only, avoid GBK parse issue)
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
    try {
        $r = Invoke-RestMethod -Uri $url -Method Post -ContentType 'application/json; charset=utf-8' -Headers @{ Authorization = "Bearer $token" } -Body ([System.Text.Encoding]::UTF8.GetBytes($body))
        return @{ ok = ($r.code -eq 0); raw = ($r | ConvertTo-Json -Depth 3 -Compress) }
    } catch {
        return @{ ok = $false; raw = $_.Exception.Message }
    }
}

function Check($name, $res) {
    if ($res.ok) { $script:pass++; Write-Output "[PASS] $name" } else { $script:fail++; Write-Output "[FAIL] $name => $($res.raw)" }
}

# 1. admin login
$adminToken = Login 'admin'
if ($adminToken) { Write-Output "[PASS] admin login" } else { Write-Output '[FAIL] admin login'; exit 1 }

# 2. profile / shop info
try { $p = Invoke-RestMethod -Uri "$base/merchant/profile" -Headers @{ Authorization = "Bearer $adminToken" }; Check 'profile' @{ ok = ($p.code -eq 0); raw = '' } } catch { Check 'profile' @{ ok = $false; raw = $_.Exception.Message } }
try { $s = Invoke-RestMethod -Uri "$base/merchant/shop/info" -Headers @{ Authorization = "Bearer $adminToken" }; Check 'shop/info' @{ ok = ($s.code -eq 0); raw = '' } } catch { Check 'shop/info' @{ ok = $false; raw = $_.Exception.Message } }

# 3. module lists (empty data should still be code=0)
$lists = @(
    @('/merchant/order/list', @{ page = 1; page_size = 10 }),
    @('/merchant/groups/list', @{ page = 1; page_size = 10 }),
    @('/merchant/comment/list', @{ page = 1; page_size = 10 }),
    @('/merchant/refund/list', @{ page = 1; page_size = 10 }),
    @('/merchant/goods/list', @{ page = 1; page_size = 10; grounding = 1 }),
    @('/merchant/freight/list', @{ page = 1; page_size = 10 }),
    @('/merchant/category/tree', $null),
    @('/merchant/brand/list', @{ page = 1; page_size = 10 }),
    @('/merchant/attachment/list', @{ page = 1; page_size = 10 }),
    @('/merchant/page/list', @{ page = 1; page_size = 10 }),
    @('/merchant/page/list?type=systpl', @{ page = 1; page_size = 10; type = 'systpl' }),
    @('/merchant/staff/list', @{ page = 1; page_size = 10 })
)
foreach ($item in $lists) {
    $res = PostJson ($base + $item[0]) $adminToken $item[1]
    Check $item[0] $res
}

# 4. perm codes registry
try { $pc = Invoke-RestMethod -Uri "$base/merchant/perm/codes" -Headers @{ Authorization = "Bearer $adminToken" }; Check 'perm/codes' @{ ok = ($pc.code -eq 0); raw = '' } } catch { Check 'perm/codes' @{ ok = $false; raw = $_.Exception.Message } }

# 5. upload + static access
$pngBytes = [byte[]](0x89,0x50,0x4E,0x47,0x0D,0x0A,0x1A,0x0A,0x00,0x00,0x00,0x0D,0x49,0x48,0x44,0x52,0x00,0x00,0x00,0x01,0x00,0x00,0x00,0x01,0x08,0x06,0x00,0x00,0x00,0x1F,0x15,0xC4,0x89,0x00,0x00,0x00,0x0D,0x49,0x44,0x41,0x54,0x78,0x9C,0x62,0x00,0x01,0x00,0x00,0x05,0x00,0x01,0x0D,0x0A,0x2D,0xB4,0x00,0x00,0x00,0x00,0x49,0x45,0x4E,0x44,0xAE,0x42,0x60,0x82)
$pngPath = "$env:TEMP\smoke_test.png"
[System.IO.File]::WriteAllBytes($pngPath, $pngBytes)
$up = & curl.exe -s -X POST "$base/merchant/attachment/upload" -H "Authorization: Bearer $adminToken" -F "file=@$pngPath;type=image/png"
Write-Output "[INFO] upload resp: $up"
$upObj = $up | ConvertFrom-Json
if ($upObj.code -eq 0 -and $upObj.data.url) {
    $pass++
    Write-Output "[PASS] attachment/upload url=$($upObj.data.url)"
    $code = & curl.exe -s -o NUL -w "%{http_code}" ($base + $upObj.data.url)
    if ($code -eq '200') { $pass++; Write-Output '[PASS] static GET 200' } else { $fail++; Write-Output "[FAIL] static GET code=$code" }
} else { $fail++; Write-Output '[FAIL] attachment/upload' }

# 6. kefu forbidden check (default role has no new perms, expect 403)
$kefuToken = Login 'kefu'
if (-not $kefuToken) { Write-Output '[FAIL] kefu login'; exit 1 }
Write-Output '[PASS] kefu login'
# ErrorJson returns HTTP 200 with business code 403 in body, so assert on body code
$jsonList = '{"page":1,"page_size":10}'
$rb = & curl.exe -s -X POST "$base/merchant/order/list" -H "Authorization: Bearer $kefuToken" -H "Content-Type: application/json" -d $jsonList
if (($rb | ConvertFrom-Json).code -eq 403) { $pass++; Write-Output '[PASS] kefu order/list denied' } else { $fail++; Write-Output "[FAIL] kefu order/list expected body code 403 got $rb" }
$jsonEmpty = '{}'
$rb = & curl.exe -s -X POST "$base/merchant/goods/save" -H "Authorization: Bearer $kefuToken" -H "Content-Type: application/json" -d $jsonEmpty
if (($rb | ConvertFrom-Json).code -eq 403) { $pass++; Write-Output '[PASS] kefu goods/save denied' } else { $fail++; Write-Output "[FAIL] kefu goods/save expected body code 403 got $rb" }
$code = & curl.exe -s -o NUL -w "%{http_code}" "$base/merchant/profile" -H "Authorization: Bearer $kefuToken"
if ($code -eq '200') { $pass++; Write-Output '[PASS] kefu profile 200' } else { $fail++; Write-Output "[FAIL] kefu profile expected 200 got $code" }

Write-Output ''
Write-Output "===== RESULT: PASS=$pass FAIL=$fail ====="
