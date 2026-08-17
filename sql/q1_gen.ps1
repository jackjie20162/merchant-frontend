# q1 生成链：merge proto -> goctls rpc -> 去omitempty -> ent generate
Set-Location D:\go_work\simple-admin\wanshop-rpc
$log = 'D:\go_work\simple-admin\store-console-frontend\sql\dbg_q1gen.txt'

'=== merge proto ===' | Out-File $log -Encoding utf8
node merge_proto.mjs 2>&1 | Out-File $log -Append -Encoding utf8
"merge exit: $LASTEXITCODE" | Out-File $log -Append -Encoding utf8

'=== goctls rpc protoc ===' | Out-File $log -Append -Encoding utf8
goctls rpc protoc ./wss.proto --go_out=./types --go-grpc_out=./types --zrpc_out=. --style=go_zero 2>&1 | Out-File $log -Append -Encoding utf8
"goctls exit: $LASTEXITCODE" | Out-File $log -Append -Encoding utf8

'=== strip omitempty (UTF-8 safe) ===' | Out-File $log -Append -Encoding utf8
$utf8 = New-Object System.Text.UTF8Encoding($false)
$count = 0
Get-ChildItem .\types\wss\*.pb.go | ForEach-Object {
  $c = [System.IO.File]::ReadAllText($_.FullName)
  if ($c.Contains(',omitempty')) {
    [System.IO.File]::WriteAllText($_.FullName, $c.Replace(',omitempty', ''), $utf8)
    $count++
  }
}
"stripped files: $count" | Out-File $log -Append -Encoding utf8

'=== ent generate ===' | Out-File $log -Append -Encoding utf8
go run -mod=mod entgo.io/ent/cmd/ent generate --template glob="./ent/template/*.tmpl" ./ent/schema --feature sql/execquery 2>&1 | Out-File $log -Append -Encoding utf8
"entgen exit: $LASTEXITCODE" | Out-File $log -Append -Encoding utf8

'=== done ===' | Out-File $log -Append -Encoding utf8
