@echo off
setlocal

:: Load config from the configuration file
for /f "delims=" %%i in (%1) do set "config=%%i"

:: Load repo path and branch from the config (assuming config.txt has lines like `repo_path=path` and `branch=main`)
for /f "tokens=1,2 delims==" %%a in ('findstr "repo_path=" %config%') do set "REPO_PATH=%%b"
for /f "tokens=1,2 delims==" %%a in ('findstr "branch=" %config%') do set "BRANCH=%%b"

:: If repo path and branch are not defined, exit
if not defined REPO_PATH (
    echo Repo path not defined in config. Exiting...
    exit /b
)

if not defined BRANCH (
    echo Branch not defined in config. Exiting...
    exit /b
)

:: Change directory to the repo
cd /d %REPO_PATH%

:: Handle commit and push
set COMMIT_MSG=%2
if not defined COMMIT_MSG (
    echo No commit message provided. Using default commit message. >> git_push.log
    set COMMIT_MSG="Automated commit"
)

:: Run Git commands
git add .
git commit -m %COMMIT_MSG%
git push origin %BRANCH%

:: Check if push was successful
if %ERRORLEVEL%==0 (
    echo Git push successful. >> git_push.log
) else (
    echo Git push failed. >> git_push.log
)

endlocal
