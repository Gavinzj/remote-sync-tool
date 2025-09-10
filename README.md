# Remote Sync Tool

A portable, configurable file synchronization tool for nested SSH environments. Perfect for editing files locally in your favorite editor (like Cursor) and syncing them to remote machines through jump hosts.

## 🚀 Features

- **Nested SSH Support**: Works through jump hosts/bastion servers
- **Multi-Machine Support**: Easy selection of target machines with 3-digit codes
- **Configurable**: Easy setup for different environments
- **Portable**: Self-contained tool that can be moved anywhere
- **Progress Tracking**: Visual progress indicators for file transfers
- **Error Handling**: Comprehensive error checking and reporting
- **Backward Compatible**: Old commands still work

## 📁 Directory Structure

```
remote-sync-tool/
├── README.md                 # This file
├── install.sh               # Installation script (optional)
├── package.sh               # Create portable archive
├── bin/                     # Executable scripts
│   ├── sync.sh              # Main unified sync script
│   └── setup_remote_editing.sh # Setup diagnostics
├── config/                  # Configuration files
│   ├── sync_config.template # Configuration template
│   └── sync_config.sh       # Your actual configuration
└── examples/                # Example scripts
    └── example_usage.sh     # Usage examples
```

## 🛠️ Installation

1. **Clone or download** this tool to your desired location
2. **Configure your connection** by editing `config/sync_config.sh`
3. **Test the setup**: `./bin/sync.sh`

**Note**: `install.sh` is optional - you can use the tool directly!

## ⚙️ Configuration

Edit `config/sync_config.sh` with your connection details

## 📖 Usage

### Command Syntax

#### With Machine Selection (Recommended)
```bash
./bin/sync.sh [push|pull] [machine_code] [local_path] [remote_path]
```

#### Without Machine Selection (Uses Default)
```bash
./bin/sync.sh [push|pull] [local_path] [remote_path]
```


## 🎯 Common Workflows

#### File Operations
```bash
# Send a file to machine 180
./bin/sync.sh push 180 ./config.txt /home/ma-user/

# Get a file from machine 162
./bin/sync.sh pull 162 /home/ma-user/result.txt ./

# Send entire project to machine 21
./bin/sync.sh push 21 ./myproject/ /home/ma-user/myproject/
```

#### Directory Operations
```bash
# Push current directory to machine 127
./bin/sync.sh push 127 ./ /home/ma-user/current_project/

# Pull back results from machine 127
./bin/sync.sh pull 127 /home/ma-user/results/ ./results/
```


## 🔧 Advanced Usage

### Custom SSH Options
Add custom SSH options for specific needs:

```bash
SSH_OPTIONS="-o ConnectTimeout=30 -o ServerAliveInterval=60 -o StrictHostKeyChecking=no"
```

### Custom Rsync Options
Customize rsync behavior:

```bash
RSYNC_OPTIONS="-avz --progress --exclude='*.tmp' --exclude='.git'"
```

## 🔍 Troubleshooting

### Connection Issues
```bash
# Test SSH connection manually
ssh -J server ma-user@192.168.0.231

# Check available machines
./bin/sync.sh

# Check network connectivity
ssh server "ping -c 3 192.168.0.231"
```

## 🤝 Contributing

This tool is designed to be easily customizable. Feel free to:

- Add new features to the scripts
- Create additional configuration templates
- Improve error handling
- Add support for different protocols

## 📄 License

This tool is designed and implemented by Zijin Feng, with the helps of Cursor.

---

**Happy Syncing!** 🚀