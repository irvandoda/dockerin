#!/bin/bash

# Shortcut script to start menu
# Usage: curl -sL https://raw.githubusercontent.com/irvandoda/dockerin/main/start.sh | bash

# Check if running locally
if [ -f "$(dirname "${BASH_SOURCE[0]}")/menu.sh" ]; then
    "$(dirname "${BASH_SOURCE[0]}")/menu.sh" "$@"
else
    # Load from GitHub
    bash <(curl -s https://raw.githubusercontent.com/irvandoda/dockerin/main/bootstrap.sh) menu "$@"
fi
