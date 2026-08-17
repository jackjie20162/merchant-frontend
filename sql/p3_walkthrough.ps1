# p3 goods module interface-level walkthrough (ASCII comments only)
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

# ---- dropdown data sources ----
$r = PostJson "$base/merchant/freight/list" $adminToken @{ page = 1; page_size = 10 }
Check 'admin freight/list code=0' ($r.code -eq 0)

$r = PostJson "$base/merchant/category/tree" $adminToken @{ type = 'goods' }
Check 'admin merchant category/tree code=0' ($r.code -eq 0)

$r = PostJson "$base/merchant/brand/list" $adminToken @{ page = 1; page_size = 10 }
Check 'admin brand/list code=0' ($r.code -eq 0)

$r = Invoke-RestMethod -Uri "$base/api/category/tree/goods"
Check 'public category tree code=0' ($r.code -eq 0)
Check 'public category tree has nodes' ($r.data.Count -gt 0)

# ---- goods list grounding tabs ----
$r = PostJson "$base/merchant/goods/list" $adminToken @{ page = 1; page_size = 10; grounding = 1 }
Check 'admin goods/list grounding=1' ($r.code -eq 0)
Write-Output ('[INFO] sale total=' + $r.data.total)

$r = PostJson "$base/merchant/goods/list" $adminToken @{ page = 1; page_size = 10; grounding = 0 }
Check 'admin goods/list grounding=0' ($r.code -eq 0)
Write-Output ('[INFO] warehouse total=' + $r.data.total)

# ---- create single-spec goods ----
$singleSpu = @{ name = '规格'; item = '["默认"]' }
$singleSku = @{ difference = '{"规格":"默认"}'; price = 19.9; market_price = 29.9; stock = 100; sn = '' }
$singleGoods = @{
    title = 'p3 test single-spec goods'; category_id = 1; brand_id = 0
    image = '/static/test.png'; images = '/static/test.png'
    description = 'single spec'; content = '<p>detail</p>'
    freight_id = 0; specs = 'single'; grounding = 0
    payment_type = 'wechat,alipay'; after_sale = '7day_return'
}
$r = PostJson "$base/merchant/goods/save" $adminToken @{ goods = $singleGoods; spus = @($singleSpu); skus = @($singleSku) }
Check 'goods/save single-spec returns id' ($r.code -eq 0 -and $r.data.id -gt 0)
$gid1 = $r.data.id

$r = Invoke-RestMethod -Uri "$base/merchant/goods/detail/$gid1" -Headers @{ Authorization = "Bearer $adminToken" }
Check 'goods/detail spus count=1' ($r.code -eq 0 -and $r.data.spus.Count -eq 1)
Check 'goods/detail skus count=1' ($r.data.skus.Count -eq 1)
Check 'goods/detail price=min sku' ([double]$r.data.goods.price -eq 19.9)

$r = PostJson "$base/merchant/goods/list" $adminToken @{ page = 1; page_size = 10; grounding = 0 }
$found = $false
foreach ($g in $r.data.data) { if ($g.id -eq $gid1) { $found = $true } }
Check 'new goods appears in warehouse list' $found

# ---- grounding switch ----
$r = PostJson "$base/merchant/goods/grounding" $adminToken @{ id = $gid1; grounding = 1 }
Check 'goods/grounding up code=0' ($r.code -eq 0)

$r = PostJson "$base/merchant/goods/list" $adminToken @{ page = 1; page_size = 10; grounding = 1 }
$found = $false
foreach ($g in $r.data.data) { if ($g.id -eq $gid1) { $found = $true } }
Check 'goods appears in sale list after grounding' $found

# ---- create multi-spec goods (2 groups x 2 values = 4 skus) ----
$multiSpu1 = @{ name = '颜色'; item = '["红","蓝"]' }
$multiSpu2 = @{ name = '尺码'; item = '["S","M"]' }
$mk1 = '{"颜色":"红","尺码":"S"}'
$mk2 = '{"颜色":"红","尺码":"M"}'
$mk3 = '{"颜色":"蓝","尺码":"S"}'
$mk4 = '{"颜色":"蓝","尺码":"M"}'
$sku1 = @{ difference = $mk1; price = 10.0; market_price = 12.0; stock = 10; sn = '' }
$sku2 = @{ difference = $mk2; price = 11.0; market_price = 13.0; stock = 20; sn = '' }
$sku3 = @{ difference = $mk3; price = 12.0; market_price = 14.0; stock = 30; sn = '' }
$sku4 = @{ difference = $mk4; price = 8.5; market_price = 9.0; stock = 40; sn = '' }
$multiGoods = @{
    title = 'p3 test multi-spec goods'; category_id = 1; brand_id = 0
    image = '/static/test.png'; images = '/static/test.png'
    description = 'multi spec'; content = ''
    freight_id = 0; specs = 'multi'; grounding = 0
    payment_type = 'wechat'; after_sale = '7day_return'
}
$r = PostJson "$base/merchant/goods/save" $adminToken @{ goods = $multiGoods; spus = @($multiSpu1, $multiSpu2); skus = @($sku1, $sku2, $sku3, $sku4) }
Check 'goods/save multi-spec returns id' ($r.code -eq 0 -and $r.data.id -gt 0)
$gid2 = $r.data.id

$r = Invoke-RestMethod -Uri "$base/merchant/goods/detail/$gid2" -Headers @{ Authorization = "Bearer $adminToken" }
Check 'multi-spec detail spus count=2' ($r.code -eq 0 -and $r.data.spus.Count -eq 2)
Check 'multi-spec detail skus count=4' ($r.data.skus.Count -eq 4)
Check 'multi-spec price=min(8.50)' ([double]$r.data.goods.price -eq 8.5)

# ---- update goods (title change) ----
$updGoods = $multiGoods
$updGoods.id = $gid2
$updGoods.title = 'p3 test multi-spec goods v2'
$r = PostJson "$base/merchant/goods/save" $adminToken @{ goods = $updGoods; spus = @($multiSpu1, $multiSpu2); skus = @($sku1, $sku2, $sku3, $sku4) }
Check 'goods/save update same id' ($r.code -eq 0)
$r = Invoke-RestMethod -Uri "$base/merchant/goods/detail/$gid2" -Headers @{ Authorization = "Bearer $adminToken" }
Check 'updated title persisted' ($r.data.goods.title -eq 'p3 test multi-spec goods v2')

# ---- delete both ----
$r = PostJson "$base/merchant/goods/delete" $adminToken @{ ids = @($gid1, $gid2) }
Check 'goods/delete code=0' ($r.code -eq 0)
$r = PostJson "$base/merchant/goods/list" $adminToken @{ page = 1; page_size = 100; grounding = 0 }
$left = 0
foreach ($g in $r.data.data) { if ($g.id -eq $gid1 -or $g.id -eq $gid2) { $left++ } }
Check 'deleted goods gone from list' ($left -eq 0)

# ---- kefu permission guard ----
$kefuToken = Login 'kefu'
Check 'kefu login' ($kefuToken -ne $null -and $kefuToken -ne '')
$r = PostJson "$base/merchant/goods/list" $kefuToken @{ page = 1; page_size = 10 }
Write-Output ('[INFO] kefu goods/list body code=' + $r.code)
Check 'kefu goods/list denied(403)' ($r.code -eq 403)

Write-Output ''
Write-Output "RESULT: pass=$pass fail=$fail"
