$ErrorActionPreference = "Stop"

$taskName = "AI-Digest-Viewer-OnLogon"
$scriptPath = "C:\Users\justike.liu\ai-daily-digest\scripts\start-digest-viewer.ps1"

$action = New-ScheduledTaskAction `
  -Execute "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" `
  -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`""

$trigger = New-ScheduledTaskTrigger -AtLogOn
$settings = New-ScheduledTaskSettingsSet -StartWhenAvailable

if (Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue) {
  Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
}

Register-ScheduledTask `
  -TaskName $taskName `
  -Action $action `
  -Trigger $trigger `
  -Settings $settings `
  -Description "Start AI Daily Digest viewer server at logon and open browser"

Get-ScheduledTask -TaskName $taskName | Select-Object TaskName, State
