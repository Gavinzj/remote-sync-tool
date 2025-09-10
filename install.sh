#!/bin/bash

# Remote Sync Tool - Installation Script
# This script sets up the remote sync tool on your system

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}    Remote Sync Tool - Installation    ${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOOL_NAME="remote-sync-tool"

echo -e "${YELLOW}Installing Remote Sync Tool...${NC}"
echo ""

# Check if rsync is installed
if ! command -v rsync &> /dev/null; then
    echo -e "${RED}Error: rsync is not installed.${NC}"
    echo "Please install rsync first:"
    echo "  Ubuntu/Debian: sudo apt-get install rsync"
    echo "  CentOS/RHEL: sudo yum install rsync"
    echo "  macOS: brew install rsync"
    exit 1
fi

echo -e "${GREEN}✓ rsync is available${NC}"

# Check if SSH is available
if ! command -v ssh &> /dev/null; then
    echo -e "${RED}Error: SSH is not installed.${NC}"
    echo "Please install OpenSSH client first."
    exit 1
fi

echo -e "${GREEN}✓ SSH is available${NC}"

# Check if configuration exists
CONFIG_FILE="$SCRIPT_DIR/config/sync_config.sh"
if [ ! -f "$CONFIG_FILE" ]; then
    echo -e "${YELLOW}Configuration file not found. Creating from template...${NC}"
    if [ -f "$SCRIPT_DIR/config/sync_config.template" ]; then
        cp "$SCRIPT_DIR/config/sync_config.template" "$CONFIG_FILE"
        echo -e "${GREEN}✓ Configuration template copied${NC}"
        echo -e "${YELLOW}Please edit $CONFIG_FILE with your connection details${NC}"
    else
        echo -e "${RED}Error: Configuration template not found${NC}"
        exit 1
    fi
else
    echo -e "${GREEN}✓ Configuration file exists${NC}"
fi

# Make scripts executable
echo -e "${YELLOW}Setting up executable permissions...${NC}"
chmod +x "$SCRIPT_DIR/bin/"*.sh
chmod +x "$SCRIPT_DIR/install.sh"
echo -e "${GREEN}✓ Scripts are now executable${NC}"



echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}    Installation Complete!             ${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "1. Edit configuration: $CONFIG_FILE"
echo "2. Test connection: $SCRIPT_DIR/bin/sync.sh"
echo "3. Read documentation: $SCRIPT_DIR/README.md"
echo ""
echo -e "${BLUE}Quick start:${NC}"
echo "  $SCRIPT_DIR/bin/sync.sh push ./myfile.txt /remote/path/"
echo "  $SCRIPT_DIR/bin/sync.sh pull /remote/path/myfile.txt ./"
echo ""
echo -e "${YELLOW}Tool location: $SCRIPT_DIR${NC}"
