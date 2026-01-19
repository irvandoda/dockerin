#!/bin/bash

# Environment Manager
# Generate dan manage .env file untuk Laravel

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Generate .env file
generate_env_file() {
    local project_name=$1
    local app_name=${2:-$project_name}
    local db_type=$3
    local db_host=${4:-db}
    local db_port=${5:-3306}
    local db_database=$6
    local db_username=$7
    local db_password=$8
    local redis_enabled=${9:-false}
    local redis_host=${10:-redis}
    local redis_port=${11:-6379}
    local app_url=${12:-http://localhost}
    local mail_host=${13:-mailhog}
    local mail_port=${14:-1025}
    local output_file=${15:-.env}
    
    cat > "$output_file" << EOF
APP_NAME="$app_name"
APP_ENV=local
APP_KEY=
APP_DEBUG=true
APP_TIMEZONE=UTC
APP_URL="$app_url"

APP_LOCALE=en
APP_FALLBACK_LOCALE=en
APP_FAKER_LOCALE=en_US

APP_MAINTENANCE_DRIVER=file
APP_MAINTENANCE_STORE=database

BCRYPT_ROUNDS=12

LOG_CHANNEL=stack
LOG_STACK=single
LOG_DEPRECATIONS_CHANNEL=null
LOG_LEVEL=debug

DB_CONNECTION=$db_type
DB_HOST=$db_host
DB_PORT=$db_port
DB_DATABASE=$db_database
DB_USERNAME=$db_username
DB_PASSWORD="$db_password"

SESSION_DRIVER=database
SESSION_LIFETIME=120
SESSION_ENCRYPT=false
SESSION_PATH=/
SESSION_DOMAIN=null

BROADCAST_CONNECTION=log
FILESYSTEM_DISK=local
QUEUE_CONNECTION=database

CACHE_STORE=database
CACHE_PREFIX=

if [ "\$db_type" = "mysql" ]; then
MEMCACHED_HOST=127.0.0.1
REDIS_CLIENT=phpredis
REDIS_HOST=$redis_host
REDIS_PASSWORD=null
REDIS_PORT=$redis_port
fi

MAIL_MAILER=smtp
MAIL_HOST=$mail_host
MAIL_PORT=$mail_port
MAIL_USERNAME=null
MAIL_PASSWORD=null
MAIL_ENCRYPTION=null
MAIL_FROM_ADDRESS="hello@example.com"
MAIL_FROM_NAME="\${APP_NAME}"

AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=
AWS_DEFAULT_REGION=us-east-1
AWS_BUCKET=
AWS_USE_PATH_STYLE_ENDPOINT=false

VITE_APP_NAME="\${APP_NAME}"
EOF

    echo -e "${GREEN}Generated .env file: $output_file${NC}"
}

# Validate .env file
validate_env_file() {
    local env_file=$1
    
    if [ ! -f "$env_file" ]; then
        echo -e "${RED}Error: .env file not found: $env_file${NC}" >&2
        return 1
    fi
    
    # Check for required variables
    local required_vars=("APP_NAME" "DB_CONNECTION" "DB_HOST" "DB_DATABASE" "DB_USERNAME" "DB_PASSWORD")
    local missing_vars=()
    
    for var in "${required_vars[@]}"; do
        if ! grep -q "^${var}=" "$env_file"; then
            missing_vars+=("$var")
        fi
    done
    
    if [ ${#missing_vars[@]} -gt 0 ]; then
        echo -e "${YELLOW}Warning: Missing required variables: ${missing_vars[*]}${NC}" >&2
        return 1
    fi
    
    return 0
}

# Backup .env file
backup_env_file() {
    local env_file=$1
    local backup_dir=${2:-./backups}
    local timestamp=$(date +%Y%m%d_%H%M%S)
    
    if [ ! -f "$env_file" ]; then
        echo -e "${YELLOW}Warning: .env file not found, nothing to backup${NC}" >&2
        return 1
    fi
    
    mkdir -p "$backup_dir"
    local backup_file="$backup_dir/.env.backup.$timestamp"
    cp "$env_file" "$backup_file"
    echo -e "${GREEN}Backed up .env to: $backup_file${NC}"
}

# Update .env value
update_env_value() {
    local env_file=$1
    local key=$2
    local value=$3
    
    if [ ! -f "$env_file" ]; then
        echo -e "${RED}Error: .env file not found${NC}" >&2
        return 1
    fi
    
    # Backup first
    backup_env_file "$env_file"
    
    # Update or add value
    if grep -q "^${key}=" "$env_file"; then
        # Update existing
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' "s|^${key}=.*|${key}=${value}|" "$env_file"
        else
            sed -i "s|^${key}=.*|${key}=${value}|" "$env_file"
        fi
    else
        # Add new
        echo "${key}=${value}" >> "$env_file"
    fi
    
    echo -e "${GREEN}Updated $key in .env${NC}"
}

# Get .env value
get_env_value() {
    local env_file=$1
    local key=$2
    
    if [ ! -f "$env_file" ]; then
        return 1
    fi
    
    grep "^${key}=" "$env_file" | cut -d '=' -f2- | sed 's/^"\(.*\)"$/\1/'
}
