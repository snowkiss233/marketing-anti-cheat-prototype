[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"
$taskName = "MarketingAntiCheatPrototypeSync"
$syncScript = Join-Path $PSScriptRoot "sync-prototype.ps1"
$powershell = "$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe"

if (-not (Test-Path -LiteralPath $syncScript)) {
    throw "Sync script not found: $syncScript"
}

$action = New-ScheduledTaskAction `
    -Execute $powershell `
    -Argument "-NoProfile -NonInteractive -ExecutionPolicy Bypass -File `"$syncScript`""

$trigger = New-ScheduledTaskTrigger `
    -Once `
    -At (Get-Date).AddMinutes(1) `
    -RepetitionInterval (New-TimeSpan -Minutes 5)

$settings = New-ScheduledTaskSettingsSet `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries `
    -StartWhenAvailable `
    -MultipleInstances IgnoreNew `
    -ExecutionTimeLimit (New-TimeSpan -Minutes 3)

Register-ScheduledTask `
    -TaskName $taskName `
    -Action $action `
    -Trigger $trigger `
    -Settings $settings `
    -Description "Automatically sync the marketing anti-cheat HTML prototype to GitHub." `
    -Force | Out-Null

Write-Output "Scheduled task '$taskName' has been installed."

