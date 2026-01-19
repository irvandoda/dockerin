#!/bin/bash

# Remote Script Loader
# Load dan execute script dari GitHub dengan dependency management

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
GITHUB_REPO="irvandoda/dockerin"
GITHUB_BRANCH="${GITHUB_BRANCH:-main}"
CACHE_DIR="$HOME/.dockerin/cache"
CACHE_TTL=3600 # 1 hour in seconds

# Get GitHub base URL
get_github_base_url() {
    local branch=${1:-$GITHUB_BRANCH}
    echo "https://raw.githubusercontent.com/$GITHUB_REPO/$branch"
}

# Create cache directory
ensure_cache_dir() {
    if [ ! -d "$CACHE_DIR" ]; then
        mkdir -p "$CACHE_DIR"
    fi
}

# Check if cache is valid
is_cache_valid() {
    local cache_file=$1
    
    if [ ! -f "$cache_file" ]; then
        return 1
    fi
    
    local cache_age=$(($(date +%s) - $(stat -f %m "$cache_file" 2>/dev/null || stat -c %Y "$cache_file" 2>/dev/null)))
    
    if [ $cache_age -lt $CACHE_TTL ]; then
        return 0
    fi
    
    return 1
}

# Get cached script
get_cached_script() {
    local script_path=$1
    local cache_file="$CACHE_DIR/$(echo $script_path | tr '/' '_')"
    
    if is_cache_valid "$cache_file"; then
        cat "$cache_file"
        return 0
    fi
    
    return 1
}

# Cache script
cache_script() {
    local script_path=$1
    local content=$2
    local cache_file="$CACHE_DIR/$(echo $script_path | tr '/' '_')"
    
    ensure_cache_dir
    echo "$content" > "$cache_file"
}

# Load script from GitHub
load_script() {
    local script_path=$1
    local branch=${2:-$GITHUB_BRANCH}
    local base_url=$(get_github_base_url "$branch")
    local script_url="$base_url/$script_path"
    
    # Try cache first
    local cached=$(get_cached_script "$script_path")
    if [ -n "$cached" ]; then
        echo "$cached"
        return 0
    fi
    
    # Load from GitHub
    echo -e "${BLUE}Loading $script_path from GitHub...${NC}" >&2
    
    local max_retries=3
    local retry=0
    
    while [ $retry -lt $max_retries ]; do
        if command -v curl &> /dev/null; then
            local content=$(curl -s -f "$script_url" 2>/dev/null)
        elif command -v wget &> /dev/null; then
            local content=$(wget -q -O - "$script_url" 2>/dev/null)
        else
            echo -e "${RED}Error: curl or wget is required${NC}" >&2
            return 1
        fi
        
        if [ -n "$content" ] && [[ "$content" != *"404: Not Found"* ]]; then
            # Validate script (check for shebang)
            if [[ "$content" == "#!/bin/bash"* ]] || [[ "$content" == "#!/usr/bin/env bash"* ]] || [[ "$content" == "#"* ]]; then
                cache_script "$script_path" "$content"
                echo "$content"
                return 0
            else
                echo -e "${YELLOW}Warning: Script may not be valid bash script${NC}" >&2
                cache_script "$script_path" "$content"
                echo "$content"
                return 0
            fi
        fi
        
        retry=$((retry + 1))
        if [ $retry -lt $max_retries ]; then
            echo -e "${YELLOW}Retry $retry/$max_retries...${NC}" >&2
            sleep $((retry * 2))
        fi
    done
    
    echo -e "${RED}Error: Failed to load $script_path after $max_retries attempts${NC}" >&2
    return 1
}

# Load dependencies from script
load_dependencies() {
    local script_content=$1
    local deps=()
    
    # Extract source/load statements
    while IFS= read -r line; do
        if [[ "$line" =~ ^[[:space:]]*(source|\.)[[:space:]]+[\"\']?([^\"\']+)[\"\']? ]]; then
            local dep_path="${BASH_REMATCH[2]}"
            # Convert relative paths
            if [[ "$dep_path" == *"utils/"* ]] || [[ "$dep_path" == *"generators/"* ]]; then
                deps+=("$dep_path")
            fi
        fi
    done <<< "$script_content"
    
    echo "${deps[@]}"
}

# Load script with dependencies
load_script_with_deps() {
    local script_path=$1
    local branch=${2:-$GITHUB_BRANCH}
    
    # Load main script
    local main_script=$(load_script "$script_path" "$branch")
    if [ $? -ne 0 ]; then
        return 1
    fi
    
    # Load dependencies
    local deps=$(load_dependencies "$main_script")
    local combined_script="$main_script"
    
    for dep in $deps; do
        local dep_script=$(load_script "$dep" "$branch")
        if [ $? -eq 0 ]; then
            combined_script="$dep_script

$combined_script"
        fi
    done
    
    echo "$combined_script"
}

# Check if running remotely
is_remote_execution() {
    # Check if script is being executed via curl/wget pipe
    if [ -t 0 ] && [ ! -f "${BASH_SOURCE[0]}" ]; then
        return 0
    fi
    
    # Check if script path contains raw.githubusercontent.com
    local script_source="${BASH_SOURCE[0]}"
    if [[ "$script_source" == *"raw.githubusercontent.com"* ]]; then
        return 0
    fi
    
    return 1
}

# Get script directory (works for both local and remote)
get_script_dir() {
    if is_remote_execution; then
        echo "$HOME/.dockerin"
    else
        echo "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    fi
}
