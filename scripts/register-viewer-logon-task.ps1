[CmdletBinding()]
param(
  [string]$TaskName = "AI-Digest-Viewer-OnLogon"
)

$ErrorActionPreference = "Stop"

$scriptPath = Join-Path $PSScriptRoot "start-digest-viewer.ps1"
if (-not (Test-Path $scriptPath)) {
  throw "start-digest-viewer.ps1 not found: $scriptPath"
}

$repoRoot = Split-Path -Parent $PSScriptRoot
$powerShellExe = (Get-Command "powershell.exe" -ErrorAction SilentlyContinue).Source
if (-not $powerShellExe) {
  $powerShellExe = "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"
}

$action = New-ScheduledTaskAction `
  -Execute $powerShellExe `
  -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`"" `
  -WorkingDirectory $repoRoot

$trigger = New-ScheduledTaskTrigger -AtLogOn
$settings = New-ScheduledTaskSettingsSet -StartWhenAvailable

if (Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue) {
  Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
}

Register-ScheduledTask `
  -TaskName $TaskName `
  -Action $action `
  -Trigger $trigger `
  -Settings $settings `
  -Description "Start AI Daily Digest viewer server at logon and open browser"

Get-ScheduledTask -TaskName $TaskName | Select-Object TaskName, State
