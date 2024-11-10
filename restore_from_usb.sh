#!/bin/bash

# Restore Script to restore backup from USB thumb drive
# 11/10/2024
# Created By WROG208 \ N4ASS
# www.lonewolfsystem.org
#
# This script restores the most recent backup from the USB drive. It is designed to be used
# independently of the backup script to allow for quick and easy restoration. The script will
# find the latest backup zip file on the USB drive, prompt the user to confirm, and then restore
# the backup. It also logs the process in the backup_logs directory on the USB drive.
#
# Make sure to place this script in /usr/local/bin or another directory in your PATH to use it easily.



SCRIPT_DIR=$(dirname "$(realpath "$0")")
CONFIG_FILE="$SCRIPT_DIR/backup_config.conf"


if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
else
    echo "Configuration file $CONFIG_FILE not found. Exiting."
    exit 1
fi


USB_MOUNT_POINT=$usb_mount_point
LOG_DIR="$USB_MOUNT_POINT/backup_logs"


mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/restore_log_$(date +%Y%m%d_%H%M%S).txt"


LATEST_BACKUP=$(ls -t "$USB_MOUNT_POINT"/*_backup_*.zip 2>/dev/null | head -n 1)

if [ -z "$LATEST_BACKUP" ]; then
    echo "Error: No backup file found on USB." | tee -a "$LOG_FILE"
    exit 1
fi

echo "Latest backup found: $LATEST_BACKUP" | tee -a "$LOG_FILE"
read -p "Do you want to proceed with the restore? This will overwrite existing files. (y/n): " confirm
if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
    echo "Restore operation aborted by user." | tee -a "$LOG_FILE"
    exit 0
fi

echo "Restoring from $LATEST_BACKUP..." | tee -a "$LOG_FILE"
sudo unzip -o "$LATEST_BACKUP" -d / &>> "$LOG_FILE"

if [ $? -eq 0 ]; then
    echo "Restore successful" | tee -a "$LOG_FILE"
else
    echo "Restore failed" | tee -a "$LOG_FILE"
    exit 1
fi


find "$LOG_DIR" -name "restore_log_*.txt" -type f | sort | head -n -4 | xargs -r rm --

echo "Restore complete" | tee -a "$LOG_FILE"
