# Dockerin Installer for Windows PowerShell
# Install dockerin locally for easy access

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

# Configuration
$INSTALL_DIR = "$env:USERPROFILE\.dockerin"
$GITHUB_REPO = "irvandoda/dockerin"
$GITHUB_BRANCH = if ($env:GITHUB_BRANCH) { $env:GITHUB_BRANCH } else { "main" }
$BASE_URL = "https://raw.githubusercontent.com/$GITHUB_REPO/$GITHUB_BRANCH"

# Print header
function Print-Header {
    Write-ColorOutput Cyan "╔════════════════════════════════════════════════════════════╗"
    Write-ColorOutput Cyan "║              Dockerin Installation                       ║"
    Write-ColorOutput Cyan "╚════════════════════════════════════════════════════════════╝"
    Write-Output ""
}

# Check prerequisites
function Test-Prerequisites {
    $missing = @()
    
    if (-not (Get-Command curl -ErrorAction SilentlyContinue) -and 
        -not (Get-Command wget -ErrorAction SilentlyContinue) -and
        -not (Get-Command Invoke-WebRequest -ErrorAction SilentlyContinue)) {
        $missing += "curl, wget, or Invoke-WebRequest"
    }
    
    if (-not (Get-Command bash -ErrorAction SilentlyContinue)) {
        Write-ColorOutput Yellow "Warning: Bash not found. Git Bash or WSL is recommended for best experience."
        Write-ColorOutput Yellow "You can install Git Bash from: https://git-scm.com/downloads"
        Write-Output ""
    }
    
    if ($missing.Count -gt 0) {
        Write-ColorOutput Red "Error: Missing prerequisites: $($missing -join ', ')"
        return $false
    }
    
    return $true
}

# Download file from GitHub
function Get-FileFromGitHub {
    param(
        [string]$FilePath,
        [string]$OutputPath
    )
    
    $fileUrl = "$BASE_URL/$FilePath"
    Write-ColorOutput Blue "Downloading $FilePath..."
    
    try {
        $webClient = New-Object System.Net.WebClient
        $webClient.DownloadFile($fileUrl, $OutputPath)
        Write-ColorOutput Green "✓ Downloaded $FilePath"
        return $true
    }
    catch {
        Write-ColorOutput Red "Error downloading $FilePath`: $($_.Exception.Message)"
        return $false
    }
    finally {
        if ($webClient) {
            $webClient.Dispose()
        }
    }
}

# Install dockerin
function Install-Dockerin {
    Write-ColorOutput Cyan "Installing Dockerin..."
    
    # Create install directory
    if (-not (Test-Path $INSTALL_DIR)) {
        New-Item -ItemType Directory -Path $INSTALL_DIR -Force | Out-Null
    }
    
    # List of files to download
    $files = @(
        "menu.sh",
        "bootstrap.sh",
        "tutorial.sh",
        "dev-tools.sh",
        "database-tools.sh",
        "start.sh",
        "generators/laravel-compose.sh",
        "utils/port-manager.sh",
        "utils/env-manager.sh",
        "utils/remote-loader.sh",
        "templates/nginx-laravel.conf",
        "templates/xdebug-config.ini",
        "templates/queue-worker.yml",
        "templates/mail-catcher.yml"
    )
    
    # Download files
    foreach ($file in $files) {
        $dirPath = Split-Path $file -Parent
        $fileName = Split-Path $file -Leaf
        
        if ($dirPath -and $dirPath -ne ".") {
            $targetDir = Join-Path $INSTALL_DIR $dirPath
            if (-not (Test-Path $targetDir)) {
                New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
            }
            $outputPath = Join-Path $targetDir $fileName
        }
        else {
            $outputPath = Join-Path $INSTALL_DIR $fileName
        }
        
        if (-not (Get-FileFromGitHub -FilePath $file -OutputPath $outputPath)) {
            Write-ColorOutput Red "Failed to download $file"
            return $false
        }
    }
    
    Write-ColorOutput Green "✓ Files downloaded"
    return $true
}

# Setup PATH and aliases
function Set-PathAndAliases {
    $profilePath = $PROFILE
    
    # Create profile if it doesn't exist
    if (-not (Test-Path $profilePath)) {
        $profileDir = Split-Path $profilePath -Parent
        if (-not (Test-Path $profileDir)) {
            New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
        }
        New-Item -ItemType File -Path $profilePath -Force | Out-Null
    }
    
    # Check if alias already exists
    $profileContent = Get-Content $profilePath -Raw -ErrorAction SilentlyContinue
    if ($profileContent -and $profileContent -match "function dockerin") {
        Write-ColorOutput Yellow "Alias already exists in PowerShell profile"
        return
    }
    
    # Add alias function
    $aliasFunc = @"

# Dockerin alias
function dockerin {
    param([string]`$Command = "menu", [string[]]`$Args)
    
    if (Test-Path "$INSTALL_DIR\menu.sh") {
        switch (`$Command) {
            { `$_ -in "start", "menu" } {
                bash "$INSTALL_DIR\menu.sh" `$Args
            }
            "dev-tools" {
                bash "$INSTALL_DIR\dev-tools.sh" `$Args
            }
            "tutorial" {
                bash "$INSTALL_DIR\tutorial.sh" `$Args
            }
            "db-tools" {
                bash "$INSTALL_DIR\database-tools.sh" `$Args
            }
            "update" {
                Invoke-WebRequest -Uri "https://raw.githubusercontent.com/$GITHUB_REPO/main/install.ps1" -OutFile "$env:TEMP\dockerin-install.ps1"
                & "$env:TEMP\dockerin-install.ps1"
            }
            default {
                bash "$INSTALL_DIR\menu.sh" `$Command `$Args
            }
        }
    }
    else {
        Write-Host "Dockerin not found. Please reinstall." -ForegroundColor Red
    }
}
"@
    
    # Add to profile
    Add-Content -Path $profilePath -Value $aliasFunc
    Write-ColorOutput Green "✓ Added dockerin alias to PowerShell profile"
    Write-ColorOutput Yellow "Profile location: $profilePath"
}

# Main installation
function Main {
    Print-Header
    
    # Check prerequisites
    if (-not (Test-Prerequisites)) {
        exit 1
    }
    
    # Check for bash (required for scripts)
    if (-not (Get-Command bash -ErrorAction SilentlyContinue)) {
        Write-ColorOutput Red "Error: Bash is required to run Dockerin scripts."
        Write-ColorOutput Yellow "Please install one of the following:"
        Write-ColorOutput Yellow "  1. Git Bash: https://git-scm.com/downloads"
        Write-ColorOutput Yellow "  2. WSL: wsl --install"
        Write-Output ""
        Write-ColorOutput Yellow "After installing, restart PowerShell and run this installer again."
        exit 1
    }
    
    # Install
    if (-not (Install-Dockerin)) {
        Write-ColorOutput Red "Installation failed"
        exit 1
    }
    
    # Setup PATH
    Set-PathAndAliases
    
    Write-Output ""
    Write-ColorOutput Green "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    Write-ColorOutput Green "✓ Installation complete!"
    Write-ColorOutput Green "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    Write-Output ""
    Write-ColorOutput Cyan "Usage:"
    Write-Output "  dockerin start      # Start interactive menu"
    Write-Output "  dockerin dev-tools  # Development tools"
    Write-Output "  dockerin tutorial   # Interactive tutorial"
    Write-Output ""
    Write-ColorOutput Yellow "Note: Please restart PowerShell or run: . `$PROFILE"
    Write-Output ""
}

# Run main
Main
