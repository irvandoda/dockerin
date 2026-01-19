#!/bin/bash

# Database Tools for Dockerin
# Database management utilities

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Get command
COMMAND=${1:-help}

# Find docker-compose.yml
find_compose_file() {
    local dir=$(pwd)
    while [ "$dir" != "/" ]; do
        if [ -f "$dir/docker-compose.yml" ]; then
            echo "$dir"
            return 0
        fi
        dir=$(dirname "$dir")
    done
    return 1
}

# Get project directory
PROJECT_DIR=$(find_compose_file)

if [ -z "$PROJECT_DIR" ]; then
    echo -e "${RED}Error: docker-compose.yml not found${NC}" >&2
    echo -e "${YELLOW}Please run this command in a directory with docker-compose.yml${NC}" >&2
    exit 1
fi

cd "$PROJECT_DIR"

# Detect database type
detect_db_type() {
    if docker-compose exec -T db mysql --version &> /dev/null 2>&1; then
        echo "mysql"
    elif docker-compose exec -T db psql --version &> /dev/null 2>&1; then
        echo "postgresql"
    else
        echo "unknown"
    fi
}

DB_TYPE=$(detect_db_type)

# Get database credentials from .env
get_db_credentials() {
    if [ -f ".env" ]; then
        DB_NAME=$(grep "^DB_DATABASE=" .env | cut -d= -f2 | tr -d ' "')
        DB_USER=$(grep "^DB_USERNAME=" .env | cut -d= -f2 | tr -d ' "')
        DB_PASS=$(grep "^DB_PASSWORD=" .env | cut -d= -f2 | tr -d ' "')
        DB_HOST=$(grep "^DB_HOST=" .env | cut -d= -f2 | tr -d ' "')
    fi
    
    DB_NAME=${DB_NAME:-laravel}
    DB_USER=${DB_USER:-root}
    DB_PASS=${DB_PASS:-root}
    DB_HOST=${DB_HOST:-db}
}

get_db_credentials

# Backup database
cmd_backup() {
    local backup_file="backups/db_backup_$(date +%Y%m%d_%H%M%S).sql"
    mkdir -p backups
    
    echo -e "${BLUE}Backing up database...${NC}"
    
    case $DB_TYPE in
        mysql)
            docker-compose exec -T db mysqldump -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" > "$backup_file" 2>/dev/null || \
            docker-compose exec -T db mysqldump -u root -p"$DB_PASS" "$DB_NAME" > "$backup_file" || \
            docker-compose exec -T db mysqldump -u root "$DB_NAME" > "$backup_file"
            ;;
        postgresql)
            docker-compose exec -T db pg_dump -U "$DB_USER" "$DB_NAME" > "$backup_file" 2>/dev/null || \
            docker-compose exec -T db pg_dump -U postgres "$DB_NAME" > "$backup_file"
            ;;
        *)
            echo -e "${RED}Error: Unknown database type${NC}"
            return 1
            ;;
    esac
    
    if [ -f "$backup_file" ] && [ -s "$backup_file" ]; then
        echo -e "${GREEN}✓ Database backed up to: $backup_file${NC}"
        # Compress backup
        gzip "$backup_file" 2>/dev/null && \
            echo -e "${GREEN}✓ Backup compressed: ${backup_file}.gz${NC}"
    else
        echo -e "${RED}✗ Backup failed${NC}"
        return 1
    fi
}

# Restore database
cmd_restore() {
    local backup_file=$2
    
    if [ -z "$backup_file" ]; then
        echo -e "${RED}Error: Please specify backup file${NC}" >&2
        echo -e "${YELLOW}Usage: database-tools.sh restore <backup_file>${NC}" >&2
        return 1
    fi
    
    # Handle compressed files
    if [[ "$backup_file" == *.gz ]]; then
        local temp_file=$(mktemp)
        gunzip -c "$backup_file" > "$temp_file"
        backup_file="$temp_file"
    fi
    
    if [ ! -f "$backup_file" ]; then
        echo -e "${RED}Error: Backup file not found${NC}" >&2
        return 1
    fi
    
    echo -e "${YELLOW}Warning: This will overwrite the current database!${NC}"
    read -p "Are you sure? (y/n) [n]: " confirm
    if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
        echo "Cancelled"
        [ -n "$temp_file" ] && rm -f "$temp_file"
        return 0
    fi
    
    echo -e "${BLUE}Restoring database from $backup_file...${NC}"
    
    case $DB_TYPE in
        mysql)
            docker-compose exec -T db mysql -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" < "$backup_file" 2>/dev/null || \
            docker-compose exec -T db mysql -u root -p"$DB_PASS" "$DB_NAME" < "$backup_file" || \
            docker-compose exec -T db mysql -u root "$DB_NAME" < "$backup_file"
            ;;
        postgresql)
            docker-compose exec -T db psql -U "$DB_USER" -d "$DB_NAME" < "$backup_file" 2>/dev/null || \
            docker-compose exec -T db psql -U postgres -d "$DB_NAME" < "$backup_file"
            ;;
        *)
            echo -e "${RED}Error: Unknown database type${NC}"
            [ -n "$temp_file" ] && rm -f "$temp_file"
            return 1
            ;;
    esac
    
    [ -n "$temp_file" ] && rm -f "$temp_file"
    echo -e "${GREEN}✓ Database restored${NC}"
}

# Run migrations
cmd_migrate() {
    echo -e "${BLUE}Running migrations...${NC}"
    
    if [ -f "artisan" ]; then
        docker-compose exec php php artisan migrate
    else
        echo -e "${RED}Error: Laravel project not found${NC}"
        return 1
    fi
}

# Run seeders
cmd_seed() {
    echo -e "${BLUE}Running seeders...${NC}"
    
    if [ -f "artisan" ]; then
        docker-compose exec php php artisan db:seed
    else
        echo -e "${RED}Error: Laravel project not found${NC}"
        return 1
    fi
}

# Database shell
cmd_shell() {
    echo -e "${BLUE}Opening database shell...${NC}"
    
    case $DB_TYPE in
        mysql)
            docker-compose exec db mysql -u "$DB_USER" -p"$DB_PASS" "$DB_NAME"
            ;;
        postgresql)
            docker-compose exec db psql -U "$DB_USER" -d "$DB_NAME"
            ;;
        *)
            echo -e "${RED}Error: Unknown database type${NC}"
            return 1
            ;;
    esac
}

# Test connection
cmd_test() {
    echo -e "${BLUE}Testing database connection...${NC}"
    
    case $DB_TYPE in
        mysql)
            if docker-compose exec -T db mysql -u "$DB_USER" -p"$DB_PASS" -e "SELECT 1;" "$DB_NAME" &> /dev/null; then
                echo -e "${GREEN}✓ Database connection successful${NC}"
                echo -e "${CYAN}Database: $DB_NAME${NC}"
                echo -e "${CYAN}User: $DB_USER${NC}"
                echo -e "${CYAN}Host: $DB_HOST${NC}"
            else
                echo -e "${RED}✗ Database connection failed${NC}"
                return 1
            fi
            ;;
        postgresql)
            if docker-compose exec -T db psql -U "$DB_USER" -d "$DB_NAME" -c "SELECT 1;" &> /dev/null; then
                echo -e "${GREEN}✓ Database connection successful${NC}"
                echo -e "${CYAN}Database: $DB_NAME${NC}"
                echo -e "${CYAN}User: $DB_USER${NC}"
                echo -e "${CYAN}Host: $DB_HOST${NC}"
            else
                echo -e "${RED}✗ Database connection failed${NC}"
                return 1
            fi
            ;;
        *)
            echo -e "${RED}Error: Unknown database type${NC}"
            return 1
            ;;
    esac
}

# Help
cmd_help() {
    echo -e "${CYAN}Dockerin Database Tools${NC}\n"
    echo "Usage: database-tools.sh [command] [options]"
    echo ""
    echo "Commands:"
    echo "  backup              Backup database to SQL file"
    echo "  restore <file>       Restore database from backup file"
    echo "  migrate             Run Laravel migrations"
    echo "  seed                Run Laravel seeders"
    echo "  shell               Open database shell"
    echo "  test                Test database connection"
    echo "  help                Show this help message"
    echo ""
}

# Main
case $COMMAND in
    backup)
        cmd_backup
        ;;
    restore)
        cmd_restore "$@"
        ;;
    migrate)
        cmd_migrate
        ;;
    seed)
        cmd_seed
        ;;
    shell)
        cmd_shell
        ;;
    test)
        cmd_test
        ;;
    help|*)
        cmd_help
        ;;
esac
