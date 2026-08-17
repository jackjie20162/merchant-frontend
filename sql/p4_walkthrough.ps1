# p4 category/shop/brand/attachment interface-level walkthrough (ASCII comments only)
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

# ---- category lifecycle ----
$r = PostJson "$base/merchant/category/save" $adminToken @{ name = 'p4 top cat'; pid = 0; type = 'goods'; weigh = 9; isnav = 1; status = 'normal' }
Check 'category/save top returns id' ($r.code -eq 0 -and $r.data.id -gt 0)
$topId = $r.data.id

$r = PostJson "$base/merchant/category/save" $adminToken @{ name = 'p4 child cat'; pid = $topId; type = 'goods'; weigh = 8; isnav = 0; status = 'normal' }
Check 'category/save child returns id' ($r.code -eq 0 -and $r.data.id -gt 0)
$childId = $r.data.id

$r = PostJson "$base/merchant/category/tree" $adminToken @{ type = 'goods' }
Check 'category/tree code=0' ($r.code -eq 0)
$nodes = @($r.data)
$topNode = $null
foreach ($n in $nodes) { if ($n.id -eq $topId) { $topNode = $n } }
Check 'tree contains top node' ($topNode -ne $null)
$hasChild = $false
if ($topNode) { foreach ($c in @($topNode.children)) { if ($c.id -eq $childId) { $hasChild = $true } } }
Check 'top node has child' $hasChild

# rename child then verify
$r = PostJson "$base/merchant/category/save" $adminToken @{ id = $childId; name = 'p4 child cat v2'; pid = $topId; type = 'goods'; weigh = 8; isnav = 0; status = 'normal' }
Check 'category/save update code=0' ($r.code -eq 0)
$r = PostJson "$base/merchant/category/tree" $adminToken @{ type = 'goods' }
$renamed = $false
foreach ($n in @($r.data)) {
    if ($n.id -eq $topId) {
        foreach ($c in @($n.children)) { if ($c.id -eq $childId -and $c.name -eq 'p4 child cat v2') { $renamed = $true } }
    }
}
Check 'child renamed in tree' $renamed

# delete child then top
$r = PostJson "$base/merchant/category/delete" $adminToken @{ ids = @($childId) }
Check 'category/delete child code=0' ($r.code -eq 0)
$r = PostJson "$base/merchant/category/delete" $adminToken @{ ids = @($topId) }
Check 'category/delete top code=0' ($r.code -eq 0)
$r = PostJson "$base/merchant/category/tree" $adminToken @{ type = 'goods' }
$left = 0
foreach ($n in @($r.data)) { if ($n.id -eq $topId) { $left++ } }
Check 'deleted category gone from tree' ($left -eq 0)

# ---- shop info ----
$si = Invoke-RestMethod -Uri "$base/merchant/shop/info" -Headers @{ Authorization = "Bearer $adminToken" }
Check 'shop/info code=0' ($si.code -eq 0)
Check 'shop/info has shopname' ($si.data.shopname -ne $null -and $si.data.shopname -ne '')
$shopId = $si.data.id
$origBio = "$($si.data.bio)"

$r = PostJson "$base/merchant/shop/save" $adminToken @{ id = $shopId; bio = 'p4 bio marker' }
Check 'shop/save code=0' ($r.code -eq 0)
$si = Invoke-RestMethod -Uri "$base/merchant/shop/info" -Headers @{ Authorization = "Bearer $adminToken" }
Check 'shop bio persisted' ($si.data.bio -eq 'p4 bio marker')
# restore original bio
$r = PostJson "$base/merchant/shop/save" $adminToken @{ id = $shopId; bio = $origBio }
Check 'shop/save restore code=0' ($r.code -eq 0)

# ---- brand lifecycle ----
$r = PostJson "$base/merchant/brand/save" $adminToken @{ name = 'p4 brand'; image = ''; content = 'p4 brand content'; weigh = 1; is_switch = 1 }
Check 'brand/save returns id' ($r.code -eq 0 -and $r.data.id -gt 0)
$brandId = $r.data.id

$r = PostJson "$base/merchant/brand/list" $adminToken @{ page = 1; page_size = 50 }
Check 'brand/list code=0' ($r.code -eq 0)
$found = $false
foreach ($b in @($r.data.data)) { if ($b.id -eq $brandId) { $found = $true } }
Check 'new brand in list' $found

$r = PostJson "$base/merchant/brand/save" $adminToken @{ id = $brandId; name = 'p4 brand v2'; image = ''; content = 'p4 brand content'; weigh = 1; is_switch = 0 }
Check 'brand/save update code=0' ($r.code -eq 0)
$r = PostJson "$base/merchant/brand/list" $adminToken @{ page = 1; page_size = 50; name = 'p4 brand' }
$renamed = $false
foreach ($b in @($r.data.data)) { if ($b.id -eq $brandId -and $b.name -eq 'p4 brand v2') { $renamed = $true } }
Check 'brand renamed and name filter works' $renamed

$r = PostJson "$base/merchant/brand/delete" $adminToken @{ ids = @($brandId) }
Check 'brand/delete code=0' ($r.code -eq 0)
$r = PostJson "$base/merchant/brand/list" $adminToken @{ page = 1; page_size = 50 }
$left = 0
foreach ($b in @($r.data.data)) { if ($b.id -eq $brandId) { $left++ } }
Check 'deleted brand gone from list' ($left -eq 0)

# ---- attachment lifecycle (upload -> list -> static -> delete) ----
$pngBytes = [byte[]](0x89,0x50,0x4E,0x47,0x0D,0x0A,0x1A,0x0A,0x00,0x00,0x00,0x0D,0x49,0x48,0x44,0x52,0x00,0x00,0x00,0x01,0x00,0x00,0x00,0x01,0x08,0x06,0x00,0x00,0x00,0x1F,0x15,0xC4,0x89,0x00,0x00,0x00,0x0D,0x49,0x44,0x41,0x54,0x78,0x9C,0x62,0x00,0x01,0x00,0x00,0x05,0x00,0x01,0x0D,0x0A,0x2D,0xB4,0x00,0x00,0x00,0x00,0x49,0x45,0x4E,0x44,0xAE,0x42,0x60,0x82)
$pngPath = "$env:TEMP\p4_test.png"
[System.IO.File]::WriteAllBytes($pngPath, $pngBytes)
$up = & curl.exe -s -X POST "$base/merchant/attachment/upload" -H "Authorization: Bearer $adminToken" -F "file=@$pngPath;type=image/png"
$upObj = $up | ConvertFrom-Json
Check 'attachment/upload returns id+url' ($upObj.code -eq 0 -and $upObj.data.id -gt 0 -and $upObj.data.url -ne '')
$attId = $upObj.data.id
$attUrl = $upObj.data.url

$r = PostJson "$base/merchant/attachment/list" $adminToken @{ page = 1; page_size = 50 }
Check 'attachment/list code=0' ($r.code -eq 0)
$found = $false
foreach ($a in @($r.data.data)) { if ($a.id -eq $attId) { $found = $true } }
Check 'uploaded attachment in list' $found

$code = & curl.exe -s -o NUL -w "%{http_code}" ($base + $attUrl)
Check 'static GET 200' ($code -eq '200')

$r = PostJson "$base/merchant/attachment/delete" $adminToken @{ ids = @($attId) }
Check 'attachment/delete code=0' ($r.code -eq 0)
$r = PostJson "$base/merchant/attachment/list" $adminToken @{ page = 1; page_size = 50 }
$left = 0
foreach ($a in @($r.data.data)) { if ($a.id -eq $attId) { $left++ } }
Check 'deleted attachment gone from list' ($left -eq 0)

# ---- kefu permission guard (kefu has no p4 perms) ----
$kefuToken = Login 'kefu'
Check 'kefu login' ($kefuToken -ne $null -and $kefuToken -ne '')

$r = PostJson "$base/merchant/category/tree" $kefuToken @{ type = 'goods' }
Write-Output ('[INFO] kefu category/tree body code=' + $r.code)
Check 'kefu category/tree denied(403)' ($r.code -eq 403)

$r = PostJson "$base/merchant/brand/list" $kefuToken @{ page = 1; page_size = 10 }
Check 'kefu brand/list denied(403)' ($r.code -eq 403)

$r = PostJson "$base/merchant/attachment/list" $kefuToken @{ page = 1; page_size = 10 }
Check 'kefu attachment/list denied(403)' ($r.code -eq 403)

# shop/info is login-only (no perm code), kefu should pass
$si = Invoke-RestMethod -Uri "$base/merchant/shop/info" -Headers @{ Authorization = "Bearer $kefuToken" }
Check 'kefu shop/info allowed(login-only)' ($si.code -eq 0)

Write-Output ''
Write-Output "RESULT: pass=$pass fail=$fail"
