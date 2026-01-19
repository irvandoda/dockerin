# Dockerin Installer for Windows PowerShell
# Alternative installer that works even if install.ps1 is not available

$ErrorActionPreference = "Stop"

# Colors
function Write-ColorOutput {
    param($ForegroundColor)
    $fc = $host.UI.RawUI.ForegroundColor
    $host.UI.RawUI.ForegroundColor = $ForegroundColor
    if ($args) {
        Write-Output $args
    }
    $host.UI.RawUI.ForegroundColor = $fc
}

Write-ColorOutput Cyan "╔════════════════════════════════════════════════════════════╗"
Write-ColorOutput Cyan "║              Dockerin Installation                       ║"
Write-ColorOutput Cyan "╚════════════════════════════════════════════════════════════╝"
Write-Output ""

# Configuration
$INSTALL_DIR = "$env:USERPROFILE\.dockerin"
$GITHUB_REPO = "irvandoda/dockerin"
$GITHUB_BRANCH = "main"
$BASE_URL = "https://raw.githubusercontent.com/$GITHUB_REPO/$GITHUB_BRANCH"

# Check for bash
if (-not (Get-Command bash -ErrorAction SilentlyContinue)) {
    Write-ColorOutput Red "Error: Bash is required to run Dockerin scripts."
    Write-ColorOutput Yellow "Please install one of the following:"
    Write-ColorOutput Yellow "  1. Git Bash: https://git-scm.com/downloads"
    Write-ColorOutput Yellow "  2. WSL: wsl --install"
    Write-Output ""
    Write-ColorOutput Yellow "After installing, restart PowerShell and run this installer again."
    exit 1
}

Write-ColorOutput Green "✓ Bash found"
Write-Output ""

# Create install directory
if (-not (Test-Path $INSTALL_DIR)) {
    New-Item -ItemType Directory -Path $INSTALL_DIR -Force | Out-Null
    Write-ColorOutput Green "✓ Created install directory: $INSTALL_DIR"
}

# Download install.sh and run it
Write-ColorOutput Blue "Downloading install.sh from GitHub..."
$installShUrl = "$BASE_URL/install.sh"
$tempFile = "$env:TEMP\dockerin-install.sh"

try {
    Invoke-WebRequest -Uri $installShUrl -OutFile $tempFile -UseBasicParsing
    Write-ColorOutput Green "✓ Downloaded install.sh"
    
    # Make executable and run
    Write-ColorOutput Blue "Running installer..."
    bash $tempFile
    
    if ($LASTEXITCODE -eq 0) {
        Write-ColorOutput Green "✓ Installation complete!"
    }
    else {
        Write-ColorOutput Red "Installation failed with exit code: $LASTEXITCODE"
        exit 1
    }
}
catch {
    Write-ColorOutput Red "Error downloading installer: $($_.Exception.Message)"
    Write-ColorOutput Yellow "Trying alternative method..."
    
    # Alternative: use curl if available
    if (Get-Command curl -ErrorAction SilentlyContinue) {
        Write-ColorOutput Blue "Using curl to download..."
        curl -s $installShUrl | bash
    }
    else {
        Write-ColorOutput Red "Failed to download installer. Please check your internet connection."
        exit 1
    }
}
finally {
    # Cleanup
    if (Test-Path $tempFile) {
        Remove-Item $tempFile -ErrorAction SilentlyContinue
    }
}

Write-Output ""
Write-ColorOutput Cyan "Next steps:"
Write-Output "  1. Restart PowerShell or run: . `$PROFILE"
Write-Output "  2. Run: dockerin start"
Write-Output ""
