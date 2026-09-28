@echo off
title Node.js Installer
echo.
echo ==============================================
echo          NODE.JS INSTALLER
echo ==============================================
echo.
echo This will download the official Node.js
echo Windows installer.
echo.
echo Opening Node.js installer...
echo.

powershell.exe -NoProfile -Command "Invoke-WebRequest -Uri 'https://nodejs.org/dist/v22.23.3/node-v22.23.3-x64.msi' -OutFile '$env:TEMP\nodejs-installer.msi'"

if not exist "%TEMP%\nodejs-installer.msi" (
    echo.
    echo ERROR: Node.js installer could not be downloaded.
    pause
    exit /b 1
)

echo.
echo Starting the official Node.js installer...
echo.

start /wait "" "%TEMP%\nodejs-installer.msi"

echo.
echo ==============================================
echo Node.js installation finished.
echo ==============================================
echo.
echo Close and reopen PowerShell or Command Prompt
echo before running ScratchEXE again.
echo.

pause
