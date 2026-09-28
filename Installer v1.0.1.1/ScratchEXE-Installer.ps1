$ErrorActionPreference = "Stop"

$DownloadURL = "https://github.com/JuniHe100/ScratchEXE/releases/download/v1.0.1/Public.v1.0.1.1.zip"
$InstallPath = Join-Path $env:LOCALAPPDATA "ScratchEXE"
$TempPath = Join-Path $env:TEMP "ScratchEXE-Installer"

Write-Host ""
Write-Host "==============================================" -ForegroundColor Cyan
Write-Host "          SCRATCHEXE INSTALLER" -ForegroundColor Cyan
Write-Host "==============================================" -ForegroundColor Cyan
Write-Host ""

try {

    Write-Host "[1/5] Downloading ScratchEXE..." -ForegroundColor Cyan

    Remove-Item $TempPath -Recurse -Force -ErrorAction SilentlyContinue
    New-Item -ItemType Directory -Force $TempPath | Out-Null
    New-Item -ItemType Directory -Force $InstallPath | Out-Null

    $ZipPath = Join-Path $TempPath "ScratchEXE.zip"

    Invoke-WebRequest `
        -Uri $DownloadURL `
        -OutFile $ZipPath

    if (!(Test-Path $ZipPath)) {
        throw "ScratchEXE download failed."
    }

    Write-Host "Download complete!" -ForegroundColor Green
    Write-Host ""

    Write-Host "[2/5] Installing ScratchEXE..." -ForegroundColor Cyan

    Expand-Archive `
        -LiteralPath $ZipPath `
        -DestinationPath $InstallPath `
        -Force

    Write-Host "ScratchEXE extracted!" -ForegroundColor Green
    Write-Host ""

    Write-Host "[3/5] Finding TurboWarp Packager..." -ForegroundColor Cyan

    # Find the packager folder anywhere inside the installation.
    $Packager = Get-ChildItem `
        -Path $InstallPath `
        -Directory `
        -Recurse `
        -ErrorAction SilentlyContinue |
        Where-Object {
            $_.Name -eq "packager" -and
            (Test-Path (Join-Path $_.FullName "package.json"))
        } |
        Select-Object -First 1

    if (!$Packager) {
        throw "TurboWarp Packager folder was not found anywhere in the installed files."
    }

    $PackagerPath = $Packager.FullName

    Write-Host "Found TurboWarp Packager:" -ForegroundColor Green
    Write-Host $PackagerPath -ForegroundColor Gray
    Write-Host ""

    Write-Host "[4/5] Checking dependencies..." -ForegroundColor Cyan

    $NodeModules = Join-Path $PackagerPath "node_modules"
    $PackageLock = Join-Path $PackagerPath "package-lock.json"
    $PackageJSON = Join-Path $PackagerPath "package.json"

    if (!(Test-Path $PackageJSON)) {
        throw "TurboWarp package.json was not found."
    }

    if (!(Test-Path $NodeModules)) {

        Write-Host "node_modules is missing." -ForegroundColor Yellow
        Write-Host "Installing TurboWarp dependencies..." -ForegroundColor Yellow
        Write-Host ""

        $Node = Get-Command node -ErrorAction SilentlyContinue
        $Npm = Get-Command npm -ErrorAction SilentlyContinue

        if (!$Node -or !$Npm) {
            throw "Node.js and npm are required. Install Node.js and run the installer again."
        }

        Push-Location $PackagerPath

        try {

            if (Test-Path $PackageLock) {
                Write-Host "Running npm ci..."
                npm ci
            }
            else {
                Write-Host "Running npm install..."
                npm install
            }

            if ($LASTEXITCODE -ne 0) {
                throw "npm failed to install node_modules."
            }

        }
        finally {
            Pop-Location
        }

        Write-Host ""
        Write-Host "node_modules installed!" -ForegroundColor Green

    }
    else {

        Write-Host "node_modules already exists." -ForegroundColor Green

    }

    Write-Host ""

    Write-Host "[5/5] Finding ScratchEXE.exe..." -ForegroundColor Cyan

    $Exe = Get-ChildItem `
        -Path $InstallPath `
        -Filter "ScratchEXE.exe" `
        -Recurse `
        -File `
        -ErrorAction SilentlyContinue |
        Select-Object -First 1

    if (!$Exe) {
        throw "ScratchEXE.exe was not found after installation."
    }

    Write-Host "Found:" -ForegroundColor Green
    Write-Host $Exe.FullName -ForegroundColor Gray
    Write-Host ""

    Write-Host "Starting ScratchEXE..." -ForegroundColor Cyan

    Start-Process `
        -FilePath $Exe.FullName `
        -WorkingDirectory $Exe.DirectoryName

    Write-Host ""
    Write-Host "==============================================" -ForegroundColor Green
    Write-Host "       SCRATCHEXE INSTALLED!" -ForegroundColor Green
    Write-Host "==============================================" -ForegroundColor Green
    Write-Host ""

}
catch {

    Write-Host ""
    Write-Host "==============================================" -ForegroundColor Red
    Write-Host "             INSTALLATION FAILED" -ForegroundColor Red
    Write-Host "==============================================" -ForegroundColor Red
    Write-Host ""
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host ""

    Read-Host "Press Enter to close"
    exit 1
}
