$config = Get-Content "config.txt" | ForEach-Object {
    $parts = $_ -split "="
    @{ ($parts[0].Trim()) = $parts[1].Trim() }
} | ForEach-Object { $_ }

$taskName = "GitAutoPushTask"
$scriptPath = Join-Path $PSScriptRoot "main-runner.bat"
$trigger = New-ScheduledTaskTrigger -Daily -At $config["SCHEDULE_TIME"]
$action = New-ScheduledTaskAction -Execute $scriptPath

Register-ScheduledTask -Action $action -Trigger $trigger -TaskName $taskName `
    -Description "Automatically pushes to GitHub daily." `
    -User "$env:USERNAME" -RunLevel Highest
