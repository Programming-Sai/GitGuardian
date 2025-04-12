# Load config from config.txt
# Load config.txt into a hashtable
$config = @{}
Get-Content ".\config.txt" | ForEach-Object {
    if ($_ -match "^\s*([^#][^=]+?)\s*=\s*(.+)$") {
        $key = $matches[1].Trim()
        $value = $matches[2].Trim()
        $config[$key] = $value
    }
}


$gitScript = $config["GIT_SCRIPT"]
$lockFile = $config["LOCK_FILE"]
$logFile = $config["LOG_FILE"]
$gitFolder = $config["GIT_FOLDER"]

# Ensure the git script exists
if (-not (Test-Path $gitScript)) {
    Add-Content $logFile "[ERROR] Script file '$gitScript' does not exist."
    exit 1
}

# Check for stale lock file
if (Test-Path $lockFile) {
    $lockTime = (Get-Item $lockFile).LastWriteTime
    $now = Get-Date
    $diff = $now - $lockTime

    Add-Content $logFile "Lock file found. Last modified: $lockTime. Now: $now. Age: $($diff.TotalMinutes) minutes."

    if ($diff.TotalMinutes -ge 60) {
        Add-Content $logFile "[WARNING] Stale lock file found. Proceeding anyway."
        Remove-Item $lockFile
    }
    else {
        Add-Content $logFile "Lock file is recent. Exiting..."
        exit
    }
}

# Create new lock file
Set-Content $lockFile "Lock file created at $(Get-Date)"

# Run git
# Run the git script with arguments
$commitMessage = "Auto commit from PowerShell"
$pushFlag = "push"  # Or "" if you don't want to push

Add-Content $logFile "Running Git script at $(Get-Date) with commit message: '$commitMessage' and push flag: '$pushFlag'"

Start-Process -FilePath $gitScript -ArgumentList "`"$commitMessage`"", $pushFlag -Wait -NoNewWindow

Add-Content $logFile "Git script finished at $(Get-Date)"
