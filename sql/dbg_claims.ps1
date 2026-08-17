# decode jwt claims for kefu and admin
$base = 'http://127.0.0.1:9108'

function GetClaims($account) {
    $body = @{ account = $account; password = '123456' } | ConvertTo-Json
    $r = Invoke-RestMethod -Uri "$base/merchant/login" -Method Post -ContentType 'application/json' -Body $body
    $token = $r.data.token
    $parts = $token.Split('.')
    $p = $parts[1]
    $pad = $p.Length % 4
    if ($pad -gt 0) { $p = $p.PadRight($p.Length + (4 - $pad), '=') }
    $bytes = [Convert]::FromBase64String($p.Replace('-', '+').Replace('_', '/'))
    return [System.Text.Encoding]::UTF8.GetString($bytes)
}

Write-Output ('kefu claims: ' + (GetClaims 'kefu'))
Write-Output ('admin claims: ' + (GetClaims 'admin'))
