#!/bin/bash

# Introductory ASCII Art and Pause
echo "
                        ████████╗██╗  ██╗███████╗            
                        ╚══██╔══╝██║  ██║██╔════╝            
                           ██║   ███████║█████╗              
                           ██║   ██╔══██║██╔══╝              
                           ██║   ██║  ██║███████╗            
                           ╚═╝   ╚═╝  ╚═╝╚══════╝            
                                                             
        ███╗   ██╗██╗  ██╗ █████╗ ███████╗███████╗           
        ████╗  ██║██║  ██║██╔══██╗██╔════╝██╔════╝           
        ██╔██╗ ██║███████║███████║███████╗███████╗           
        ██║╚██╗██║╚════██║██╔══██║╚════██║╚════██║           
        ██║ ╚████║     ██║██║  ██║███████║███████║           
        ╚═╝  ╚═══╝     ╚═╝╚═╝  ╚═╝╚══════╝╚══════╝           
                                                             
                        ███╗   ███╗ █████╗ ███╗   ██╗        
                        ████╗ ████║██╔══██╗████╗  ██║        
                        ██╔████╔██║███████║██╔██╗ ██║        
                        ██║╚██╔╝██║██╔══██║██║╚██╗██║        
                        ██║ ╚═╝ ██║██║  ██║██║ ╚████║        
                        ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝        
                                                             
██╗    ██╗██████╗  ██████╗  ██████╗ ██████╗  ██████╗  █████╗ 
██║    ██║██╔══██╗██╔═══██╗██╔════╝ ╚════██╗██╔═████╗██╔══██╗
██║ █╗ ██║██████╔╝██║   ██║██║  ███╗ █████╔╝██║██╔██║╚█████╔╝
██║███╗██║██╔══██╗██║   ██║██║   ██║██╔═══╝ ████╔╝██║██╔══██╗
╚███╔███╔╝██║  ██║╚██████╔╝╚██████╔╝███████╗╚██████╔╝╚█████╔╝
 ╚══╝╚══╝ ╚═╝  ╚═╝ ╚═════╝  ╚═════╝ ╚══════╝ ╚═════╝  ╚════╝ 
                                                             
"

# Pause for 5 seconds
sleep 5


# Backup/Restore to USB thumb drive Script
# Install and Restore Script for Backup to USB drive on Raspberry Pi
# This script installs essential files and dependencies, and runs the initial backup after installation.
# 11/03/2024
# Created By WROG208 \ N4ASS
# www.lonewolfsystem.org

TARGET_DIR="/usr/local/bin"
CONFIG_DIR="/usr/local/bin"
LOG_DIR="/backup/logs"
HOSTNAME=$(hostname)

# Ensure the script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "Please run this script as root (e.g., with sudo)."
    exit 1
fi

# Inform the user about the installation and prompt for confirmation
echo "This script will install the following packages and dependencies:"
echo "1. dos2unix - Ensures files have Unix (LF) line endings."
echo "2. zip & unzip - For compressing and extracting files."
echo "3. dosfstools - For managing VFAT file systems."
echo "4. Python and related libraries:"
echo "   - python"
echo "   - python-pip"
echo "   - python-setuptools"
echo "   - python-packaging"
echo "   - python-pyparsing"
echo "   - python-six"
echo
read -p "Do you wish to proceed with the installation? (y/n): " user_confirm
if [[ "$user_confirm" != "y" && "$user_confirm" != "Y" ]]; then
    echo "Installation aborted by user."
    exit 0
fi

echo "Installing necessary system packages silently..."
if ! command -v dos2unix &> /dev/null; then
    pacman -Sy --noconfirm dos2unix
fi
if ! command -v zip &> /dev/null || ! command -v unzip &> /dev/null; then
    pacman -Sy --noconfirm zip unzip
fi
if ! command -v mkfs.vfat &> /dev/null; then
    pacman -Sy --noconfirm dosfstools
fi
if ! command -v python &> /dev/null || ! command -v pip &> /dev/null; then
    pacman -Sy --noconfirm python python-pip python-setuptools python-packaging python-pyparsing python-six
fi

# Convert files to Unix (LF) line endings
convert_to_unix() {
    for file in backup_to_usb.sh backup_config.conf; do
        if file "$file" | grep -q "CRLF"; then
            echo "Converting $file to Unix (LF) line endings..."
            dos2unix "$file"
        fi
    done
}
convert_to_unix

echo "Creating log directory at $LOG_DIR..."
mkdir -p "$LOG_DIR"

echo "Copying files..."
cp backup_to_usb.sh "$TARGET_DIR/"
cp backup_config.conf "$CONFIG_DIR/"

echo "Setting permissions..."
chmod +x "$TARGET_DIR/backup_to_usb.sh"
chmod 644 "$CONFIG_DIR/backup_config.conf"

# Set up cron job for weekly backups
CRON_JOB="30 0 * * 5 $TARGET_DIR/backup_to_usb.sh backup"
if ! crontab -l | grep -qF "$CRON_JOB"; then
    echo "Setting up a cron job for weekly backups..."
    (crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab -
    echo "Cron job set to run weekly at 12:30 AM every Friday."
else
    echo "Cron job already exists. Skipping setup."
fi

echo "Installation complete! The backup environment is now ready on this Pi."
