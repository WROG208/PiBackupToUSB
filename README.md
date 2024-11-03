# PiBackupSystem

## Note: Please insert a USB drive before starting the installation. The script will save a backup of all necessary files to the USB drive as a precaution. In case of a system failure, this backup allows you to restore the files directly to the Pi without needing to reinstall the repository. During the restore process, the files will be copied back to the Pi with the correct permissions set automatically. 

## This is NOT intended for ASL3. It was not tested. So use at your own risk.
 


## Installation Steps

### Step 1: Download the zip file 
Click on the green code button and choose Download ZIP

### Step 2: Unzip and copy the contents of the zip file to the Pi
Look for a folder named tmp and create a folder there named PiBackupToUSB and paste all the files there.
```
PiBackupToUSB
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


For some reason I cant get GitHub to allow cloning when I figure it out I will update this.
