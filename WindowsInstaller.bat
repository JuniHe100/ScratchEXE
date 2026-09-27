@echo off
setlocal EnableExtensions
title ScratchEXE 1.0 Installer

echo.
echo ============================================
echo          ScratchEXE 1.0 Installer
echo ============================================
echo.

set "URL=https://github.com/JuniHe100/ScratchEXE/releases/download/v1.0/Public.1.0.zip"
set "TEMPZIP=%TEMP%\ScratchEXE-Public-1.0.zip"
set "INSTALL=%LOCALAPPDATA%\ScratchEXE"

echo Downloading ScratchEXE 1.0...
echo.

powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Invoke-WebRequest -Uri '%URL%' -OutFile '%TEMPZIP%'"

if errorlevel 1 (
    echo.
    echo ERROR: Could not download ScratchEXE.
    echo Check your internet connection and try again.
    pause
    exit /b 1
)

echo Download complete.
echo.
echo Installing ScratchEXE...

if exist "%INSTALL%" rmdir /s /q "%INSTALL%"
mkdir "%INSTALL%"

powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Expand-Archive -LiteralPath '%TEMPZIP%' -DestinationPath '%INSTALL%' -Force"

if errorlevel 1 (
    echo.
    echo ERROR: Could not extract ScratchEXE.
    del "%TEMPZIP%" >nul 2>&1
    pause
    exit /b 1
)

del "%TEMPZIP%" >nul 2>&1

echo.
echo ============================================
echo       SCRATCHEXE 1.0 INSTALLED!
echo ============================================
echo.
echo Installed to:
echo %INSTALL%
echo.

if exist "%INSTALL%\ScratchEXE.exe" (
    echo Launching ScratchEXE...
    start "" "%INSTALL%\ScratchEXE.exe"
) else (
    echo WARNING: ScratchEXE.exe was not found.
    echo The ZIP may contain an extra folder level.
)

echo.
pause
