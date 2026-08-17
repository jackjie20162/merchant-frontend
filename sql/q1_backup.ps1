# q1 备份：重生成前备份 internal/ 与 wss.go（goctls 会覆盖 logic/server）
$ErrorActionPreference = 'Stop'
$root = 'D:\go_work\simple-admin\wanshop-rpc'
$bak = Join-Path $root 'q1_backup'
if (Test-Path $bak) { Remove-Item $bak -Recurse -Force }
New-Item -ItemType Directory -Path $bak | Out-Null
Copy-Item (Join-Path $root 'internal') (Join-Path $bak 'internal') -Recurse
Copy-Item (Join-Path $root 'wss.go') (Join-Path $bak 'wss.go')
Copy-Item (Join-Path $root 'go.mod') (Join-Path $bak 'go.mod')
Write-Output "backup done -> $bak"
