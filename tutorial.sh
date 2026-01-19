#!/bin/bash

# Interactive Tutorial for Dockerin
# Step-by-step guide from setup to running application

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Print header
print_header() {
    clear
    echo -e "${CYAN}"
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║         Dockerin - Interactive Setup Tutorial            ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# Print section
print_section() {
    local title=$1
    echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}$title${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
}

# Wait for user
wait_for_user() {
    echo -e "\n${YELLOW}Press Enter to continue...${NC}"
    read
}

# Check command exists
check_command() {
    local cmd=$1
    if command -v "$cmd" &> /dev/null; then
        echo -e "${GREEN}✓ $cmd is installed${NC}"
        return 0
    else
        echo -e "${RED}✗ $cmd is not installed${NC}"
        return 1
    fi
}

# Step 1: Prerequisites
step_prerequisites() {
    print_section "Step 1: Prerequisites Check"
    
    echo "Checking required tools..."
    echo ""
    
    local all_ok=true
    
    if ! check_command "docker"; then
        echo -e "${YELLOW}Please install Docker from: https://docs.docker.com/get-docker/${NC}"
        all_ok=false
    fi
    
    if ! check_command "docker-compose"; then
        echo -e "${YELLOW}Please install Docker Compose from: https://docs.docker.com/compose/install/${NC}"
        all_ok=false
    fi
    
    if ! check_command "git"; then
        echo -e "${YELLOW}Please install Git from: https://git-scm.com/downloads${NC}"
        all_ok=false
    fi
    
    echo ""
    if [ "$all_ok" = true ]; then
        echo -e "${GREEN}All prerequisites are installed!${NC}"
    else
        echo -e "${RED}Please install missing prerequisites before continuing.${NC}"
        wait_for_user
        return 1
    fi
    
    wait_for_user
    return 0
}

# Step 2: Generate docker-compose.yml
step_generate() {
    print_section "Step 2: Generate Docker Compose Configuration"
    
    echo "Now we'll generate your docker-compose.yml file."
    echo "This will ask you several questions about your project setup."
    echo ""
    
    wait_for_user
    
    if [ -f "$SCRIPT_DIR/menu.sh" ]; then
        "$SCRIPT_DIR/menu.sh"
    else
        echo -e "${RED}Error: menu.sh not found${NC}"
        return 1
    fi
    
    wait_for_user
    return 0
}

# Step 3: Setup Laravel Project
step_laravel_setup() {
    print_section "Step 3: Setup Laravel Project"
    
    echo "You have two options:"
    echo "1. Create a new Laravel project"
    echo "2. Use an existing Laravel project"
    echo ""
    read -p "Choose option [1]: " choice
    
    if [ "$choice" = "2" ]; then
        echo -e "${YELLOW}Make sure your existing Laravel project is in the project directory.${NC}"
        wait_for_user
        return 0
    fi
    
    echo ""
    echo "To create a new Laravel project, run:"
    echo -e "${CYAN}composer create-project laravel/laravel .${NC}"
    echo ""
    echo "Or if you prefer to use Docker:"
    echo -e "${CYAN}docker-compose exec php composer create-project laravel/laravel .${NC}"
    echo ""
    
    read -p "Do you want to create Laravel project now? (y/n) [n]: " create_now
    if [ "$create_now" = "y" ] || [ "$create_now" = "Y" ]; then
        echo ""
        echo "Creating Laravel project..."
        if command -v composer &> /dev/null; then
            composer create-project laravel/laravel .
        else
            echo -e "${YELLOW}Composer not found. Please install Composer or use Docker method.${NC}"
        fi
    fi
    
    wait_for_user
    return 0
}

# Step 4: Configure Environment
step_configure_env() {
    print_section "Step 4: Configure Environment"
    
    echo "The .env file should have been generated automatically."
    echo "If not, you can create it manually or copy from .env.example"
    echo ""
    echo "Important: Make sure your .env file has correct database credentials."
    echo ""
    
    wait_for_user
    return 0
}

# Step 5: Start Containers
step_start_containers() {
    print_section "Step 5: Start Docker Containers"
    
    echo "Now we'll start the Docker containers."
    echo ""
    echo "Commands to run:"
    echo -e "${CYAN}docker-compose up -d${NC}"
    echo ""
    echo "This will:"
    echo "  - Build the Docker images"
    echo "  - Start all services (PHP, Nginx, Database, etc.)"
    echo "  - Run in detached mode (-d)"
    echo ""
    
    read -p "Do you want to start containers now? (y/n) [y]: " start_now
    if [ "$start_now" != "n" ] && [ "$start_now" != "N" ]; then
        echo ""
        echo "Starting containers..."
        docker-compose up -d
        echo ""
        echo -e "${GREEN}Containers started!${NC}"
    fi
    
    wait_for_user
    return 0
}

# Step 6: Install Dependencies
step_install_dependencies() {
    print_section "Step 6: Install Laravel Dependencies"
    
    echo "Install Composer dependencies:"
    echo -e "${CYAN}docker-compose exec php composer install${NC}"
    echo ""
    
    read -p "Do you want to install dependencies now? (y/n) [y]: " install_now
    if [ "$install_now" != "n" ] && [ "$install_now" != "N" ]; then
        echo ""
        echo "Installing dependencies..."
        docker-compose exec php composer install
        echo ""
        echo -e "${GREEN}Dependencies installed!${NC}"
    fi
    
    wait_for_user
    return 0
}

# Step 7: Laravel Setup
step_laravel_setup_commands() {
    print_section "Step 7: Laravel Initial Setup"
    
    echo "Run these Laravel setup commands:"
    echo ""
    echo "1. Generate application key:"
    echo -e "${CYAN}docker-compose exec php php artisan key:generate${NC}"
    echo ""
    echo "2. Run database migrations:"
    echo -e "${CYAN}docker-compose exec php php artisan migrate${NC}"
    echo ""
    echo "3. (Optional) Seed database:"
    echo -e "${CYAN}docker-compose exec php php artisan db:seed${NC}"
    echo ""
    
    read -p "Do you want to run these commands now? (y/n) [y]: " run_now
    if [ "$run_now" != "n" ] && [ "$run_now" != "N" ]; then
        echo ""
        echo "Generating application key..."
        docker-compose exec php php artisan key:generate
        echo ""
        echo "Running migrations..."
        docker-compose exec php php artisan migrate
        echo ""
        echo -e "${GREEN}Laravel setup complete!${NC}"
    fi
    
    wait_for_user
    return 0
}

# Step 8: Testing
step_testing() {
    print_section "Step 8: Test Your Application"
    
    echo "Your application should now be running!"
    echo ""
    echo "Access your application at:"
    echo -e "${CYAN}http://localhost:80${NC}"
    echo ""
    echo "Or check PORT_MAPPING.txt for the exact port."
    echo ""
    echo "You can also test with curl:"
    echo -e "${CYAN}curl http://localhost:80${NC}"
    echo ""
    
    read -p "Do you want to test the application now? (y/n) [y]: " test_now
    if [ "$test_now" != "n" ] && [ "$test_now" != "N" ]; then
        echo ""
        echo "Testing application..."
        if command -v curl &> /dev/null; then
            curl -s http://localhost:80 | head -20
            echo ""
            echo -e "${GREEN}Application is responding!${NC}"
        else
            echo -e "${YELLOW}Curl not found. Please test manually in your browser.${NC}"
        fi
    fi
    
    wait_for_user
    return 0
}

# Step 9: Troubleshooting
step_troubleshooting() {
    print_section "Step 9: Troubleshooting Guide"
    
    echo "Common issues and solutions:"
    echo ""
    echo "1. Containers won't start:"
    echo "   - Check if ports are already in use"
    echo "   - Run: docker-compose logs"
    echo ""
    echo "2. Database connection error:"
    echo "   - Check .env file has correct database credentials"
    echo "   - Make sure database container is running"
    echo "   - Run: docker-compose ps"
    echo ""
    echo "3. Permission errors:"
    echo "   - Run: docker-compose exec php chown -R www-data:www-data /var/www/html/storage"
    echo "   - Run: docker-compose exec php chmod -R 775 /var/www/html/storage"
    echo ""
    echo "4. View logs:"
    echo "   - All services: docker-compose logs"
    echo "   - Specific service: docker-compose logs php"
    echo ""
    echo "5. Restart services:"
    echo "   - docker-compose restart"
    echo "   - docker-compose restart php"
    echo ""
    
    wait_for_user
    return 0
}

# Main menu
main_menu() {
    while true; do
        print_header
        echo "Select tutorial option:"
        echo ""
        echo "1) Full Tutorial (Step by step)"
        echo "2) Quick Start (Skip to essentials)"
        echo "3) Troubleshooting Guide"
        echo "4) Exit"
        echo ""
        read -p "Choice [1]: " choice
        
        case $choice in
            2)
                step_prerequisites && \
                step_generate && \
                step_start_containers && \
                step_install_dependencies && \
                step_laravel_setup_commands && \
                step_testing
                ;;
            3)
                step_troubleshooting
                ;;
            4)
                echo -e "${GREEN}Goodbye!${NC}"
                exit 0
                ;;
            *)
                step_prerequisites && \
                step_generate && \
                step_laravel_setup && \
                step_configure_env && \
                step_start_containers && \
                step_install_dependencies && \
                step_laravel_setup_commands && \
                step_testing && \
                step_troubleshooting
                ;;
        esac
        
        echo ""
        read -p "Do you want to run another tutorial? (y/n) [n]: " again
        if [ "$again" != "y" ] && [ "$again" != "Y" ]; then
            break
        fi
    done
}

# Run main menu
main_menu
