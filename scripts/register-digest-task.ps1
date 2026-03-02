[CmdletBinding()]
param(
  [string]$TaskName = "AI-Daily-Digest-9AM",
  [ValidatePattern('^\d{2}:\d{2}$')]
  [string]$DailyAt = "09:00"
)

$ErrorActionPreference = "Stop"

$scriptPath = Join-Path $PSScriptRoot "run-digest-daily.ps1"
if (-not (Test-Path $scriptPath)) {
  throw "run-digest-daily.ps1 not found: $scriptPath"
}

$repoRoot = Split-Path -Parent $PSScriptRoot
$timeOfDay = [TimeSpan]::ParseExact($DailyAt, 'hh\:mm', $null)
$triggerAt = [DateTime]::Today.Add($timeOfDay)

$powerShellExe = (Get-Command "powershell.exe" -ErrorAction SilentlyContinue).Source
if (-not $powerShellExe) {
  $powerShellExe = "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"
}

$action = New-ScheduledTaskAction `
  -Execute $powerShellExe `
  -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`"" `
  -WorkingDirectory $repoRoot

$trigger = New-ScheduledTaskTrigger -Daily -At $triggerAt
$settings = New-ScheduledTaskSettingsSet `
  -StartWhenAvailable `
  -AllowStartIfOnBatteries `
  -DontStopIfGoingOnBatteries

if (Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue) {
  Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
}

Register-ScheduledTask `
  -TaskName $TaskName `
  -Action $action `
  -Trigger $trigger `
  -Settings $settings `
  -Description "Generate AI Daily Digest every day at $DailyAt"

Get-ScheduledTask -TaskName $TaskName | Select-Object TaskName, State
