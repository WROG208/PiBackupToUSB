# PiBackupSystem

## Note: Please insert a USB drive before starting the installation. The script will save a backup of all necessary files to the USB drive as a precaution. In case of a system failure, this backup allows you to restore the files directly to the Pi without needing to reinstall the repository. During the restore process, the files will be copied back to the Pi with the correct permissions set automatically. 

## This is NOT intended for ASL3. It was not tested. So use at your own risk.
 


## Installation Steps

### Step 1: Download the zip file 

Open a terminal on your Raspberry Pi and run the following command to clone the repository it will save it to `/tmp/PiBackupSystem` creating the PiBackupSystem directory:

```bash
git clone https://WROG208@github.com/PiBackupSystem.git /tmp/PiBackupSystem
```

### Step 2: Navigate to the Repository Directory
Once cloned, navigate into the repository directory:

```bash
cd /tmp/PiBackupSystem
```


### Step 3: Set the executable permission for install.sh:

```bash
sudo chmod +x install.sh
```


### Step 4: Run the install.sh. This script will copy files to the appropriate directories, set permissions, and configure the environment.

```bash
sudo ./install.sh
```

### Step 5: Verify the Installation

After the script completes, you can verify that the setup was successful by checking for any log messages or verifying the cron job (if one was set up).

```bash
crontab -e
```
Look for this line. If the line is there then the crontab has been set. (This is the crontab for updates not the cron tab for the weekly backup.

```cron
0 0 1-7 * 2 /usr/local/bin/update_scripts.sh
```
### The crontab for the weekly backup should look like this:

```cron
30 0 * * 5 /usr/local/bin/backup_to_usb.sh backup
```


### Updating the Project

To update the project with the latest changes from GitHub.

### How the Update Process Works

## Checks for Repository:
   If the repository isn’t cloned locally, it will clone it to /tmp/PiBackupSystem.
   If the repository is already present, it pulls the latest changes from GitHub.

## Copies Updated Scripts to the System:
   Copies backup_to_usb.sh, restore_from_usb.sh, and backup_config.conf to /usr/local/bin.
   Sets the necessary permissions to ensure the scripts can execute and the configuration file is readable.

## Updates USB Backup:
   If the USB drive is mounted, it copies the updated scripts to the USB drive.
   If the USB drive isn’t mounted, it skips the USB backup update but completes the update on the Pi.

## Usage Instructions
Run the update_scripts.sh Script whenever you want to apply the latest changes from the GitHub repository:

```bash
sudo /path/to/update_scripts.sh
```

## Automate Updates: 
Optionally, you can set up a cron job to run update_scripts.sh at regular intervals (e.g., weekly) if you want to automate the update process.

This approach keeps the scripts on both the Pi and the USB drive up to date with the latest repository changes, ensuring that you always have the most recent version.

```bash

