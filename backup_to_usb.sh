#!/bin/bash

# Backup/Restore Script to USB thumb drive
# This script creates a backup of specified directories and files and saves it to a mounted USB drive.

# Load configuration file
SCRIPT_DIR=$(dirname "$(realpath "$0")")
CONFIG_FILE="$SCRIPT_DIR/backup_config.conf"

if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
else
    echo "Configuration file $CONFIG_FILE not found. Exiting."
    exit 1
fi

# Set variables from config file
BACKUP_SOURCES=($backup_sources)
USB_DEVICE=$usb_device
USB_MOUNT_POINT=$usb_mount_point
LOG_DIR="$USB_MOUNT_POINT/backup_logs"
RETAIN_BACKUPS=$retain_backups

# Generate backup and log file names
HOSTNAME=$(hostname)
BACKUP_FILE="$USB_MOUNT_POINT/${HOSTNAME}_backup_$(date +%Y%m%d).zip"
LOG_FILE="$LOG_DIR/backup_log_$(date +%Y%m%d_%H%M%S).txt"

# Create log directory
mkdir -p "$LOG_DIR"

# Function to mount USB drive if not mounted
mount_usb() {
    if mount | grep -q "$USB_MOUNT_POINT"; then
        echo "USB drive is already mounted at $USB_MOUNT_POINT" | tee -a "$LOG_FILE"
    else
        echo "Mounting USB drive at $USB_MOUNT_POINT..." | tee -a "$LOG_FILE"
        sudo mount "$USB_DEVICE" "$USB_MOUNT_POINT"
        if [ $? -ne 0 ]; then
            echo "Error: Unable to mount USB drive at $USB_MOUNT_POINT" | tee -a "$LOG_FILE"
            exit 1
        fi
        echo "USB drive mounted successfully at $USB_MOUNT_POINT" | tee -a "$LOG_FILE"
    fi
}

# Backup function
backup() {
    mount_usb  # Ensure USB is mounted

    echo "Starting backup of selected directories and files to $BACKUP_FILE" | tee -a "$LOG_FILE"
    zip -r "$BACKUP_FILE" "${BACKUP_SOURCES[@]}" &>> "$LOG_FILE"

    if [ $? -eq 0 ] && [ -f "$BACKUP_FILE" ]; then
        echo "Backup successful: $BACKUP_FILE" | tee -a "$LOG_FILE"
    else
        echo "Backup failed" | tee -a "$LOG_FILE"
        exit 1
    fi

    # Remove older backups, keeping only the latest $RETAIN_BACKUPS
    find "$USB_MOUNT_POINT" -name "${HOSTNAME}_backup_*.zip" -type f | sort | head -n -"$RETAIN_BACKUPS" | xargs -r rm --

    echo "Backup complete" | tee -a "$LOG_FILE"

    # Keep only the last 4 log files
    find "$LOG_DIR" -name "backup_log_*.txt" -type f | sort | head -n -4 | xargs -r rm --
}

# Run the backup function
backup
