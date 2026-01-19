#!/bin/bash

# Development Tools for Dockerin
# Various utilities for development workflow

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

# View logs
cmd_logs() {
    local service=${2:-}
    if [ -n "$service" ]; then
        docker-compose logs -f "$service"
    else
        docker-compose logs -f
    fi
}

# Health check
cmd_health() {
    echo -e "${CYAN}Checking service health...${NC}\n"
    
    docker-compose ps
    
    echo ""
    echo -e "${CYAN}Testing services...${NC}\n"
    
    # Test PHP
    if docker-compose exec -T php php -v &> /dev/null; then
        echo -e "${GREEN}✓ PHP service is healthy${NC}"
    else
        echo -e "${RED}✗ PHP service is not responding${NC}"
    fi
    
    # Test Nginx
    if curl -s http://localhost:80/health &> /dev/null; then
        echo -e "${GREEN}✓ Nginx service is healthy${NC}"
    else
        echo -e "${YELLOW}⚠ Nginx service may not be responding${NC}"
    fi
    
    # Test Database
    if docker-compose exec -T db mysql --version &> /dev/null 2>&1 || \
       docker-compose exec -T db psql --version &> /dev/null 2>&1; then
        echo -e "${GREEN}✓ Database service is healthy${NC}"
    else
        echo -e "${RED}✗ Database service is not responding${NC}"
    fi
}

# Shell access
cmd_shell() {
    local service=${2:-php}
    docker-compose exec "$service" bash
}

# Restart service
cmd_restart() {
    local service=${2:-}
    if [ -n "$service" ]; then
        echo -e "${BLUE}Restarting $service...${NC}"
        docker-compose restart "$service"
    else
        echo -e "${BLUE}Restarting all services...${NC}"
        docker-compose restart
    fi
    echo -e "${GREEN}✓ Restarted${NC}"
}

# Clear cache
cmd_clear_cache() {
    echo -e "${BLUE}Clearing caches...${NC}"
    
    # Laravel cache
    docker-compose exec -T php php artisan cache:clear 2>/dev/null && \
        echo -e "${GREEN}✓ Laravel cache cleared${NC}" || \
        echo -e "${YELLOW}⚠ Laravel cache clear failed (may not be Laravel project)${NC}"
    
    # Laravel config cache
    docker-compose exec -T php php artisan config:clear 2>/dev/null && \
        echo -e "${GREEN}✓ Laravel config cache cleared${NC}"
    
    # Laravel route cache
    docker-compose exec -T php php artisan route:clear 2>/dev/null && \
        echo -e "${GREEN}✓ Laravel route cache cleared${NC}"
    
    # Laravel view cache
    docker-compose exec -T php php artisan view:clear 2>/dev/null && \
        echo -e "${GREEN}✓ Laravel view cache cleared${NC}"
    
    # Redis cache (if available)
    if docker-compose ps redis &> /dev/null; then
        docker-compose exec -T redis redis-cli FLUSHALL 2>/dev/null && \
            echo -e "${GREEN}✓ Redis cache cleared${NC}"
    fi
    
    # Nginx cache (if exists)
    if [ -d "/var/cache/nginx" ]; then
        docker-compose exec -T nginx rm -rf /var/cache/nginx/* 2>/dev/null && \
            echo -e "${GREEN}✓ Nginx cache cleared${NC}"
    fi
    
    echo -e "${GREEN}Cache clearing complete!${NC}"
}

# Status
cmd_status() {
    echo -e "${CYAN}Container Status:${NC}\n"
    docker-compose ps
    
    echo ""
    echo -e "${CYAN}Resource Usage:${NC}\n"
    docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}" \
        $(docker-compose ps -q)
}

# Backup database
cmd_backup_db() {
    local backup_file="backups/db_backup_$(date +%Y%m%d_%H%M%S).sql"
    mkdir -p backups
    
    echo -e "${BLUE}Backing up database...${NC}"
    
    if docker-compose exec -T db mysql --version &> /dev/null 2>&1; then
        # MySQL
        docker-compose exec -T db mysqldump -u root -p"$(grep MYSQL_ROOT_PASSWORD docker-compose.yml | cut -d: -f2 | tr -d ' \"')" \
            --all-databases > "$backup_file" 2>/dev/null || \
            docker-compose exec -T db mysqldump -u root --all-databases > "$backup_file"
    elif docker-compose exec -T db psql --version &> /dev/null 2>&1; then
        # PostgreSQL
        docker-compose exec -T db pg_dumpall -U postgres > "$backup_file"
    else
        echo -e "${RED}Error: Unknown database type${NC}"
        return 1
    fi
    
    if [ -f "$backup_file" ]; then
        echo -e "${GREEN}✓ Database backed up to: $backup_file${NC}"
    else
        echo -e "${RED}✗ Backup failed${NC}"
        return 1
    fi
}

# Restore database
cmd_restore_db() {
    local backup_file=$2
    
    if [ -z "$backup_file" ]; then
        echo -e "${RED}Error: Please specify backup file${NC}" >&2
        echo -e "${YELLOW}Usage: dev-tools restore-db <backup_file>${NC}" >&2
        return 1
    fi
    
    if [ ! -f "$backup_file" ]; then
        echo -e "${RED}Error: Backup file not found: $backup_file${NC}" >&2
        return 1
    fi
    
    echo -e "${YELLOW}Warning: This will overwrite the current database!${NC}"
    read -p "Are you sure? (y/n) [n]: " confirm
    if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
        echo "Cancelled"
        return 0
    fi
    
    echo -e "${BLUE}Restoring database from $backup_file...${NC}"
    
    if docker-compose exec -T db mysql --version &> /dev/null 2>&1; then
        # MySQL
        docker-compose exec -T db mysql -u root < "$backup_file"
    elif docker-compose exec -T db psql --version &> /dev/null 2>&1; then
        # PostgreSQL
        docker-compose exec -T db psql -U postgres < "$backup_file"
    else
        echo -e "${RED}Error: Unknown database type${NC}"
        return 1
    fi
    
    echo -e "${GREEN}✓ Database restored${NC}"
}

# Help
cmd_help() {
    echo -e "${CYAN}Dockerin Development Tools${NC}\n"
    echo "Usage: dev-tools.sh [command] [options]"
    echo ""
    echo "Commands:"
    echo "  logs [service]     View logs (all services or specific service)"
    echo "  health             Check health of all services"
    echo "  shell [service]    Access shell (default: php)"
    echo "  restart [service]  Restart service(s)"
    echo "  clear-cache        Clear all caches (Laravel, Redis, Nginx)"
    echo "  status             Show container status and resource usage"
    echo "  backup-db          Backup database"
    echo "  restore-db <file>  Restore database from backup"
    echo "  help               Show this help message"
    echo ""
}

# Main
case $COMMAND in
    logs)
        cmd_logs "$@"
        ;;
    health)
        cmd_health
        ;;
    shell)
        cmd_shell "$@"
        ;;
    restart)
        cmd_restart "$@"
        ;;
    clear-cache)
        cmd_clear_cache
        ;;
    status)
        cmd_status
        ;;
    backup-db)
        cmd_backup_db
        ;;
    restore-db)
        cmd_restore_db "$@"
        ;;
    help|*)
        cmd_help
        ;;
esac
