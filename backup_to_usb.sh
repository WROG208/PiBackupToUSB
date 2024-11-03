#!/bin/bash

# Backup/Restore Script to USB thumb drive
# 11/03/2024
# Created By WROG208 \ N4ASS
# www.lonewolfsystem.org
#
# Script will backup the Supermon Folder, Asterisk folder, and all of their content, and will also
# backup the astdb.txt file (database file) and root file of the cron jobs you have on your Pi. 
# It will create a zip file that will be saved on the Thumb Drive if inserted on the Pi.
# If no thumb drive is inserted the job will FAIL.
# File will be created with the name of the HOST (HOST name is whatever your Raspberry Pi is named) with the date it was created.
# 
# Manual Install. If you ran the install.sh script this was done for you already
# Save this file in /usr/local/bin as well as backup_config.conf MAKE sure you change permissions to bacup_to_usb.sh to make it executable, the .conf file does not need any special permissions
# leave as is.
# Go into the BASH SHELL and type crontab -e that will open your cron jobs in the text editor NANO. Create a CRON job for the file to run.
# 
# 00 0 * * 5 /usr/local/bin/backup.to.usb.sh
# This CRON job will run at midnight every Friday. Adjust for your needs.
# The first 2 numbers are for minutes. The second set of numbers is the hour. Third * change if you want to make it run on a certain day of the month.
# options are 1 to 31 allowed values. Fourth * change if you want to make it run on a certain month 1 to 12 are the allowed values. The fifth 5 change if you want to make it run on a different # # day of the week 0 being Sunday and 6 being Saturday.
# It will check the USB drive and delete the oldest backups always leaving the last 2 backups.
# It will also create a folder on the ROOT named backup_log where it will save the last 2 logs of when it ran to be able to troubleshoot if any problems.




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

    echo "Starting backup of selected directories and files to $BACKUP_FILE" | tee -a "$LOG_FILE"
    zip -r "$BACKUP_FILE" "${BACKUP_SOURCES[@]}" &>> "$LOG_FILE"

    if [ $? -eq 0 ] && [ -f "$BACKUP_FILE" ]; then
        echo "Backup successful: $BACKUP_FILE" | tee -a "$LOG_FILE"
    else
        echo "Backup failed" | tee -a "$LOG_FILE"
        exit 1
    fi


    find "$USB_MOUNT_POINT" -name "${HOSTNAME}_backup_*.zip" -type f | sort | head -n -"$RETAIN_BACKUPS" | xargs -r rm --

    echo "Backup complete" | tee -a "$LOG_FILE"


    find "$LOG_DIR" -name "backup_log_*.txt" -type f | sort | head -n -4 | xargs -r rm --
}


backup
