#!/bin/bash

# Dockerin Installer
# Install dockerin locally for easy access

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
INSTALL_DIR="$HOME/.dockerin"
GITHUB_REPO="irvandoda/dockerin"
GITHUB_BRANCH="${GITHUB_BRANCH:-main}"
BASE_URL="https://raw.githubusercontent.com/$GITHUB_REPO/$GITHUB_BRANCH"

# Check prerequisites
check_prerequisites() {
    local missing=()
    
    if ! command -v curl &> /dev/null && ! command -v wget &> /dev/null; then
        missing+=("curl or wget")
    fi
    
    if ! command -v bash &> /dev/null; then
        missing+=("bash")
    fi
    
    if [ ${#missing[@]} -gt 0 ]; then
        echo -e "${RED}Error: Missing prerequisites: ${missing[*]}${NC}" >&2
        return 1
    fi
    
    return 0
}

# Download file from GitHub
download_file() {
    local file_path=$1
    local output_path=$2
    local file_url="$BASE_URL/$file_path"
    
    echo -e "${BLUE}Downloading $file_path...${NC}" >&2
    
    if command -v curl &> /dev/null; then
        curl -s -f "$file_url" -o "$output_path"
    elif command -v wget &> /dev/null; then
        wget -q "$file_url" -O "$output_path"
    else
        echo -e "${RED}Error: curl or wget is required${NC}" >&2
        return 1
    fi
}

# Install dockerin
install_dockerin() {
    echo -e "${CYAN}Installing Dockerin...${NC}"
    
    # Create install directory
    mkdir -p "$INSTALL_DIR"
    
    # List of files to download
    local files=(
        "menu.sh"
        "bootstrap.sh"
        "tutorial.sh"
        "dev-tools.sh"
        "database-tools.sh"
        "generators/laravel-compose.sh"
        "utils/port-manager.sh"
        "utils/env-manager.sh"
        "utils/remote-loader.sh"
        "templates/nginx-laravel.conf"
        "templates/xdebug-config.ini"
        "templates/queue-worker.yml"
        "templates/mail-catcher.yml"
    )
    
    # Download files
    for file in "${files[@]}"; do
        local dir_path=$(dirname "$file")
        local file_name=$(basename "$file")
        
        if [ "$dir_path" != "." ]; then
            mkdir -p "$INSTALL_DIR/$dir_path"
            download_file "$file" "$INSTALL_DIR/$file"
        else
            download_file "$file" "$INSTALL_DIR/$file_name"
        fi
        
        # Make executable
        chmod +x "$INSTALL_DIR/$file" 2>/dev/null || chmod +x "$INSTALL_DIR/$file_name"
    done
    
    echo -e "${GREEN}✓ Files downloaded${NC}"
}

# Setup PATH and aliases
setup_path() {
    local shell_rc=""
    local shell_name=$(basename "$SHELL")
    
    case $shell_name in
        bash)
            shell_rc="$HOME/.bashrc"
            ;;
        zsh)
            shell_rc="$HOME/.zshrc"
            ;;
        fish)
            shell_rc="$HOME/.config/fish/config.fish"
            ;;
        *)
            shell_rc="$HOME/.profile"
            ;;
    esac
    
    # Create alias function
    local alias_func="
# Dockerin alias
dockerin() {
    if [ -f \"$INSTALL_DIR/menu.sh\" ]; then
        case \"\$1\" in
            start|menu)
                \"$INSTALL_DIR/menu.sh\" \"\${@:2}\"
                ;;
            dev-tools)
                \"$INSTALL_DIR/dev-tools.sh\" \"\${@:2}\"
                ;;
            tutorial)
                \"$INSTALL_DIR/tutorial.sh\" \"\${@:2}\"
                ;;
            db-tools|database-tools)
                \"$INSTALL_DIR/database-tools.sh\" \"\${@:2}\"
                ;;
            update)
                bash <(curl -s https://raw.githubusercontent.com/$GITHUB_REPO/main/install.sh)
                ;;
            *)
                \"$INSTALL_DIR/menu.sh\" \"\$@\"
                ;;
        esac
    else
        echo \"Dockerin not found. Please reinstall.\"
    fi
}
"
    
    # Add to shell config
    if [ -f "$shell_rc" ]; then
        if ! grep -q "dockerin()" "$shell_rc"; then
            echo "$alias_func" >> "$shell_rc"
            echo -e "${GREEN}✓ Added dockerin alias to $shell_rc${NC}"
        else
            echo -e "${YELLOW}Alias already exists in $shell_rc${NC}"
        fi
    else
        echo "$alias_func" > "$shell_rc"
        echo -e "${GREEN}✓ Created $shell_rc${NC}"
    fi
    
    # Create symlink in /usr/local/bin (requires sudo)
    if command -v sudo &> /dev/null; then
        echo -e "${YELLOW}Creating symlink in /usr/local/bin (may require password)...${NC}"
        sudo ln -sf "$INSTALL_DIR/menu.sh" /usr/local/bin/dockerin 2>/dev/null && \
            echo -e "${GREEN}✓ Created symlink${NC}" || \
            echo -e "${YELLOW}Could not create symlink (permission denied)${NC}"
    fi
}

# Main installation
main() {
    print_header() {
        echo -e "${CYAN}"
        echo "╔════════════════════════════════════════════════════════════╗"
        echo "║              Dockerin Installation                       ║"
        echo "╚════════════════════════════════════════════════════════════╝"
        echo -e "${NC}\n"
    }
    
    print_header
    
    # Check prerequisites
    if ! check_prerequisites; then
        exit 1
    fi
    
    # Install
    install_dockerin
    
    # Setup PATH
    setup_path
    
    echo -e "\n${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}✓ Installation complete!${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "\n${CYAN}Usage:${NC}"
    echo "  dockerin start      # Start interactive menu"
    echo "  dockerin dev-tools  # Development tools"
    echo "  dockerin tutorial   # Interactive tutorial"
    echo ""
    echo -e "${YELLOW}Note: Please restart your terminal or run: source ~/.bashrc${NC}"
    echo ""
}

main
