#!/bin/bash

# Install from USB script for Backup System on Raspberry Pi
# 11/03/2024
# Created by WROG208 \ N4ASS
# www.lonewolfsystem.org
#
# This script installs all necessary backup and restore scripts to the USB drive for resilience against SD card failure.
# It sets up the initial backup environment and schedules automatic backups.

TARGET_DIR="/usr/local/bin"
CONFIG_DIR="/usr/local/bin"
LOG_DIR="/backup/logs"
USB_DEVICE="/dev/sda1"
USB_MOUNT_POINT="/mnt/usb"
MARKER_FILE="$TARGET_DIR/.backup_installed"
HOSTNAME=$(hostname)

# Ensure the script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "Please run this script as root (e.g., with sudo)."
    exit 1
fi

# Install necessary packages silently
echo "Installing necessary packages..."
pacman -Sy --noconfirm dos2unix zip unzip dosfstools

# Format and mount the USB drive if needed
if [ ! -d "$USB_MOUNT_POINT" ]; then
    echo "Creating USB mount point at $USB_MOUNT_POINT..."
    mkdir -p "$USB_MOUNT_POINT"
fi

# Format to vfat and mount with user confirmation
if ! mount | grep -q "$USB_MOUNT_POINT"; then
    echo "Warning: This will format the USB drive, erasing all data on it."
    read -p "Do you want to proceed with formatting the USB drive? (y/n): " confirm_format
    if [[ "$confirm_format" =~ ^[Yy]$ ]]; then
        mkfs.vfat "$USB_DEVICE"
        mount "$USB_DEVICE" "$USB_MOUNT_POINT"
    else
        echo "USB formatting canceled. Exiting."
        exit 1
    fi
fi

# Copy scripts to USB drive, including this install script
echo "Copying scripts to USB drive..."
cp backup_to_usb.sh "$USB_MOUNT_POINT/"
cp restore_from_usb.sh "$USB_MOUNT_POINT/"
cp backup_config.conf "$USB_MOUNT_POINT/"
cp "$0" "$USB_MOUNT_POINT/install_from_usb.sh"  # Copy this script

# Set permissions
chmod +x "$USB_MOUNT_POINT/backup_to_usb.sh" "$USB_MOUNT_POINT/restore_from_usb.sh" "$USB_MOUNT_POINT/install_from_usb.sh"
chmod 644 "$USB_MOUNT_POINT/backup_config.conf"

# Ensure log directory exists on the main system
echo "Creating log directory at $LOG_DIR..."
mkdir -p "$LOG_DIR"

# Copy files to target directories on the Pi
cp backup_to_usb.sh "$TARGET_DIR/"
cp restore_from_usb.sh "$TARGET_DIR/"
cp backup_config.conf "$CONFIG_DIR/"

# Set permissions for copied files on Pi
chmod +x "$TARGET_DIR/backup_to_usb.sh" "$TARGET_DIR/restore_from_usb.sh"
chmod 644 "$CONFIG_DIR/backup_config.conf"

# Set up a cron job for weekly backups
CRON_JOB="30 0 * * 5 $TARGET_DIR/backup_to_usb.sh backup"
if ! crontab -l | grep -qF "$CRON_JOB"; then
    echo "Setting up a cron job for weekly backups..."
    (crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab -
    echo "Cron job set to run weekly at 12:30 AM every Friday."
else
    echo "Cron job already exists. Skipping setup."
fi

# Mark first run complete
touch "$MARKER_FILE"

# Run the initial backup
echo "Running first-time backup to USB drive..."
if mount | grep -q "$USB_MOUNT_POINT"; then
    "$TARGET_DIR/backup_to_usb.sh" backup
    if [ $? -eq 0 ]; then
        echo "Initial backup completed successfully."
    else
        echo "Initial backup failed."
    fi
else
    echo "USB drive not mounted. Unable to perform the initial backup."
fi

echo "Installation complete! The backup environment is now ready on this Pi. A copy of this install script is saved on the USB drive for recovery."
