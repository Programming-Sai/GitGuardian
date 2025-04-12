param (
    [string]$Action = "start"
)

$config = @{ }
Get-Content "c:\Users\pc\Desktop\GitGuardian\config.txt" | ForEach-Object {
    $parts = $_ -split "=", 2
    $config[$parts[0].Trim()] = $parts[1].Trim()
}

$taskName = "GitAutoPushTask"
$scriptPath = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Definition) "main-runner.ps1"
Write-Host "Script path is: $scriptPath"

switch ($Action.ToLower()) {
    "start" {
        $trigger = New-ScheduledTaskTrigger -Daily -At $config["SCHEDULE_TIME"]
        
        # Fully specify the path for cmd.exe
        $cmdPath = "C:\Windows\System32\cmd.exe"
        $action = New-ScheduledTaskAction -Execute $cmdPath -Argument "/c `"$scriptPath`""
        
        # Check the type again to confirm it's MSFT_TaskExecAction
        $action.GetType().FullName
        


        Register-ScheduledTask -Action $action -Trigger $trigger -TaskName $taskName `
            -Description "Automatically pushes to GitHub daily." `
            -User "SYSTEM" -RunLevel Highest -Force


        Enable-ScheduledTask -TaskName $taskName
        Write-Output "[START] Task registered and enabled."
    }

    "stop" {
        Disable-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
        Write-Output "[STOP] Task disabled (but not removed)."
    }

    "status" {
        $task = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
        if ($null -eq $task) {
            Write-Output "[STATUS] Task not found."
        }
        else {
            $state = (Get-ScheduledTaskInfo -TaskName $taskName).State
            Write-Output "[STATUS] Task exists. Current state: $state"
        }
    }

    "uninstall" {
        Unregister-ScheduledTask -TaskName $taskName -Confirm:$false -ErrorAction SilentlyContinue
        Write-Output "[UNINSTALL] Task unregistered."
    }

    default {
        Write-Output "Invalid argument. Use one of: start, stop, status, uninstall"
    }
}
