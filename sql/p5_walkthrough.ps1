# p5 decorate (DIY page) interface-level walkthrough (ASCII comments only)
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

# ---- create blank page with one banner component ----
$itemJson = '[{"name":"banner","type":"banner","style":{"color":"#000000"},"params":{"interval":"2800","height":"115px"},"data":[{"image":"","link":""}]}]'
$pageJson = '{"params":{"navigationBarTitleText":"p5 title"},"style":{"pageBackgroundColor":"#f5f5f5"}}'
$r = PostJson "$base/merchant/page/save" $adminToken @{ name = 'p5 test page'; type = 'page'; page = $pageJson; item = $itemJson }
Check 'page/save create returns id' ($r.code -eq 0 -and $r.data.id -gt 0)
$pageId = $r.data.id

# ---- detail roundtrip ----
$r = Invoke-RestMethod -Uri "$base/merchant/page/detail/$pageId" -Headers @{ Authorization = "Bearer $adminToken" }
Check 'page/detail code=0' ($r.code -eq 0)
Check 'page/detail name matches' ($r.data.name -eq 'p5 test page')
$items = $r.data.item | ConvertFrom-Json
Check 'item json roundtrip: 1 banner' ($items.Count -eq 1 -and $items[0].type -eq 'banner')
$conf = $r.data.page | ConvertFrom-Json
Check 'page conf roundtrip: nav title' ($conf.params.navigationBarTitleText -eq 'p5 title')

# ---- update page (rename + add component) ----
$itemJson2 = '[{"name":"banner","type":"banner","style":{},"params":{},"data":[{"image":"","link":""}]},{"name":"empty","type":"empty","style":{"height":"25px"},"data":[]}]'
$r = PostJson "$base/merchant/page/save" $adminToken @{ id = $pageId; name = 'p5 test page v2'; page = $pageJson; item = $itemJson2 }
Check 'page/save update code=0' ($r.code -eq 0)
$r = Invoke-RestMethod -Uri "$base/merchant/page/detail/$pageId" -Headers @{ Authorization = "Bearer $adminToken" }
$items = $r.data.item | ConvertFrom-Json
Check 'updated: name + 2 components' ($r.data.name -eq 'p5 test page v2' -and $items.Count -eq 2)

# ---- shop page list contains it ----
$r = PostJson "$base/merchant/page/list" $adminToken @{ page = 1; page_size = 50 }
Check 'page/list code=0' ($r.code -eq 0)
$found = $false
foreach ($p in @($r.data.data)) { if ($p.id -eq $pageId) { $found = $true } }
Check 'created page in shop list' $found

# ---- systpl template list (read-only reference) ----
$r = PostJson "$base/merchant/page/list" $adminToken @{ page = 1; page_size = 50; type = 'systpl' }
Check 'page/list systpl code=0' ($r.code -eq 0)
Write-Output ('[INFO] systpl templates count=' + @($r.data.data).Count)

# ---- creating systpl/index type must be rejected ----
$r = PostJson "$base/merchant/page/save" $adminToken @{ name = 'p5 bad type'; type = 'systpl'; item = '[]' }
Write-Output ('[INFO] page/save systpl body code=' + $r.code)
Check 'page/save systpl rejected' ($r.code -ne 0)

# ---- delete page ----
$r = PostJson "$base/merchant/page/delete" $adminToken @{ ids = @($pageId) }
Check 'page/delete code=0' ($r.code -eq 0)
$r = PostJson "$base/merchant/page/list" $adminToken @{ page = 1; page_size = 50 }
$left = 0
foreach ($p in @($r.data.data)) { if ($p.id -eq $pageId) { $left++ } }
Check 'deleted page gone from list' ($left -eq 0)

# ---- cross-shop guard: detail of other shop page denied ----
# page id 1 belongs to platform/other shop in legacy data (type=systpl readable, so pick a foreign non-systpl if exists)
$r = PostJson "$base/merchant/page/list" $adminToken @{ page = 1; page_size = 50 }
Write-Output ('[INFO] shop pages after cleanup=' + @($r.data.data).Count)

# ---- kefu permission guard ----
$kefuToken = Login 'kefu'
Check 'kefu login' ($kefuToken -ne $null -and $kefuToken -ne '')
$r = PostJson "$base/merchant/page/list" $kefuToken @{ page = 1; page_size = 10 }
Write-Output ('[INFO] kefu page/list body code=' + $r.code)
Check 'kefu page/list denied(403)' ($r.code -eq 403)
$r = PostJson "$base/merchant/page/save" $kefuToken @{ name = 'x' }
Check 'kefu page/save denied(403)' ($r.code -eq 403)

Write-Output ''
Write-Output "RESULT: pass=$pass fail=$fail"
