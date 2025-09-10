#!/bin/bash

# Remote Sync Tool - Unified sync script
# Usage: 
#   ./sync.sh [push|pull] [local_path] [remote_path]  # Direct sync
#   ./sync.sh                                          # Interactive mode

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOOL_DIR="$(dirname "$SCRIPT_DIR")"

# Load configuration
CONFIG_FILE="$TOOL_DIR/config/sync_config.sh"
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: Configuration file not found at $CONFIG_FILE"
    echo "Please copy config/sync_config.template to config/sync_config.sh and configure it."
    exit 1
fi

# Source the configuration
source "$CONFIG_FILE"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to show usage
show_usage() {
    echo -e "${BLUE}Remote Sync Tool${NC}"
    echo -e "${YELLOW}Usage: $0 [push|pull] [machine] [local_path] [remote_path]${NC}"
    echo ""
    echo "Examples:"
    echo "  $0 push 231 ./myfile.txt ${DEFAULT_REMOTE_PATH}/"
    echo "  $0 pull 180 ${DEFAULT_REMOTE_PATH}/myfile.txt ./"
    echo "  $0 push 21 ./project/ ${DEFAULT_REMOTE_PATH}/project/"
    echo ""
    echo "Note: For pull operations, the syntax is: pull machine remote_path local_path"
    echo ""
    echo "Available machines:"
    for machine in "${!TARGET_HOSTS[@]}"; do
        echo "  $machine -> ${TARGET_HOSTS[$machine]}"
    done
    echo ""
    echo "Actions:"
    echo "  push: sync local files to remote target machine"
    echo "  pull: sync remote files from target machine to local"
    echo ""
    echo -e "${BLUE}Current Configuration:${NC}"
    echo "  Jumper Host: $JUMPER_HOST"
    echo "  Target User: $TARGET_USER"
    echo "  Default Remote Path: $DEFAULT_REMOTE_PATH"
    echo "  Default Machine: $DEFAULT_TARGET (${TARGET_HOSTS[$DEFAULT_TARGET]})"
}

# Function to show interactive helper
show_interactive_helper() {
    echo -e "${BLUE}=== Remote Sync Tool - Interactive Helper ===${NC}"
    echo ""
    
    # Get current directory name for project sync
    CURRENT_DIR=$(basename "$PWD")
    
    echo -e "${BLUE}Current Configuration:${NC}"
    echo "  Jumper Host: $JUMPER_HOST"
    echo "  Target User: $TARGET_USER"
    echo "  Default Remote Path: $DEFAULT_REMOTE_PATH"
    echo "  Default Machine: $DEFAULT_TARGET (${TARGET_HOSTS[$DEFAULT_TARGET]})"
    echo ""
    
    echo "Available machines:"
    for machine in "${!TARGET_HOSTS[@]}"; do
        echo "  $machine -> ${TARGET_HOSTS[$machine]}"
    done
    echo ""
    
    echo "Available quick operations:"
    echo ""
    echo "1. Sync current directory to target machine:"
    echo "   $0 push 231 ./ $DEFAULT_REMOTE_PATH/$CURRENT_DIR/"
    echo ""
    echo "2. Pull entire project from target machine:"
    echo "   $0 pull 180 $DEFAULT_REMOTE_PATH/$CURRENT_DIR/ ./"
    echo ""
    echo "3. Sync a specific file:"
    echo "   $0 push 21 ./filename.txt $DEFAULT_REMOTE_PATH/"
    echo ""
    echo "4. Pull a specific file:"
    echo "   $0 pull 127 $DEFAULT_REMOTE_PATH/filename.txt ./"
    echo ""
    
    # Interactive mode
    read -p "Do you want to sync the current directory to target machine? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Syncing current directory to default machine ($DEFAULT_TARGET)...${NC}"
        perform_sync "push" "$DEFAULT_TARGET" "./" "$DEFAULT_REMOTE_PATH/$CURRENT_DIR/"
    fi
}

# Function to perform the actual sync
perform_sync() {
    local ACTION=$1
    local MACHINE=$2
    local LOCAL_PATH=$3
    local REMOTE_PATH=$4
    
    # Get the target host IP from machine name
    if [ -z "${TARGET_HOSTS[$MACHINE]}" ]; then
        echo -e "${RED}Error: Unknown machine '$MACHINE'${NC}"
        echo "Available machines: ${!TARGET_HOSTS[*]}"
        exit 1
    fi
    
    local TARGET_HOST="${TARGET_HOSTS[$MACHINE]}"
    
    # Check if rsync is available
    if ! command -v rsync &> /dev/null; then
        echo -e "${RED}Error: rsync is not installed. Please install it first.${NC}"
        exit 1
    fi
    
    # Build SSH command with options
    SSH_CMD="ssh -J $JUMPER_HOST"
    if [ -n "$SSH_OPTIONS" ]; then
        SSH_CMD="$SSH_CMD $SSH_OPTIONS"
    fi
    
    # Build rsync command with options
    RSYNC_CMD="rsync"
    if [ -n "$RSYNC_OPTIONS" ]; then
        RSYNC_CMD="$RSYNC_CMD $RSYNC_OPTIONS"
    else
        RSYNC_CMD="$RSYNC_CMD -avz --progress"
    fi
    
    if [ "$ACTION" = "push" ]; then
        echo -e "${GREEN}Pushing $LOCAL_PATH to remote $REMOTE_PATH...${NC}"
        echo -e "${YELLOW}Connection: Local → $JUMPER_HOST → $TARGET_USER@$TARGET_HOST${NC}"
        $RSYNC_CMD -e "$SSH_CMD" "$LOCAL_PATH" "$TARGET_USER@$TARGET_HOST:$REMOTE_PATH"
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✓ Push completed successfully!${NC}"
        else
            echo -e "${RED}✗ Push failed!${NC}"
            exit 1
        fi
    elif [ "$ACTION" = "pull" ]; then
        echo -e "${GREEN}Pulling $REMOTE_PATH from remote to local $LOCAL_PATH...${NC}"
        echo -e "${YELLOW}Connection: $TARGET_USER@$TARGET_HOST → $JUMPER_HOST → Local${NC}"
        
        # For pull operations, ensure the local destination directory exists
        # Only create directory if it's a relative path or in user's home
        if [ ! -d "$LOCAL_PATH" ]; then
            # Check if it's a relative path or in user's home directory
            if [[ "$LOCAL_PATH" == ./* ]] || [[ "$LOCAL_PATH" == ~/* ]] || [[ "$LOCAL_PATH" == "$HOME"/* ]]; then
                echo -e "${YELLOW}Creating local directory: $LOCAL_PATH${NC}"
                mkdir -p "$LOCAL_PATH"
            else
                echo -e "${YELLOW}Warning: Cannot create directory $LOCAL_PATH (permission denied)${NC}"
                echo -e "${YELLOW}Please create the directory manually or use a different path${NC}"
            fi
        fi
        
        $RSYNC_CMD -e "$SSH_CMD" "$TARGET_USER@$TARGET_HOST:$REMOTE_PATH" "$LOCAL_PATH"
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✓ Pull completed successfully!${NC}"
        else
            echo -e "${RED}✗ Pull failed!${NC}"
            exit 1
        fi
    else
        echo -e "${RED}Invalid action. Use 'push' or 'pull'${NC}"
        exit 1
    fi
}

# Main logic
if [ $# -eq 0 ]; then
    # No arguments - show interactive helper
    show_interactive_helper
elif [ $# -eq 4 ]; then
    # Four arguments - perform direct sync with machine
    ACTION=$1
    MACHINE=$2
    if [ "$ACTION" = "pull" ]; then
        # For pull: ./sync.sh pull machine remote_path local_path
        REMOTE_PATH=$3
        LOCAL_PATH=$4
    else
        # For push: ./sync.sh push machine local_path remote_path
        LOCAL_PATH=$3
        REMOTE_PATH=$4
    fi
    perform_sync "$ACTION" "$MACHINE" "$LOCAL_PATH" "$REMOTE_PATH"
elif [ $# -eq 3 ]; then
    # Three arguments - use default machine
    ACTION=$1
    if [ "$ACTION" = "pull" ]; then
        # For pull: ./sync.sh pull remote_path local_path
        REMOTE_PATH=$2
        LOCAL_PATH=$3
    else
        # For push: ./sync.sh push local_path remote_path
        LOCAL_PATH=$2
        REMOTE_PATH=$3
    fi
    echo -e "${YELLOW}Using default machine: $DEFAULT_TARGET (${TARGET_HOSTS[$DEFAULT_TARGET]})${NC}"
    perform_sync "$ACTION" "$DEFAULT_TARGET" "$LOCAL_PATH" "$REMOTE_PATH"
else
    # Wrong number of arguments - show usage
    show_usage
    exit 1
fi
