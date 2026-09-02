# q1 编译 zzhshopR2-rpc
Set-Location D:\go_work\simple-admin\zzhshopR2-rpc
$log = 'D:\go_work\simple-admin\merchant-frontend\sql\dbg_q1build.txt'
go build -o wss_rpc.exe wss.go 2>&1 | Out-File $log -Encoding utf8
"build exit: $LASTEXITCODE" | Out-File $log -Append -Encoding utf8
