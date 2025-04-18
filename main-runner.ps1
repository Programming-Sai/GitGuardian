# Load config from config.txt
# Load config.txt into a hashtable
$config = @{}
$configFilePath = Join-Path (Get-Location) 'config.txt'
Get-Content $configFilePath | ForEach-Object {
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

# Run git-push.bat with commit message and optional "push"
$commitMessage = "Auto commit at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
$pushFlag = "push"

# Set required env variables before calling the script
$env:GIT_FOLDER = $gitFolder
$env:LOG_FILE = $logFile

Set-Location $gitFolder
& $gitScript $commitMessage $pushFlag

# Clean up lock
Remove-Item $lockFile
