#!/bin/bash

# Update Script for Backup and Restore System on Raspberry Pi
# 11/2/2024
# Created By WROG208 \ N4ASS
# www.lonewolfsystem.org
#
# This script pulls the latest changes from the GitHub repository, updates
# the necessary files in /usr/local/bin, and copies updated scripts to the USB drive.
# It also gives the option to set up a cron job to automate this update process.


REPO_DIR="/tmp/PiBackupSystem"
TARGET_DIR="/usr/local/bin"
USB_MOUNT_POINT="/mnt/usb"
GITHUB_REPO="https://github.com/WROG208/PiBackupSystem.git"
CRON_JOB="0 0 1-7 * 2 /usr/local/bin/update_scripts.sh"


if [ "$(id -u)" -ne 0 ]; then
    echo "Please run this script as root (e.g., with sudo)."
    exit 1
fi


if [ ! -d "$REPO_DIR" ]; then
    echo "Cloning the repository..."
    git clone "$GITHUB_REPO" "$REPO_DIR"
else
    echo "Pulling the latest changes from the repository..."
    cd "$REPO_DIR"
    git pull origin main
fi


echo "Updating scripts in $TARGET_DIR..."
cp "$REPO_DIR/backup_to_usb.sh" "$TARGET_DIR/"
cp "$REPO_DIR/restore_from_usb.sh" "$TARGET_DIR/"
cp "$REPO_DIR/backup_config.conf" "$TARGET_DIR/"
cp "$REPO_DIR/update_scripts.sh" "$TARGET_DIR/"


chmod +x "$TARGET_DIR/backup_to_usb.sh"
chmod +x "$TARGET_DIR/restore_from_usb.sh"
chmod +x "$TARGET_DIR/update_scripts.sh"
chmod 644 "$TARGET_DIR/backup_config.conf"


if mount | grep -q "$USB_MOUNT_POINT"; then
    echo "Updating backup files on USB drive at $USB_MOUNT_POINT..."
    cp "$REPO_DIR/backup_to_usb.sh" "$USB_MOUNT_POINT/"
    cp "$REPO_DIR/restore_from_usb.sh" "$USB_MOUNT_POINT/"
    cp "$REPO_DIR/backup_config.conf" "$USB_MOUNT_POINT/"
    cp "$REPO_DIR/update_scripts.sh" "$USB_MOUNT_POINT/"
    echo "Backup files on USB drive updated."
else
    echo "USB drive not mounted. Skipping USB backup update."
fi


read -p "Would you like to set up a cron job for automatic monthly updates? (y/n): " setup_cron
if [[ "$setup_cron" =~ ^[Yy]$ ]]; then
    if ! crontab -l | grep -qF "$CRON_JOB"; then
        echo "Setting up cron job for monthly updates..."
        (crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab -
        echo "Cron job set to run on the first Tuesday of each month at 12:00 AM."
    else
        echo "Cron job for monthly updates is already configured."
    fi
else
    echo "Skipping cron job setup."
fi

echo "Update complete! All scripts are up to date."
