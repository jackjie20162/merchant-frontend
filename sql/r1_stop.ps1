# stop zzhshopR2 services on 9108/9201 before rename
foreach ($port in @(9108, 9201)) {
    $c = Get-NetTCPConnection -LocalPort $port -State Listen -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($c) {
        Stop-Process -Id $c.OwningProcess -Force -ErrorAction SilentlyContinue
        Write-Output ('stopped port=' + $port + ' pid=' + $c.OwningProcess)
    } else {
        Write-Output ('no listener port=' + $port)
    }
}
Start-Sleep -Seconds 2
Write-Output 'STOP-DONE'
