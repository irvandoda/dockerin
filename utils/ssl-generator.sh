#!/bin/bash

# SSL Certificate Generator
# Generate SSL certificates for local development using mkcert

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if mkcert is installed
check_mkcert() {
    if command -v mkcert &> /dev/null; then
        return 0
    fi
    return 1
}

# Install mkcert
install_mkcert() {
    echo -e "${BLUE}Installing mkcert...${NC}"
    
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get update
            sudo apt-get install -y libnss3-tools
        elif command -v yum &> /dev/null; then
            sudo yum install -y nss-tools
        fi
        
        if command -v wget &> /dev/null; then
            wget -O /tmp/mkcert https://github.com/FiloSottile/mkcert/releases/latest/download/mkcert-v1.4.4-linux-amd64
        elif command -v curl &> /dev/null; then
            curl -L -o /tmp/mkcert https://github.com/FiloSottile/mkcert/releases/latest/download/mkcert-v1.4.4-linux-amd64
        fi
        
        chmod +x /tmp/mkcert
        sudo mv /tmp/mkcert /usr/local/bin/mkcert
        
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        if command -v brew &> /dev/null; then
            brew install mkcert
        else
            echo -e "${RED}Error: Homebrew is required. Install from https://brew.sh${NC}"
            return 1
        fi
    elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
        if command -v choco &> /dev/null; then
            choco install mkcert
        else
            echo -e "${RED}Error: Chocolatey is required. Install from https://chocolatey.org${NC}"
            return 1
        fi
    fi
    
    echo -e "${GREEN}✓ mkcert installed${NC}"
}

# Install CA
install_ca() {
    if ! check_mkcert; then
        echo -e "${RED}Error: mkcert is not installed${NC}"
        return 1
    fi
    
    echo -e "${BLUE}Installing local CA...${NC}"
    mkcert -install
    echo -e "${GREEN}✓ Local CA installed${NC}"
}

# Generate certificates
generate_certificates() {
    local domains=$1
    local output_dir=${2:-./ssl}
    
    if ! check_mkcert; then
        echo -e "${RED}Error: mkcert is not installed${NC}"
        read -p "Do you want to install mkcert? (y/n) [y]: " install
        if [ "$install" != "n" ] && [ "$install" != "N" ]; then
            install_mkcert
            install_ca
        else
            return 1
        fi
    fi
    
    mkdir -p "$output_dir"
    
    echo -e "${BLUE}Generating SSL certificates...${NC}"
    
    # Default domains
    if [ -z "$domains" ]; then
        domains="localhost 127.0.0.1 ::1"
    fi
    
    # Generate certificate
    mkcert -cert-file "$output_dir/cert.pem" \
           -key-file "$output_dir/key.pem" \
           $domains
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Certificates generated in $output_dir${NC}"
        echo -e "${CYAN}Certificate: $output_dir/cert.pem${NC}"
        echo -e "${CYAN}Private Key: $output_dir/key.pem${NC}"
        return 0
    else
        echo -e "${RED}✗ Certificate generation failed${NC}"
        return 1
    fi
}

# Main
main() {
    local domains=$1
    local output_dir=$2
    
    if [ -z "$domains" ]; then
        echo "Usage: ssl-generator.sh [domains] [output_dir]"
        echo "Example: ssl-generator.sh 'localhost *.test' ./ssl"
        echo ""
        read -p "Enter domains (space-separated, or press Enter for default): " user_domains
        domains=${user_domains:-"localhost 127.0.0.1 ::1"}
    fi
    
    output_dir=${output_dir:-./ssl}
    
    # Check/install mkcert
    if ! check_mkcert; then
        echo -e "${YELLOW}mkcert is not installed${NC}"
        read -p "Do you want to install mkcert? (y/n) [y]: " install
        if [ "$install" != "n" ] && [ "$install" != "N" ]; then
            install_mkcert
            install_ca
        else
            echo "Cancelled"
            exit 0
        fi
    else
        # Install CA if not already installed
        install_ca
    fi
    
    # Generate certificates
    generate_certificates "$domains" "$output_dir"
}

main "$@"
