# find process listening on 9108
$conn = Get-NetTCPConnection -LocalPort 9108 -State Listen -ErrorAction SilentlyContinue | Select-Object -First 1
if ($conn) {
    $proc = Get-Process -Id $conn.OwningProcess -ErrorAction SilentlyContinue
    Write-Output ('pid=' + $conn.OwningProcess + ' name=' + $proc.ProcessName + ' started=' + $proc.StartTime)
    Write-Output ('path=' + $proc.Path)
} else {
    Write-Output 'no listener on 9108'
}
