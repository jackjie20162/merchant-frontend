# q1 恢复：用备份还原 internal/ 与 wss.go（保留新生成的 server 骨架/wssclient/types）
$ErrorActionPreference = 'Stop'
$root = 'D:\go_work\simple-admin\wanshop-rpc'
$bak = Join-Path $root 'q1_backup'
Remove-Item (Join-Path $root 'internal') -Recurse -Force
Copy-Item (Join-Path $bak 'internal') (Join-Path $root 'internal') -Recurse
Copy-Item (Join-Path $bak 'wss.go') (Join-Path $root 'wss.go') -Force
Copy-Item (Join-Path $bak 'go.mod') (Join-Path $root 'go.mod') -Force
Write-Output "restore done"
# 列出新生成的待实现 logic 目录
Get-ChildItem (Join-Path $root 'internal\logic\finance') -Name
Get-ChildItem (Join-Path $root 'internal\logic\shopsettings') -Name
Get-ChildItem (Join-Path $root 'internal\logic\withdraw') -Name
