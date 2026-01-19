#!/bin/bash

# Project Manager for Dockerin
# Manage multiple Docker projects

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
PROJECTS_DIR="$HOME/.dockerin/projects"
PROJECTS_FILE="$PROJECTS_DIR/projects.json"

# Initialize
init() {
    mkdir -p "$PROJECTS_DIR"
    if [ ! -f "$PROJECTS_FILE" ]; then
        echo "{}" > "$PROJECTS_FILE"
    fi
}

# List projects
list_projects() {
    init
    
    echo -e "${CYAN}Registered Projects:${NC}\n"
    
    if [ ! -s "$PROJECTS_FILE" ] || [ "$(cat "$PROJECTS_FILE")" = "{}" ]; then
        echo -e "${YELLOW}No projects registered${NC}"
        return 0
    fi
    
    # Parse and display projects
    local projects=$(cat "$PROJECTS_FILE")
    
    # Simple JSON parsing (basic implementation)
    echo "$projects" | grep -o '"[^"]*":' | sed 's/"//g' | sed 's/://g' | while read project; do
        local path=$(echo "$projects" | grep -o "\"$project\":\"[^\"]*\"" | cut -d'"' -f4)
        local status="stopped"
        
        if [ -f "$path/docker-compose.yml" ]; then
            cd "$path"
            if docker-compose ps | grep -q "Up"; then
                status="running"
            fi
        fi
        
        echo -e "${GREEN}$project${NC} - $path (${status})"
    done
}

# Register project
register_project() {
    local project_name=$1
    local project_path=${2:-$(pwd)}
    
    if [ -z "$project_name" ]; then
        echo -e "${RED}Error: Project name is required${NC}" >&2
        return 1
    fi
    
    project_path=$(cd "$project_path" && pwd)
    
    if [ ! -f "$project_path/docker-compose.yml" ]; then
        echo -e "${RED}Error: docker-compose.yml not found in $project_path${NC}" >&2
        return 1
    fi
    
    init
    
    # Simple JSON update (basic implementation)
    local temp_file=$(mktemp)
    if [ -s "$PROJECTS_FILE" ] && [ "$(cat "$PROJECTS_FILE")" != "{}" ]; then
        cat "$PROJECTS_FILE" > "$temp_file"
    else
        echo "{}" > "$temp_file"
    fi
    
    # Add project (simple string replacement)
    if grep -q "\"$project_name\"" "$temp_file"; then
        echo -e "${YELLOW}Project already registered. Updating...${NC}"
    fi
    
    # This is a simplified version - in production, use jq or similar
    echo "{\"$project_name\": \"$project_path\"}" > "$PROJECTS_FILE"
    
    echo -e "${GREEN}✓ Project registered: $project_name${NC}"
}

# Switch project
switch_project() {
    local project_name=$1
    
    if [ -z "$project_name" ]; then
        echo -e "${RED}Error: Project name is required${NC}" >&2
        return 1
    fi
    
    init
    
    local path=$(cat "$PROJECTS_FILE" | grep -o "\"$project_name\":\"[^\"]*\"" | cut -d'"' -f4)
    
    if [ -z "$path" ]; then
        echo -e "${RED}Error: Project not found: $project_name${NC}" >&2
        return 1
    fi
    
    if [ ! -d "$path" ]; then
        echo -e "${RED}Error: Project directory not found: $path${NC}" >&2
        return 1
    fi
    
    cd "$path"
    echo -e "${GREEN}✓ Switched to project: $project_name${NC}"
    echo -e "${CYAN}Directory: $path${NC}"
}

# Delete project
delete_project() {
    local project_name=$1
    
    if [ -z "$project_name" ]; then
        echo -e "${RED}Error: Project name is required${NC}" >&2
        return 1
    fi
    
    echo -e "${YELLOW}Warning: This will only remove the project from registry, not delete files.${NC}"
    read -p "Continue? (y/n) [n]: " confirm
    
    if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
        echo "Cancelled"
        return 0
    fi
    
    init
    
    # Simple removal (basic implementation)
    echo "{}" > "$PROJECTS_FILE"
    
    echo -e "${GREEN}✓ Project removed from registry${NC}"
}

# Backup project config
backup_project() {
    local project_name=$1
    local backup_file=${2:-"backups/${project_name}_config_$(date +%Y%m%d_%H%M%S).tar.gz"}
    
    if [ -z "$project_name" ]; then
        echo -e "${RED}Error: Project name is required${NC}" >&2
        return 1
    fi
    
    init
    
    local path=$(cat "$PROJECTS_FILE" | grep -o "\"$project_name\":\"[^\"]*\"" | cut -d'"' -f4)
    
    if [ -z "$path" ] || [ ! -d "$path" ]; then
        echo -e "${RED}Error: Project not found${NC}" >&2
        return 1
    fi
    
    mkdir -p "$(dirname "$backup_file")"
    
    cd "$path"
    tar -czf "$backup_file" docker-compose.yml .env PROJECT_CONFIG.json PORT_MAPPING.txt 2>/dev/null
    
    if [ -f "$backup_file" ]; then
        echo -e "${GREEN}✓ Project config backed up to: $backup_file${NC}"
    else
        echo -e "${RED}✗ Backup failed${NC}"
        return 1
    fi
}

# Help
cmd_help() {
    echo -e "${CYAN}Dockerin Project Manager${NC}\n"
    echo "Usage: project-manager.sh [command] [options]"
    echo ""
    echo "Commands:"
    echo "  list                    List all registered projects"
    echo "  register <name> [path]  Register a project"
    echo "  switch <name>           Switch to a project"
    echo "  delete <name>           Remove project from registry"
    echo "  backup <name> [file]    Backup project configuration"
    echo "  help                    Show this help message"
    echo ""
}

# Main
init

COMMAND=${1:-help}

case $COMMAND in
    list)
        list_projects
        ;;
    register)
        register_project "$2" "$3"
        ;;
    switch)
        switch_project "$2"
        ;;
    delete)
        delete_project "$2"
        ;;
    backup)
        backup_project "$2" "$3"
        ;;
    help|*)
        cmd_help
        ;;
esac
