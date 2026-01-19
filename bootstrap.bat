@echo off
REM Bootstrap Script for Windows CMD
REM Dockerin - Remote Execution Script

setlocal enabledelayedexpansion

set GITHUB_REPO=irvandoda/dockerin
set GITHUB_BRANCH=%GITHUB_BRANCH%
if "%GITHUB_BRANCH%"=="" set GITHUB_BRANCH=main
set BASE_URL=https://raw.githubusercontent.com/%GITHUB_REPO%/%GITHUB_BRANCH%

set COMMAND=%1
if "%COMMAND%"=="" set COMMAND=menu

echo.
echo ========================================
echo Dockerin Bootstrap for Windows
echo ========================================
echo.

REM Check if bash is available (Git Bash or WSL)
where bash >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Bash is not found!
    echo.
    echo Please install one of the following:
    echo   1. Git Bash: https://git-scm.com/downloads
    echo   2. WSL: wsl --install
    echo.
    echo Or use PowerShell version:
    echo   powershell -ExecutionPolicy Bypass -File bootstrap.ps1 %COMMAND%
    echo.
    exit /b 1
)

echo Loading script from GitHub...
echo.

REM Execute using bash
if "%COMMAND%"=="menu" (
    bash -c "curl -s %BASE_URL%/bootstrap.sh menu | bash"
) else if "%COMMAND%"=="start" (
    bash -c "curl -s %BASE_URL%/bootstrap.sh menu | bash"
) else (
    bash -c "curl -s %BASE_URL%/bootstrap.sh %COMMAND% | bash"
)

exit /b %ERRORLEVEL%
