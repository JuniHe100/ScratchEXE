@echo off
setlocal EnableExtensions

title ScratchEXE Installer

echo.
echo ==============================================
echo          SCRATCHEXE INSTALLER
echo          Latest GitHub Release
echo ==============================================
echo.

powershell.exe -NoProfile -ExecutionPolicy Bypass -Command ^
"$ErrorActionPreference='Stop'; ^
$Repo='JuniHe100/ScratchEXE'; ^
$Install=Join-Path $env:LOCALAPPDATA 'ScratchEXE'; ^
$Temp=Join-Path $env:TEMP 'ScratchEXE-Installer'; ^
$Api='https://api.github.com/repos/'+$Repo+'/releases/latest'; ^
$Headers=@{'Accept'='application/vnd.github+json';'User-Agent'='ScratchEXE-Installer'}; ^
Write-Host '[1/5] Checking GitHub for latest release...'; ^
$Release=Invoke-RestMethod -Uri $Api -Headers $Headers; ^
if(!$Release){throw 'Could not find the latest GitHub release.'}; ^
$Asset=$Release.assets | Where-Object {$*.name -like '*.zip'} | Select-Object -First 1; ^
if(!$Asset){throw 'No ZIP release asset was found.'}; ^
Write-Host ('Latest release: '+$Release.tag_name); ^
Write-Host ('Asset: '+$Asset.name); ^
Write-Host ''; ^
Write-Host '[2/5] Downloading release...'; ^
New-Item -ItemType Directory -Force -Path $Install,$Temp | Out-Null; ^
$Zip=Join-Path $Temp $Asset.name; ^
Remove-Item $Zip -Force -ErrorAction SilentlyContinue; ^
Invoke-WebRequest -Uri $Asset.browser_download_url -OutFile $Zip -Headers @{'User-Agent'='ScratchEXE-Installer'} -UseBasicParsing; ^
if(!(Test-Path $Zip)){throw 'Release download failed.'}; ^
Write-Host '[3/5] Installing ScratchEXE files...'; ^
Expand-Archive -LiteralPath $Zip -DestinationPath $Install -Force; ^
$Packager=Get-ChildItem -LiteralPath $Install -Directory -Recurse -ErrorAction SilentlyContinue | Where-Object {$*.FullName -like '*Runtime\Source\packager'} | Select-Object -First 1; ^
if(!$Packager){throw 'TurboWarp packager folder was not found.'}; ^
$NodeModules=Join-Path $Packager.FullName 'node_modules'; ^
$PackageJson=Join-Path $Packager.FullName 'package.json'; ^
$PackageLock=Join-Path $Packager.FullName 'package-lock.json'; ^
Write-Host ''; ^
Write-Host '[4/5] Checking required files...'; ^
if(!(Test-Path $NodeModules)){ ^
Write-Host 'node_modules is missing. Installing dependencies...'; ^
if(!(Get-Command node -ErrorAction SilentlyContinue)){ ^
throw 'Node.js is required to install ScratchEXE dependencies. Please install Node.js and run the installer again.' ^
}; ^
if(!(Get-Command npm -ErrorAction SilentlyContinue)){ ^
throw 'npm is required to install ScratchEXE dependencies.' ^
}; ^
if(!(Test-Path $PackageJson)){throw 'package.json is missing from the release.'}; ^
Push-Location $Packager.FullName; ^
try { ^
if(Test-Path $PackageLock){ ^
npm ci; ^
} else { ^
npm install; ^
}; ^
if($LASTEXITCODE -ne 0){throw 'npm failed to install ScratchEXE dependencies.'} ^
} finally { ^
Pop-Location ^
} ^
} else { ^
Write-Host 'node_modules found. Skipping dependency installation.' -ForegroundColor Green ^
}; ^
Write-Host ''; ^
Write-Host '[5/5] Finding ScratchEXE...'; ^
$Exe=Get-ChildItem -LiteralPath $Install -Filter 'ScratchEXE.exe' -Recurse -File | Select-Object -First 1; ^
if(!$Exe){throw 'ScratchEXE.exe was not found in the release.'}; ^
Write-Host ''; ^
Write-Host '==============================================' -ForegroundColor Green; ^
Write-Host '       SCRATCHEXE INSTALLED SUCCESSFULLY' -ForegroundColor Green; ^
Write-Host '==============================================' -ForegroundColor Green; ^
Write-Host ''; ^
Write-Host ('Version: '+$Release.tag_name); ^
Write-Host ('Location: '+$Exe.FullName); ^
Write-Host ''; ^
Start-Process -FilePath $Exe.FullName -WorkingDirectory $Exe.DirectoryName; ^
exit 0"

if %ERRORLEVEL% NEQ 0 (
echo.
echo ==============================================
echo             INSTALLER FAILED
echo ==============================================
echo.
echo See the message above for the problem.
echo.
pause
exit /b 1
)

echo.
echo ScratchEXE is ready!
echo.
timeout /t 2 /nobreak >nul
exit /b 0
