#!/bin/bash

# Backup/Restore to USB thumb drive Script
# Install and Restore Script for Backup to USB drive on Raspberry Pi
# This script will install essential files and dependencies as well as make a backup of files to the USB drive and finally run the first backup once installed 
# 11/03/2024
# Created By WROG208 \ N4ASS
# www.lonewolfsystem.org
# Files being copied to the Pi. backup_to_usb.sh backup_config.conf and setting permissions for the files as well as adding a CRON job for the script  # to run every week.


TARGET_DIR="/usr/local/bin"
CONFIG_DIR="/usr/local/bin"
LOG_DIR="/backup/logs"
HOSTNAME=$(hostname)
USB_DEVICE="/dev/sda1"
USB_MOUNT_POINT="/mnt/usb"
MARKER_FILE="$TARGET_DIR/.backup_installed"


if [ "$(id -u)" -ne 0 ]; then
    echo "Please run this script as root (e.g., with sudo)."
    exit 1
fi


echo "Installing necessary packages..."
if ! command -v dos2unix &> /dev/null; then
    pacman -Sy --noconfirm dos2unix
fi
if ! command -v zip &> /dev/null || ! command -v unzip &> /dev/null; then
    pacman -Sy --noconfirm zip unzip
fi


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
cp restore_from_usb.sh "$TARGET_DIR/"

echo "Setting permissions..."
chmod +x "$TARGET_DIR/backup_to_usb.sh"
chmod +x "$TARGET_DIR/restore_from_usb.sh"
chmod 644 "$CONFIG_DIR/backup_config.conf"


if [ ! -d "$USB_MOUNT_POINT" ]; then
    echo "Creating USB mount point at $USB_MOUNT_POINT..."
    mkdir -p "$USB_MOUNT_POINT"
fi


if ! mount | grep -q "$USB_MOUNT_POINT"; then
    echo "Attempting to mount USB drive at $USB_MOUNT_POINT..."
    mount "$USB_DEVICE" "$USB_MOUNT_POINT" || echo "Failed to mount USB drive."
fi


if [ ! -f "$MARKER_FILE" ]; then
    echo "First run detected. Skipping restore prompt."
else

    LATEST_BACKUP=$(ls -t "$USB_MOUNT_POINT"/*_backup_*.zip 2>/dev/null | head -n 1)
    if [ -n "$LATEST_BACKUP" ]; then
        echo "Backup found on USB drive: $LATEST_BACKUP"
        read -p "Do you want to restore from this backup? (y/n): " confirm
        if [[ "$confirm" =~ ^[Yy]$ ]]; then
            echo "Restoring from $LATEST_BACKUP..."
            unzip -o "$LATEST_BACKUP" -d /
            if [ $? -eq 0 ]; then
                echo "Restore successful."
            else
                echo "Restore failed."
                exit 1
            fi
        else
            echo "Restore skipped by user."
        fi
    else
        echo "No backup file found on USB."
    fi
fi


CRON_JOB="30 0 * * 5 $TARGET_DIR/backup_to_usb.sh backup"
if ! crontab -l | grep -qF "$CRON_JOB"; then
    echo "Setting up a cron job for weekly backups..."
    (crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab -
    echo "Cron job set to run weekly at 12:30 AM every Friday."
else
    echo "Cron job already exists. Skipping setup."
fi


echo "Creating marker file to indicate first run complete."
touch "$MARKER_FILE"


run_initial_backup() {
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
}


run_initial_backup

echo "Installation complete! The backup environment is now ready on this Pi. And backed up on the USB thumb drive"

