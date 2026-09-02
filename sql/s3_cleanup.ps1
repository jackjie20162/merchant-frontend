# s3: cleanup leftover store-console-frontend shell dir
$root = 'D:\go_work\simple-admin'
$oldDir = Join-Path $root 'store-console-frontend'
$newDir = Join-Path $root 'merchant-frontend'

if (-not (Test-Path $oldDir)) { Write-Output 'OLD-ALREADY-GONE' }
else {
    # what is left inside?
    $leftFiles = Get-ChildItem $oldDir -Recurse -File -Force -ErrorAction SilentlyContinue
    $leftDirs = Get-ChildItem $oldDir -Recurse -Directory -Force -ErrorAction SilentlyContinue
    Write-Output ('left files=' + $leftFiles.Count + ' dirs=' + $leftDirs.Count)
    $leftFiles | Select-Object -First 20 | ForEach-Object { Write-Output ('  F: ' + $_.FullName.Substring($root.Length)) }
    $leftDirs | Select-Object -First 20 | ForEach-Object { Write-Output ('  D: ' + $_.FullName.Substring($root.Length)) }

    # any node/other process still referencing old dir
    Get-CimInstance Win32_Process | Where-Object { $_.CommandLine -and $_.CommandLine -match 'store-console-frontend' -and $_.Name -ne 'powershell.exe' } | ForEach-Object {
        Write-Output ('HOLD pid=' + $_.ProcessId + ' name=' + $_.Name)
        if ($_.Name -eq 'node.exe') { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue; Write-Output ('killed ' + $_.ProcessId) }
    }
    Start-Sleep -Seconds 3

    # try remove
    $done = $false
    for ($i = 1; $i -le 6; $i++) {
        try {
            Remove-Item -LiteralPath $oldDir -Recurse -Force -ErrorAction Stop
            Write-Output 'OLD-REMOVED'
            $done = $true
            break
        } catch {
            Write-Output ('DEL-RETRY' + $i + ' FAIL: ' + $_.Exception.Message)
            Start-Sleep -Seconds 3
        }
    }
    if (-not $done) { Write-Output 'OLD-STILL-LOCKED' }
}

# verify new dir completeness + no leftovers
Write-Output ('newDir exists: ' + (Test-Path $newDir))
Write-Output ('oldDir exists: ' + (Test-Path $oldDir))
$gitOk = Test-Path (Join-Path $newDir '.git')
Write-Output ('.git moved: ' + $gitOk)
Write-Output 'S3-DONE'
