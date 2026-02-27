$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$serverPath = Join-Path $repoRoot "viewer\server.ts"
$url = "http://localhost:8787"

$running = Get-CimInstance Win32_Process |
  Where-Object { $_.CommandLine -match "viewer[\\/]+server\.ts" -and $_.Name -match "powershell|pwsh|bun" } |
  Select-Object -First 1

if (-not $running) {
  Start-Process `
    -FilePath "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" `
    -WorkingDirectory $repoRoot `
    -WindowStyle Minimized `
    -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"bun `"$serverPath`"`""
  Start-Sleep -Seconds 2
}

Start-Process $url
