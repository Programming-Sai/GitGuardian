# GitGuardian

An automated tool to commit and push the contents of a specified folder to GitHub at scheduled intervals—leveraging PowerShell scripts, lockfiles, and WSL cron.

---

## Repository Structure

```text
GitGuardian/
├── .fttignore
├── .gitignore
├── config.txt                  # Defines script names, lockfile, log locations, and repo folder
├── git-push.bat                # Batch script: adds, commits, and pushes
├── main-runner.ps1             # PowerShell orchestration: lockfile & script invocation
└── README.md                   # Project documentation (this file)
```

---

## How It Works

1. **Load Configuration** (`config.txt`)

   - `GIT_SCRIPT`: name of the batch file (e.g., `git-push.bat`)
   - `LOCK_FILE`: filename for the lockfile to prevent overlapping runs
   - `LOG_FILE`: filename for appending commit logs
   - `GIT_FOLDER`: path to the local Git repository (use your own path)

2. **PowerShell Runner** (`main-runner.ps1`)

   - Reads key/value pairs from `config.txt`
   - Validates that the batch script exists in the project root
   - Checks for a stale lockfile (deletes if older than 60 minutes)
   - Creates a new lockfile, sets environment variables, and `cd` into `%GIT_FOLDER%`
   - Invokes the batch script to commit and push with a timestamped message
   - Removes the lockfile on completion

3. **Commit & Push** (`git-push.bat`)

   - Requires a commit message argument and a valid `.git` directory
   - Stages all changes, commits, and pushes to the remote branch
   - Outputs status and errors to the log file defined in `config.txt`

4. **Scheduling**

   - Define cron jobs in WSL to invoke the PowerShell script at desired times
   - **Example cron entries** (place under your own user with `crontab -e`):

     ```cron
     # Early morning (e.g., 2‑4 AM)
     0 2-4 * * * powershell.exe -ExecutionPolicy Bypass -File "<path-to>/main-runner.ps1" >> "<path-to>/git_push.log" 2>&1

     # Mid-afternoon (e.g., 3‑4 PM)
     0 15-16 * * * powershell.exe -ExecutionPolicy Bypass -File "<path-to>/main-runner.ps1" >> "<path-to>/git_push.log" 2>&1
     ```

   - Replace `<path-to>` with the absolute or relative path to your project folder

---

## Prerequisites

- **Windows 10/11** with **WSL (Ubuntu)** installed
- **Git** available on Windows (and optionally in WSL)
- **PowerShell** (built‑in to Windows)

---

## Manual Testing

Run the orchestration script directly to verify before scheduling:

```powershell
# Replace <path-to> with your project directory
powershell.exe -ExecutionPolicy Bypass -File "<path-to>\main-runner.ps1"
```

Check the log file for confirmation of commits and any errors.

---

## Customization

- **Scheduling**: adjust time fields in your crontab entries via `crontab -e`.
- **Configuration**: modify `config.txt` entries (script names, filenames, repo path).
- **Branching/Tags**: update `git-push.bat` to handle additional Git options if needed.

---

## License

MIT © Your Name or Organization
