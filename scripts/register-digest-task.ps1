$ErrorActionPreference = "Stop"

$taskName = "AI-Daily-Digest-9AM"
$scriptPath = "C:\Users\justike.liu\ai-daily-digest\scripts\run-digest-daily.ps1"

$action = New-ScheduledTaskAction `
  -Execute "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" `
  -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`""

$trigger = New-ScheduledTaskTrigger -Daily -At 9:00AM
$settings = New-ScheduledTaskSettingsSet -StartWhenAvailable

if (Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue) {
  Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
}

Register-ScheduledTask `
  -TaskName $taskName `
  -Action $action `
  -Trigger $trigger `
  -Settings $settings `
  -Description "Generate AI Daily Digest every day at 09:00"

Get-ScheduledTask -TaskName $taskName | Select-Object TaskName, State
