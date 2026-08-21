@echo off
set target=%1

if "%target%"=="" (
    echo Usage: env_switch.bat [local|production]
    exit /b 1
)

if not exist ".env.%target%" (
    echo Error: .env.%target% does not exist!
    exit /b 1
)

echo Switching environment to %target%...
copy /Y ".env.%target%" ".env" > nul

echo Clearing caches...
call php artisan optimize:clear

if "%target%"=="production" (
    echo Caching for production...
    call php artisan config:cache
    call php artisan route:cache
    call php artisan view:cache
)

echo Done! Environment switched to %target%.
