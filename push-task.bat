@echo off
setlocal

:: Define variables
set LOCK_FILE=git_push.lock
set LOG_FILE=git_push.log
set CONFIG_FILE=config.txt

:: Check if the lock file exists
if exist %LOCK_FILE% (
    echo Lock file exists. Exiting... >> %LOG_FILE%
    exit /b
)

:: Create lock file to prevent multiple instances
echo Lock file created. >> %LOG_FILE%
echo Locking at %date% %time% > %LOCK_FILE%

:: Call the actual push script
call git-push.bat %CONFIG_FILE%

:: Remove lock file after push
del %LOCK_FILE%
echo Lock file removed. >> %LOG_FILE%

endlocal
