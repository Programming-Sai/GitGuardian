@echo off
setlocal enabledelayedexpansion

:: Check for commit message
if "%~1"=="" (
    echo No commit message provided.
    exit /b 1
)

:: Check if in a Git repository
if not exist ".git" (
    echo This is not a Git repository. Please navigate to one before running the script.
    exit /b 1
)

:: Create log file if not already set
if not defined LOG_FILE (
    set LOG_FILE=git_push.log
)

>> "%LOG_FILE%" echo ==== Script started at %date% %time% ====

:: Change to GIT_FOLDER if defined and exists
if defined GIT_FOLDER (
    if exist "%GIT_FOLDER%" (
        cd /d "%GIT_FOLDER%"
    )
)

:: After push or commit
git status >> "%LOG_FILE%"

:: Add and commit
git add .
git commit -m "%~1"

if errorlevel 1 (
    echo Commit failed. Possibly nothing to commit.
    exit /b 1
)

:: Check if "push" argument was passed
if /i "%~2"=="push" (
    git push
    if errorlevel 1 (
        echo Push failed. Please check your internet connection or remote config.
        exit /b 1
    )
    echo Changes have been committed and pushed successfully.
) else (
    echo Changes have been committed successfully. Not pushed.
)

>> "%LOG_FILE%" echo ==== Script ended at %date% %time% ====
endlocal