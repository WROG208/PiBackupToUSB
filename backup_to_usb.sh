#!/bin/bash

# Backup/Restore Script to USB thumb drive
# 11/10/2024
# Created By WROG208 \ N4ASS
# www.lonewolfsystem.org

SCRIPT_DIR=$(dirname "$(realpath "$0")")
CONFIG_FILE="$SCRIPT_DIR/backup_config.conf"

if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
else
    echo "Configuration file $CONFIG_FILE not found. Exiting."
    exit 1
fi

BACKUP_SOURCES=($backup_sources)
USB_MOUNT_POINT=$usb_mount_point
LOG_DIR="$USB_MOUNT_POINT/backup_logs"
RETAIN_BACKUPS=$retain_backups

HOSTNAME=$(hostname)
BACKUP_FILE="$USB_MOUNT_POINT/${HOSTNAME}_backup_$(date +%Y%m%d).zip"
LOG_FILE="$LOG_DIR/backup_log_$(date +%Y%m%d_%H%M%S).txt"

mkdir -p "$LOG_DIR"

backup() {

    if mount | grep -q "$USB_MOUNT_POINT"; then
        echo "USB drive is mounted at $USB_MOUNT_POINT" | tee -a "$LOG_FILE"
    else
        echo "Error: USB drive not mounted at $USB_MOUNT_POINT" | tee -a "$LOG_FILE"
        exit 1
    fi

    tmp_backup_dir=$(mktemp -d)
    
    for src in "${BACKUP_SOURCES[@]}"; do
        cp -r "$src" "$tmp_backup_dir"
    done

    cp "$SCRIPT_DIR/backup_to_usb.sh" "$tmp_backup_dir/"
    cp "$SCRIPT_DIR/restore_from_usb.sh" "$tmp_backup_dir/"
    cp "$CONFIG_FILE" "$tmp_backup_dir/"

    zip -r "$BACKUP_FILE" "$tmp_backup_dir"/* &>> "$LOG_FILE"

    if [ $? -eq 0 ] && [ -f "$BACKUP_FILE" ]; then
        echo "Backup successful: $BACKUP_FILE" | tee -a "$LOG_FILE"
    else
        echo "Backup failed" | tee -a "$LOG_FILE"
        exit 1
    fi

    rm -rf "$tmp_backup_dir"

    find "$USB_MOUNT_POINT" -name "${HOSTNAME}_backup_*.zip" -type f | sort | head -n -"$RETAIN_BACKUPS" | xargs -r rm --

    echo "Backup complete" | tee -a "$LOG_FILE"

    find "$LOG_DIR" -name "backup_log_*.txt" -type f | sort | head -n -4 | xargs -r rm --
}

backup
