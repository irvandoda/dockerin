#!/bin/bash

# Dockerin - Interactive Docker CLI for Laravel
# Main menu script

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load utilities
if [ -f "$SCRIPT_DIR/utils/port-manager.sh" ]; then
    source "$SCRIPT_DIR/utils/port-manager.sh"
fi

if [ -f "$SCRIPT_DIR/utils/env-manager.sh" ]; then
    source "$SCRIPT_DIR/utils/env-manager.sh"
fi

# Configuration variables
PROJECT_NAME=""
LARAVEL_VERSION="latest"
PHP_VERSION="8.3"
DB_TYPE="mysql"
DB_USERNAME=""
DB_PASSWORD=""
DB_NAME=""
DB_PORT=""
REDIS_ENABLED=false
REDIS_PORT=""
NGINX_HTTP_PORT=""
NGINX_HTTPS_PORT=""
NGINX_SSL=false
NGINX_CACHE=false
NGINX_RATE_LIMIT=false
MAIL_CATCHER=false
XDEBUG=false
QUEUE_WORKER=false
DB_ADMIN=""
HOT_RELOAD=false
PRESET="custom"

# Print header
print_header() {
    clear
    echo -e "${CYAN}"
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║           Dockerin - Laravel Docker Setup CLI             ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# Print section header
print_section() {
    local title=$1
    echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}$title${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
}

# Validate project name
validate_project_name() {
    local name=$1
    
    if [ -z "$name" ]; then
        echo -e "${RED}Error: Project name cannot be empty${NC}" >&2
        return 1
    fi
    
    if [[ ! "$name" =~ ^[a-zA-Z0-9_-]+$ ]]; then
        echo -e "${RED}Error: Project name can only contain letters, numbers, underscores, and hyphens${NC}" >&2
        return 1
    fi
    
    return 0
}

# Validate password
validate_password() {
    local password=$1
    
    if [ -z "$password" ]; then
        echo -e "${RED}Error: Password cannot be empty${NC}" >&2
        return 1
    fi
    
    if [ ${#password} -lt 6 ]; then
        echo -e "${YELLOW}Warning: Password should be at least 6 characters${NC}" >&2
    fi
    
    return 0
}

# Input project name
input_project_name() {
    while true; do
        read -p "Enter project name: " PROJECT_NAME
        if validate_project_name "$PROJECT_NAME"; then
            break
        fi
    done
}

# Input Laravel version
input_laravel_version() {
    echo "Select Laravel version:"
    echo "1) Latest (11.x)"
    echo "2) 11.x"
    echo "3) 10.x"
    echo "4) 9.x"
    read -p "Choice [1]: " choice
    
    case $choice in
        2) LARAVEL_VERSION="11.x" ;;
        3) LARAVEL_VERSION="10.x" ;;
        4) LARAVEL_VERSION="9.x" ;;
        *) LARAVEL_VERSION="latest" ;;
    esac
}

# Input PHP version
input_php_version() {
    echo "Select PHP version:"
    echo "1) 8.4 (Latest)"
    echo "2) 8.3"
    echo "3) 8.2"
    echo "4) 8.1"
    echo "5) 8.0"
    read -p "Choice [2]: " choice
    
    case $choice in
        1) PHP_VERSION="8.4" ;;
        3) PHP_VERSION="8.2" ;;
        4) PHP_VERSION="8.1" ;;
        5) PHP_VERSION="8.0" ;;
        *) PHP_VERSION="8.3" ;;
    esac
}

# Input database configuration
input_database() {
    echo "Select database:"
    echo "1) MySQL"
    echo "2) PostgreSQL"
    read -p "Choice [1]: " choice
    
    if [ "$choice" = "2" ]; then
        DB_TYPE="postgresql"
        DB_PORT=$(get_database_port "postgresql")
    else
        DB_TYPE="mysql"
        DB_PORT=$(get_database_port "mysql")
    fi
    
    echo -e "${GREEN}Suggested database port: $DB_PORT${NC}"
    read -p "Database port [$DB_PORT]: " user_port
    if [ -n "$user_port" ]; then
        if validate_port "$user_port"; then
            DB_PORT=$user_port
        fi
    fi
    
    read -p "Database username [root]: " DB_USERNAME
    DB_USERNAME=${DB_USERNAME:-root}
    
    while true; do
        read -sp "Database password: " DB_PASSWORD
        echo
        if validate_password "$DB_PASSWORD"; then
            break
        fi
    done
    
    read -p "Database name [$PROJECT_NAME]: " DB_NAME
    DB_NAME=${DB_NAME:-$PROJECT_NAME}
}

# Input Redis configuration
input_redis() {
    read -p "Enable Redis? (y/n) [n]: " choice
    if [ "$choice" = "y" ] || [ "$choice" = "Y" ]; then
        REDIS_ENABLED=true
        REDIS_PORT=$(get_redis_port)
        echo -e "${GREEN}Suggested Redis port: $REDIS_PORT${NC}"
        read -p "Redis port [$REDIS_PORT]: " user_port
        if [ -n "$user_port" ]; then
            if validate_port "$user_port"; then
                REDIS_PORT=$user_port
            fi
        fi
    fi
}

# Input Nginx configuration
input_nginx() {
    NGINX_HTTP_PORT=$(get_nginx_http_port)
    echo -e "${GREEN}Suggested Nginx HTTP port: $NGINX_HTTP_PORT${NC}"
    read -p "Nginx HTTP port [$NGINX_HTTP_PORT]: " user_port
    if [ -n "$user_port" ]; then
        if validate_port "$user_port"; then
            NGINX_HTTP_PORT=$user_port
        fi
    fi
    
    NGINX_HTTPS_PORT=$(get_nginx_https_port)
    echo -e "${GREEN}Suggested Nginx HTTPS port: $NGINX_HTTPS_PORT${NC}"
    read -p "Nginx HTTPS port [$NGINX_HTTPS_PORT]: " user_port
    if [ -n "$user_port" ]; then
        if validate_port "$user_port"; then
            NGINX_HTTPS_PORT=$user_port
        fi
    fi
    
    echo "Nginx Extensions:"
    read -p "Enable SSL? (y/n) [n]: " choice
    if [ "$choice" = "y" ] || [ "$choice" = "Y" ]; then
        NGINX_SSL=true
    fi
    
    read -p "Enable Cache? (y/n) [n]: " choice
    if [ "$choice" = "y" ] || [ "$choice" = "Y" ]; then
        NGINX_CACHE=true
    fi
    
    read -p "Enable Rate Limiting? (y/n) [n]: " choice
    if [ "$choice" = "y" ] || [ "$choice" = "Y" ]; then
        NGINX_RATE_LIMIT=true
    fi
}

# Input additional features
input_additional_features() {
    read -p "Enable Mail Catcher (MailHog/Mailpit)? (y/n) [n]: " choice
    if [ "$choice" = "y" ] || [ "$choice" = "Y" ]; then
        MAIL_CATCHER=true
    fi
    
    read -p "Enable Xdebug? (y/n) [n]: " choice
    if [ "$choice" = "y" ] || [ "$choice" = "Y" ]; then
        XDEBUG=true
    fi
    
    read -p "Enable Queue Worker? (y/n) [n]: " choice
    if [ "$choice" = "y" ] || [ "$choice" = "Y" ]; then
        QUEUE_WORKER=true
    fi
    
    echo "Database Admin Tool:"
    echo "1) None"
    echo "2) phpMyAdmin (MySQL only)"
    echo "3) Adminer (MySQL & PostgreSQL)"
    read -p "Choice [1]: " choice
    
    case $choice in
        2) DB_ADMIN="phpmyadmin" ;;
        3) DB_ADMIN="adminer" ;;
        *) DB_ADMIN="" ;;
    esac
    
    read -p "Enable Hot Reload? (y/n) [n]: " choice
    if [ "$choice" = "y" ] || [ "$choice" = "Y" ]; then
        HOT_RELOAD=true
    fi
    
    echo "Preset Template:"
    echo "1) Custom"
    echo "2) API Only"
    echo "3) SPA (Vue/React)"
    echo "4) Full-stack"
    read -p "Choice [1]: " choice
    
    case $choice in
        2) PRESET="api" ;;
        3) PRESET="spa" ;;
        4) PRESET="fullstack" ;;
        *) PRESET="custom" ;;
    esac
}

# Print summary
print_summary() {
    print_section "Configuration Summary"
    
    echo -e "${CYAN}Project Configuration:${NC}"
    echo "  Project Name: $PROJECT_NAME"
    echo "  Laravel Version: $LARAVEL_VERSION"
    echo "  PHP Version: $PHP_VERSION"
    echo ""
    
    echo -e "${CYAN}Database Configuration:${NC}"
    echo "  Type: $DB_TYPE"
    echo "  Host: db"
    echo "  Port: $DB_PORT"
    echo "  Database: $DB_NAME"
    echo "  Username: $DB_USERNAME"
    echo ""
    
    echo -e "${CYAN}Services:${NC}"
    echo "  Redis: $REDIS_ENABLED"$([ "$REDIS_ENABLED" = true ] && echo " (Port: $REDIS_PORT)" || echo "")
    echo "  Mail Catcher: $MAIL_CATCHER"
    echo "  Xdebug: $XDEBUG"
    echo "  Queue Worker: $QUEUE_WORKER"
    echo "  Database Admin: ${DB_ADMIN:-None}"
    echo "  Hot Reload: $HOT_RELOAD"
    echo ""
    
    echo -e "${CYAN}Nginx Configuration:${NC}"
    echo "  HTTP Port: $NGINX_HTTP_PORT"
    echo "  HTTPS Port: $NGINX_HTTPS_PORT"
    echo "  SSL: $NGINX_SSL"
    echo "  Cache: $NGINX_CACHE"
    echo "  Rate Limiting: $NGINX_RATE_LIMIT"
    echo ""
    
    echo -e "${CYAN}Preset:${NC}"
    echo "  Template: $PRESET"
    echo ""
}

# Main menu flow
main() {
    print_header
    
    print_section "Project Setup"
    input_project_name
    input_laravel_version
    input_php_version
    
    print_section "Database Configuration"
    input_database
    
    print_section "Additional Services"
    input_redis
    
    print_section "Nginx Configuration"
    input_nginx
    
    print_section "Additional Features"
    input_additional_features
    
    print_summary
    
    read -p "Generate docker-compose.yml? (y/n) [y]: " confirm
    if [ "$confirm" != "n" ] && [ "$confirm" != "N" ]; then
        # Call generator
        if [ -f "$SCRIPT_DIR/generators/laravel-compose.sh" ]; then
            "$SCRIPT_DIR/generators/laravel-compose.sh" \
                "$PROJECT_NAME" \
                "$LARAVEL_VERSION" \
                "$PHP_VERSION" \
                "$DB_TYPE" \
                "$DB_USERNAME" \
                "$DB_PASSWORD" \
                "$DB_NAME" \
                "$DB_PORT" \
                "$REDIS_ENABLED" \
                "$REDIS_PORT" \
                "$NGINX_HTTP_PORT" \
                "$NGINX_HTTPS_PORT" \
                "$NGINX_SSL" \
                "$NGINX_CACHE" \
                "$NGINX_RATE_LIMIT" \
                "$MAIL_CATCHER" \
                "$XDEBUG" \
                "$QUEUE_WORKER" \
                "$DB_ADMIN" \
                "$HOT_RELOAD" \
                "$PRESET"
        else
            echo -e "${RED}Error: Generator script not found${NC}"
            exit 1
        fi
    else
        echo -e "${YELLOW}Cancelled${NC}"
        exit 0
    fi
}

# Run main
main
