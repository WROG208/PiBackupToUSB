#!/bin/bash

# Install Script for Backup System on Raspberry Pi


TARGET_DIR="/usr/local/bin"
CONFIG_DIR="/usr/local/bin"
LOG_DIR="/backup/logs"
HOSTNAME=$(hostname)
USB_DEVICE="/dev/sda1"
USB_MOUNT_POINT="/mnt/usb"


if [ "$(id -u)" -ne 0 ]; then
    echo "Please run this script as root (e.g., with sudo)."
    exit 1
fi


if ! command -v dos2unix &> /dev/null; then
    echo "Installing dos2unix for line ending conversion..."
    pacman -Sy --noconfirm dos2unix
fi


convert_to_unix() {
    for file in backup_to_usb.sh setup.sh backup_config.conf; do
        if file "$file" | grep -q "CRLF"; then
            echo "Converting $file to Unix (LF) line endings..."
            dos2unix "$file"
        fi
    done
}


convert_to_unix


if [ ! -d "$USB_MOUNT_POINT" ]; then
    echo "Creating USB mount point at $USB_MOUNT_POINT..."
    mkdir -p "$USB_MOUNT_POINT"
fi


if mount | grep -q "$USB_MOUNT_POINT"; then
    echo "USB drive is already mounted at $USB_MOUNT_POINT."
else

    echo "USB drive not mounted. Attempting to mount at $USB_MOUNT_POINT..."
    mount "$USB_DEVICE" "$USB_MOUNT_POINT"
    

    if [ $? -eq 0 ]; then
        echo "USB drive successfully mounted at $USB_MOUNT_POINT."
    else
        echo "Error: Unable to mount USB drive. Proceeding without USB backup."
    fi
fi


if mount | grep -q "$USB_MOUNT_POINT"; then
    echo "Creating a backup copy of files on the USB drive..."
    USB_BACKUP_DIR="$USB_MOUNT_POINT/BackupFiles"
    mkdir -p "$USB_BACKUP_DIR"
    cp backup_to_usb.sh setup.sh backup_config.conf "$USB_BACKUP_DIR/"
else
    echo "Warning: No USB drive detected or mount failed. Essential files will not be backed up to USB."
fi


echo "Creating log directory at $LOG_DIR..."
mkdir -p "$LOG_DIR"


echo "Copying files..."
cp backup_to_usb.sh "$TARGET_DIR/"
cp setup.sh "$TARGET_DIR/"
cp backup_config.conf "$CONFIG_DIR/"


echo "Setting permissions..."
chmod +x "$TARGET_DIR/backup_to_usb.sh"
chmod +x "$TARGET_DIR/setup.sh"
chmod 644 "$CONFIG_DIR/backup_config.conf"


echo "Installing necessary packages..."
if ! command -v zip &> /dev/null || ! command -v unzip &> /dev/null; then
    pacman -Sy --noconfirm zip unzip
fi


CRON_JOB="30 0 * * 5 $TARGET_DIR/backup_to_usb.sh backup"
if ! crontab -l | grep -qF "$CRON_JOB"; then
    echo "Setting up a cron job for weekly backups..."
    (crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab -
    echo "Cron job set to run weekly at 12:30 AM every Friday."
else
    echo "Cron job already exists. Skipping setup."
fi

echo "Installation complete! The backup environment is now ready on this Pi. And backed up on the USB thumb drive"
