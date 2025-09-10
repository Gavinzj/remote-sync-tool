# Remote Sync Tool Configuration
# This file contains your actual connection details

# Connection details for your nested SSH setup
JUMPER_HOST="server"
TARGET_USER="ma-user"

# Multiple target hosts - use short names for easy selection
declare -A TARGET_HOSTS=(
    ["231"]="192.168.0.231"
    ["180"]="192.168.0.180"
    ["21"]="192.168.0.21"
    ["41"]="192.168.0.41"
    ["127"]="192.168.0.127"
    ["139"]="192.168.0.139"
    ["162"]="192.168.0.162"
    ["198"]="192.168.0.198"
    ["235"]="192.168.0.235"
)

# Default target host (if no machine specified)
DEFAULT_TARGET="231"

# Optional: Custom SSH options
SSH_OPTIONS="-o ConnectTimeout=30 -o ServerAliveInterval=60"

# Optional: Custom rsync options
RSYNC_OPTIONS="-avz --progress"

# Optional: Default remote path
DEFAULT_REMOTE_PATH="/home/ma-user"

# Optional: Default local path
DEFAULT_LOCAL_PATH="./"
