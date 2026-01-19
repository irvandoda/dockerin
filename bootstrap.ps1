# Bootstrap Script for Windows PowerShell
# Dockerin - Remote Execution Script

$ErrorActionPreference = "Stop"

# Colors
function Write-ColorOutput($ForegroundColor) {
    $fc = $host.UI.RawUI.ForegroundColor
    $host.UI.RawUI.ForegroundColor = $ForegroundColor
    if ($args) {
        Write-Output $args
    }
    $host.UI.RawUI.ForegroundColor = $fc
}

# Configuration
$GITHUB_REPO = "irvandoda/dockerin"
$GITHUB_BRANCH = if ($env:GITHUB_BRANCH) { $env:GITHUB_BRANCH } else { "main" }
$BASE_URL = "https://raw.githubusercontent.com/$GITHUB_REPO/$GITHUB_BRANCH"

# Get command from arguments
$COMMAND = if ($args[0]) { $args[0] } else { "menu" }
$ARGS = $args[1..($args.Length - 1)]

# Load script from GitHub
function Load-FromGitHub {
    param(
        [string]$ScriptPath
    )
    
    $scriptUrl = "$BASE_URL/$ScriptPath"
    Write-ColorOutput Cyan "Loading $ScriptPath from GitHub..."
    
    try {
        $script = Invoke-WebRequest -Uri $scriptUrl -UseBasicParsing -ErrorAction Stop
        return $script.Content
    }
    catch {
        Write-ColorOutput Red "Error: Failed to load $ScriptPath"
        Write-ColorOutput Red $_.Exception.Message
        return $null
    }
}

# Execute command
function Execute-Command {
    param(
        [string]$Cmd,
        [string[]]$Arguments
    )
    
    # Check if running locally first
    $scriptDir = Split-Path -Parent $MyInvocation.PSCommandPath
    $scriptFile = Join-Path $scriptDir "$Cmd.sh"
    
    if (Test-Path $scriptFile) {
        Write-ColorOutput Green "Running locally: $scriptFile"
        # For Windows, we need to use bash (Git Bash or WSL)
        if (Get-Command bash -ErrorAction SilentlyContinue) {
            $argString = $Arguments -join " "
            bash $scriptFile $argString
            return $LASTEXITCODE
        }
        else {
            Write-ColorOutput Yellow "Bash not found. Please install Git Bash or WSL."
            Write-ColorOutput Yellow "Alternatively, use: curl -sL $BASE_URL/$Cmd.sh | bash"
            return 1
        }
    }
    
    # Load from GitHub
    switch ($Cmd) {
        { $_ -in "menu", "start" } {
            $script = Load-FromGitHub "menu.sh"
            if ($script) {
                # Load dependencies
                $portMgr = Load-FromGitHub "utils/port-manager.sh"
                $envMgr = Load-FromGitHub "utils/env-manager.sh"
                
                # Save to temp file and execute
                $tempFile = [System.IO.Path]::GetTempFileName() + ".sh"
                "$portMgr`n`n$envMgr`n`n$script" | Out-File -FilePath $tempFile -Encoding UTF8
                
                if (Get-Command bash -ErrorAction SilentlyContinue) {
                    $argString = $Arguments -join " "
                    bash $tempFile $argString
                    Remove-Item $tempFile -ErrorAction SilentlyContinue
                    return $LASTEXITCODE
                }
                else {
                    Write-ColorOutput Yellow "Bash not found. Please install Git Bash or WSL."
                    Write-ColorOutput Yellow "Command to run: curl -sL $BASE_URL/menu.sh | bash"
                    Remove-Item $tempFile -ErrorAction SilentlyContinue
                    return 1
                }
            }
        }
        "dev-tools" {
            $script = Load-FromGitHub "dev-tools.sh"
            if ($script) {
                $tempFile = [System.IO.Path]::GetTempFileName() + ".sh"
                $script | Out-File -FilePath $tempFile -Encoding UTF8
                
                if (Get-Command bash -ErrorAction SilentlyContinue) {
                    $argString = $Arguments -join " "
                    bash $tempFile $argString
                    Remove-Item $tempFile -ErrorAction SilentlyContinue
                    return $LASTEXITCODE
                }
                else {
                    Write-ColorOutput Yellow "Bash not found. Please install Git Bash or WSL."
                    Write-ColorOutput Yellow "Command to run: curl -sL $BASE_URL/dev-tools.sh | bash"
                    Remove-Item $tempFile -ErrorAction SilentlyContinue
                    return 1
                }
            }
        }
        "tutorial" {
            $script = Load-FromGitHub "tutorial.sh"
            if ($script) {
                $tempFile = [System.IO.Path]::GetTempFileName() + ".sh"
                $script | Out-File -FilePath $tempFile -Encoding UTF8
                
                if (Get-Command bash -ErrorAction SilentlyContinue) {
                    $argString = $Arguments -join " "
                    bash $tempFile $argString
                    Remove-Item $tempFile -ErrorAction SilentlyContinue
                    return $LASTEXITCODE
                }
                else {
                    Write-ColorOutput Yellow "Bash not found. Please install Git Bash or WSL."
                    Write-ColorOutput Yellow "Command to run: curl -sL $BASE_URL/tutorial.sh | bash"
                    Remove-Item $tempFile -ErrorAction SilentlyContinue
                    return 1
                }
            }
        }
        "install" {
            $script = Load-FromGitHub "install.sh"
            if ($script) {
                $tempFile = [System.IO.Path]::GetTempFileName() + ".sh"
                $script | Out-File -FilePath $tempFile -Encoding UTF8
                
                if (Get-Command bash -ErrorAction SilentlyContinue) {
                    $argString = $Arguments -join " "
                    bash $tempFile $argString
                    Remove-Item $tempFile -ErrorAction SilentlyContinue
                    return $LASTEXITCODE
                }
                else {
                    Write-ColorOutput Yellow "Bash not found. Please install Git Bash or WSL."
                    Write-ColorOutput Yellow "Command to run: curl -sL $BASE_URL/install.sh | bash"
                    Remove-Item $tempFile -ErrorAction SilentlyContinue
                    return 1
                }
            }
        }
        default {
            Write-ColorOutput Red "Unknown command: $Cmd"
            Write-ColorOutput Yellow "Available commands: menu, start, dev-tools, tutorial, install"
            return 1
        }
    }
    
    return 1
}

# Main
if (-not $COMMAND) {
    Write-ColorOutput Yellow "Usage: bootstrap.ps1 [command] [args...]"
    Write-ColorOutput Yellow "Commands: menu, start, dev-tools, tutorial, install"
    exit 1
}

$exitCode = Execute-Command -Cmd $COMMAND -Arguments $ARGS
exit $exitCode
