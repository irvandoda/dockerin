#!/bin/bash

# Port Manager Utility
# Mengecek port yang sudah digunakan dan generate port yang available

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Detect OS
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "linux"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "mac"
    elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
        echo "windows"
    else
        echo "unknown"
    fi
}

# Check if port is available
check_port_available() {
    local port=$1
    local os=$(detect_os)
    
    if [ -z "$port" ]; then
        return 1
    fi
    
    case $os in
        linux)
            if command -v ss &> /dev/null; then
                ss -tuln | grep -q ":$port " && return 1 || return 0
            elif command -v netstat &> /dev/null; then
                netstat -tuln | grep -q ":$port " && return 1 || return 0
            else
                # Fallback: try to connect
                timeout 1 bash -c "echo > /dev/tcp/localhost/$port" 2>/dev/null && return 1 || return 0
            fi
            ;;
        mac)
            if command -v lsof &> /dev/null; then
                lsof -i :$port &> /dev/null && return 1 || return 0
            else
                # Fallback
                timeout 1 bash -c "echo > /dev/tcp/localhost/$port" 2>/dev/null && return 1 || return 0
            fi
            ;;
        windows)
            if command -v netstat &> /dev/null; then
                netstat -an | findstr ":$port " > /dev/null && return 1 || return 0
            else
                # PowerShell fallback
                powershell -Command "Test-NetConnection -ComputerName localhost -Port $port -InformationLevel Quiet" 2>/dev/null && return 1 || return 0
            fi
            ;;
        *)
            # Unknown OS, try generic method
            timeout 1 bash -c "echo > /dev/tcp/localhost/$port" 2>/dev/null && return 1 || return 0
            ;;
    esac
}

# Find available port in range
find_available_port() {
    local start_port=$1
    local end_port=${2:-$((start_port + 1000))}
    local port=$start_port
    
    while [ $port -le $end_port ]; do
        if check_port_available $port; then
            echo $port
            return 0
        fi
        port=$((port + 1))
    done
    
    return 1
}

# Get Nginx HTTP port
get_nginx_http_port() {
    local default_port=80
    
    if check_port_available $default_port; then
        echo $default_port
    else
        local available_port=$(find_available_port 8080 8180)
        if [ -n "$available_port" ]; then
            echo $available_port
        else
            echo $default_port
        fi
    fi
}

# Get Nginx HTTPS port
get_nginx_https_port() {
    local default_port=443
    
    if check_port_available $default_port; then
        echo $default_port
    else
        local available_port=$(find_available_port 8443 8543)
        if [ -n "$available_port" ]; then
            echo $available_port
        else
            echo $default_port
        fi
    fi
}

# Get database port
get_database_port() {
    local db_type=$1
    local default_port
    
    case $db_type in
        mysql|mariadb)
            default_port=3306
            ;;
        postgres|postgresql)
            default_port=5432
            ;;
        *)
            default_port=3306
            ;;
    esac
    
    if check_port_available $default_port; then
        echo $default_port
    else
        local start_port=$((default_port + 1))
        local available_port=$(find_available_port $start_port $((start_port + 100)))
        if [ -n "$available_port" ]; then
            echo $available_port
        else
            echo $default_port
        fi
    fi
}

# Get Redis port
get_redis_port() {
    local default_port=6379
    
    if check_port_available $default_port; then
        echo $default_port
    else
        local available_port=$(find_available_port 6380 6480)
        if [ -n "$available_port" ]; then
            echo $available_port
        else
            echo $default_port
        fi
    fi
}

# Validate port
validate_port() {
    local port=$1
    
    if ! [[ "$port" =~ ^[0-9]+$ ]]; then
        echo -e "${RED}Error: Port must be a number${NC}" >&2
        return 1
    fi
    
    if [ "$port" -lt 1 ] || [ "$port" -gt 65535 ]; then
        echo -e "${RED}Error: Port must be between 1 and 65535${NC}" >&2
        return 1
    fi
    
    return 0
}

# Main function for interactive port selection
interactive_port_selection() {
    local service_name=$1
    local default_port=$2
    local suggested_port
    
    # Check if default port is available
    if check_port_available $default_port; then
        suggested_port=$default_port
        echo -e "${GREEN}Suggested port for $service_name: $suggested_port (available)${NC}"
    else
        suggested_port=$(find_available_port $((default_port + 1)) $((default_port + 1000)))
        if [ -n "$suggested_port" ]; then
            echo -e "${YELLOW}Port $default_port is in use. Suggested alternative: $suggested_port${NC}"
        else
            suggested_port=$default_port
            echo -e "${YELLOW}Could not find available port. Using default: $default_port${NC}"
        fi
    fi
    
    read -p "Enter port for $service_name [$suggested_port]: " user_port
    
    if [ -z "$user_port" ]; then
        user_port=$suggested_port
    fi
    
    # Validate port
    while ! validate_port "$user_port"; do
        read -p "Enter port for $service_name [$suggested_port]: " user_port
        if [ -z "$user_port" ]; then
            user_port=$suggested_port
        fi
    done
    
    # Check if selected port is available
    if ! check_port_available $user_port; then
        echo -e "${YELLOW}Warning: Port $user_port is already in use. Continue anyway? (y/n)${NC}"
        read -p "> " confirm
        if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
            interactive_port_selection "$service_name" "$default_port"
            return
        fi
    fi
    
    echo $user_port
}
