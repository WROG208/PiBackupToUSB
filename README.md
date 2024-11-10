# Pi Backup System
# *** Not Tested in ASL3 ***

## Overview
This backup system for Raspberry Pi automates backups to a USB thumb drive. It includes scripts for backing up essential files, restoring backups, and setting up the environment for both new installations and recovery from SD card failures.

**Created By:** WROG208 / N4ASS  
**Website:** [www.lonewolfsystem.org](http://www.lonewolfsystem.org)

## Contents

- `backup_to_usb.sh`: Performs backup operations and saves files to the USB drive.
- `backup_config.conf`: Configuration file specifying directories/files to back up, USB mount point, log directory, and backup retention settings.
- `restore_from_usb.sh`: Restores the latest backup from the USB drive.
- `install.sh`: Sets up the backup environment initially by installing dependencies, setting permissions, and configuring cron jobs.
- `README.md`: This guide.

### After Download 

Unzip file `PiBackupToUSB.zip` to a folder in your computer. 
Transfer to the Raspberry Pi using WinSCP.
Save in folder `/tmp`
Make `install.sh` executable. Just right click on `install.sh` end choose properties. On the boxes where it say permissions click on every box that has an X on the right side of it and click ok. On the bottom you should see Octal:755
Now open Putty and sign in into the Pi that you just saved the files to. Navigate to the folder typing:
```
cd /tmp
```
Now type:
```
./install.sh
```
Wait for installation and check if there was no error message.
 
  
### Generated on First Install

- `install_from_usb.sh`: Saved to the USB drive during setup, allowing for recovery directly from the USB in case of SD card failure.

## Requirements

- Raspberry Pi running a compatible Linux distribution (e.g., Raspbian, Hamvoip).
- A USB drive for storing backups.
  
## Initial Setup

1. **Insert the USB Drive**: Insert a USB drive into the Raspberry Pi that will be used for storing backups. USB drive has to be inserted BEFORE YOU RUN install.sh.
   
2. **Run `install.sh`**:
    - Download and place the package files on the Raspberry Pi.
    - Run `install.sh` as root:
      ```bash
      sudo ./install.sh
      ```
    - This script installs necessary dependencies (`dos2unix`, `zip`, `unzip`, `dosfstools`), formats the USB drive to `VFAT` if needed, and sets up the initial configuration and permissions.
    - **Warning**: If the USB drive requires formatting, all data will be erased. The script prompts for confirmation before formatting.
    
3. **Automatic Backup Setup**:
    - The script sets up a cron job to run the backup every Friday at 12:30 AM.
  
4. **Initial Backup**:
    - The script performs an initial backup to the USB drive.

## Configuration

The configuration file `backup_config.conf` defines key settings:

- **Directories and Files to Back Up**: Set in the `backup_sources` variable, a list of directories/files to back up, separated by spaces.
- **USB Mount Point**: `usb_mount_point` defines where the USB drive is mounted.
- **Log Directory**: `log_dir` sets the location for storing log files.
- **Backup Retention**: `retain_backups` sets the number of recent backups to keep on the USB drive (older backups are deleted automatically).

## Restoring Backups

### Automated Restore

If a previous backup exists, `install.sh` will prompt to restore it during setup.

### Manual Restore

Run `restore_from_usb.sh` to manually restore the most recent backup:
```bash
sudo /usr/local/bin/restore_from_usb.sh

### If you like to add more files or folders to the backup you will have to modify the backup_config.conf.

Find the line that starts with backup_sources=.
Add the paths to the new files or directories you want to back up, separated by spaces. For example:
```
backup_sources="/etc/asterisk /srv/http/supermon /var/spool/cron/root /var/log/asterisk/astdb.txt /path/to/another/directory /path/to/another/file"
```

