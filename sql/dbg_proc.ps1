# show listener processes with command lines for 9108/9201
foreach ($port in @(9108, 9201)) {
    $conn = Get-NetTCPConnection -LocalPort $port -State Listen -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($conn) {
        $proc = Get-CimInstance Win32_Process -Filter ('ProcessId=' + $conn.OwningProcess)
        Write-Output ('port=' + $port + ' pid=' + $conn.OwningProcess)
        Write-Output ('cmdline=' + $proc.CommandLine)
    } else {
        Write-Output ('port=' + $port + ' no listener')
    }
}
