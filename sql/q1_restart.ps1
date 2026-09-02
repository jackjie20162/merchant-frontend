# q1 重启 zzhshopR2-rpc (9201)
$logFile = 'D:\go_work\simple-admin\merchant-frontend\sql\dbg_q1restart.txt'
'' | Out-File -Encoding utf8 $logFile
function Log($msg) { Add-Content -Path $logFile -Value $msg }

$conn2 = Get-NetTCPConnection -LocalPort 9201 -State Listen -ErrorAction SilentlyContinue | Select-Object -First 1
if ($conn2) { Stop-Process -Id $conn2.OwningProcess -Force -ErrorAction SilentlyContinue; Log ('stopped rpc pid=' + $conn2.OwningProcess) }
Start-Sleep -Seconds 2

Set-Location D:\go_work\simple-admin\zzhshopR2-rpc
$err = go build -o wss.exe . 2>&1
if ($LASTEXITCODE -ne 0) { Log 'rpc build FAILED'; $err | ForEach-Object { Log ([string]$_) }; exit 1 }
Log 'rpc build ok'

Start-Process -FilePath D:\go_work\simple-admin\zzhshopR2-rpc\wss.exe -ArgumentList '-f','D:\go_work\simple-admin\zzhshopR2-rpc\etc\wss.yaml' -WorkingDirectory D:\go_work\simple-admin\zzhshopR2-rpc -WindowStyle Hidden
Start-Sleep -Seconds 4

$c = Get-NetTCPConnection -LocalPort 9201 -State Listen -ErrorAction SilentlyContinue | Select-Object -First 1
if ($c) { Log ('listening port=9201 pid=' + $c.OwningProcess) } else { Log 'NOT listening port=9201' }
