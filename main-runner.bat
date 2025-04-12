@echo off
setlocal

:: Load config
for /f "tokens=1,2 delims==" %%A in (config.txt) do (
    set %%A=%%B
)

:: Validate config
if not defined GIT_SCRIPT (
    echo [ERROR] GIT_SCRIPT not set in config.txt >> %LOG_FILE%
    exit /b 1
)

if not exist "%GIT_SCRIPT%" (
    echo [ERROR] Script file "%GIT_SCRIPT%" does not exist. >> %LOG_FILE%
    exit /b 1
)


:: Check for stale lock file
if exist %LOCK_FILE% (
    for %%F in (%LOCK_FILE%) do (
        set FILE_TIME=%%~tF
    )

    :: Get current and file modified times in epoch
    for /f "tokens=1-4 delims=/: " %%a in ("%FILE_TIME%") do (
        set LOCK_HOUR=%%c
        set LOCK_MIN=%%d
    )

    for /f "tokens=1-4 delims=/: " %%a in ("%time%") do (
        set NOW_HOUR=%%a
        set NOW_MIN=%%b
    )

    set /a LOCK_TOTAL_MIN=(1%LOCK_HOUR% - 100)*60 + 1%LOCK_MIN% - 100
    set /a NOW_TOTAL_MIN=(1%NOW_HOUR% - 100)*60 + 1%NOW_MIN% - 100

    set /a DIFF=%NOW_TOTAL_MIN% - %LOCK_TOTAL_MIN%

    if %DIFF% GEQ 60 (
        echo [WARNING] Stale lock file found. Proceeding anyway. >> %LOG_FILE%
        del %LOCK_FILE%
    ) else (
        echo Lock file exists and is recent. Exiting... >> %LOG_FILE%
        exit /b
    )
)


:: Create lock file to prevent multiple instances
echo Lock file created. >> %LOG_FILE%
echo Locking at %date% %time% > %LOCK_FILE%

:: Call the actual push script (passes optional "push" arg)
call %GIT_SCRIPT% "Auto push at %date% %time%" push >> %LOG_FILE% 2>&1

if errorlevel 1 (
    echo [ERROR] git script exited with an error at %date% %time% >> %LOG_FILE%
)

:: Remove lock file after push
del %LOCK_FILE%
echo Lock file removed. >> %LOG_FILE%

endlocal
