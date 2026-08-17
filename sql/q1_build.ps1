# q1 编译 wanshop-rpc
Set-Location D:\go_work\simple-admin\wanshop-rpc
$log = 'D:\go_work\simple-admin\store-console-frontend\sql\dbg_q1build.txt'
go build -o wss_rpc.exe wss.go 2>&1 | Out-File $log -Encoding utf8
"build exit: $LASTEXITCODE" | Out-File $log -Append -Encoding utf8
