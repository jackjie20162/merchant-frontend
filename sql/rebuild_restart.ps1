# rebuild and restart wanshop-rpc (9201) and wanshop-api (9108)
$logFile = 'D:\go_work\simple-admin\store-console-frontend\sql\dbg_rebuild.txt'
'' | Out-File -Encoding utf8 $logFile

function Log($msg) { Write-Output $msg; Add-Content -Path $logFile -Value $msg }

# 1. stop old processes
$conn1 = Get-NetTCPConnection -LocalPort 9108 -State Listen -ErrorAction SilentlyContinue | Select-Object -First 1
$conn2 = Get-NetTCPConnection -LocalPort 9201 -State Listen -ErrorAction SilentlyContinue | Select-Object -First 1
if ($conn1) { Stop-Process -Id $conn1.OwningProcess -Force -ErrorAction SilentlyContinue; Log ('stopped api pid=' + $conn1.OwningProcess) }
if ($conn2) { Stop-Process -Id $conn2.OwningProcess -Force -ErrorAction SilentlyContinue; Log ('stopped rpc pid=' + $conn2.OwningProcess) }
Start-Sleep -Seconds 2

# 2. build rpc
Set-Location D:\go_work\simple-admin\wanshop-rpc
$err = go build -o wss.exe . 2>&1
if ($LASTEXITCODE -ne 0) { Log 'rpc build FAILED'; $err | ForEach-Object { Log ([string]$_) }; exit 1 }
Log 'rpc build ok'

# 3. build api
Set-Location D:\go_work\simple-admin\wanshop-api
$err = go build -o wanshopapi.exe . 2>&1
if ($LASTEXITCODE -ne 0) { Log 'api build FAILED'; $err | ForEach-Object { Log ([string]$_) }; exit 1 }
Log 'api build ok'

# 4. start rpc then api
Start-Process -FilePath D:\go_work\simple-admin\wanshop-rpc\wss.exe -ArgumentList '-f','D:\go_work\simple-admin\wanshop-rpc\etc\wss.yaml' -WorkingDirectory D:\go_work\simple-admin\wanshop-rpc -WindowStyle Hidden
Start-Sleep -Seconds 3
Start-Process -FilePath D:\go_work\simple-admin\wanshop-api\wanshopapi.exe -ArgumentList '-f','D:\go_work\simple-admin\wanshop-api\etc\wanshopapi.yaml' -WorkingDirectory D:\go_work\simple-admin\wanshop-api -WindowStyle Hidden
Start-Sleep -Seconds 5

# 5. verify listeners
foreach ($port in @(9108, 9201)) {
    $c = Get-NetTCPConnection -LocalPort $port -State Listen -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($c) { Log ('listening port=' + $port + ' pid=' + $c.OwningProcess) } else { Log ('NOT listening port=' + $port) }
}
