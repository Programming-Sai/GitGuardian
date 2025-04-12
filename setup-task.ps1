$taskName = "GitAutoPushTask"
$scriptPath = "C:\Path\To\your\main-runner.bat"
$trigger = New-ScheduledTaskTrigger -Daily -At 12am
$action = New-ScheduledTaskAction -Execute $scriptPath
Register-ScheduledTask -Action $action -Trigger $trigger -TaskName $taskName -Description "Automatically pushes to GitHub daily." -User "$env:USERNAME" -RunLevel Highest
