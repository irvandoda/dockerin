#!/bin/bash

# Bootstrap Script for Remote Execution
# Supports streaming execution directly from GitHub

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
GITHUB_REPO="irvandoda/dockerin"
GITHUB_BRANCH="${GITHUB_BRANCH:-main}"
BASE_URL="https://raw.githubusercontent.com/$GITHUB_REPO/$GITHUB_BRANCH"

# Get command from arguments
COMMAND=${1:-menu}
shift
ARGS="$@"

# Check if running locally
is_local() {
    local script_source="${BASH_SOURCE[0]}"
    if [ -f "$script_source" ] && [[ "$script_source" != *"raw.githubusercontent.com"* ]]; then
        return 0
    fi
    return 1
}

# Load script from GitHub
load_from_github() {
    local script_path=$1
    local script_url="$BASE_URL/$script_path"
    
    echo -e "${BLUE}Loading $script_path from GitHub...${NC}" >&2
    
    if command -v curl &> /dev/null; then
        curl -s "$script_url"
    elif command -v wget &> /dev/null; then
        wget -q -O - "$script_url"
    else
        echo -e "${RED}Error: curl or wget is required${NC}" >&2
        return 1
    fi
}

# Execute command
execute_command() {
    local cmd=$1
    shift
    local args="$@"
    
    # Check if running locally first
    if is_local; then
        local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
        local script_file="$script_dir/$cmd.sh"
        
        if [ -f "$script_file" ]; then
            echo -e "${GREEN}Running locally: $script_file${NC}" >&2
            bash "$script_file" $args
            return $?
        fi
    fi
    
    # Load from GitHub
    case $cmd in
        menu|start)
            local script=$(load_from_github "menu.sh")
            if [ $? -eq 0 ] && [ -n "$script" ]; then
                # Load dependencies
                local port_mgr=$(load_from_github "utils/port-manager.sh")
                local env_mgr=$(load_from_github "utils/env-manager.sh")
                
                # Combine and execute
                echo "$port_mgr
$env_mgr
$script" | bash -s -- $args
                return $?
            fi
            ;;
        dev-tools)
            local script=$(load_from_github "dev-tools.sh")
            if [ $? -eq 0 ] && [ -n "$script" ]; then
                echo "$script" | bash -s -- $args
                return $?
            fi
            ;;
        tutorial)
            local script=$(load_from_github "tutorial.sh")
            if [ $? -eq 0 ] && [ -n "$script" ]; then
                echo "$script" | bash -s -- $args
                return $?
            fi
            ;;
        install)
            local script=$(load_from_github "install.sh")
            if [ $? -eq 0 ] && [ -n "$script" ]; then
                echo "$script" | bash -s -- $args
                return $?
            fi
            ;;
        *)
            echo -e "${RED}Unknown command: $cmd${NC}" >&2
            echo -e "${YELLOW}Available commands: menu, start, dev-tools, tutorial, install${NC}" >&2
            return 1
            ;;
    esac
    
    return 1
}

# Main
main() {
    if [ -z "$COMMAND" ]; then
        echo -e "${YELLOW}Usage: bootstrap.sh [command] [args...]${NC}" >&2
        echo -e "${YELLOW}Commands: menu, start, dev-tools, tutorial, install${NC}" >&2
        exit 1
    fi
    
    execute_command "$COMMAND" $ARGS
    exit $?
}

main
