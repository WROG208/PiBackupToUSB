# PiBackupSystem

## Note: Please insert a USB drive before starting the installation. The script will save a backup of all necessary files to the USB drive as a precaution. In case of a system failure, this backup allows you to restore the files directly to the Pi without needing to reinstall the repository. During the restore process, the files will be copied back to the Pi with the correct permissions set automatically. 

## This is NOT intended for ASL3. It was not tested. So use at your own risk.
 


## Installation Steps

### Step 1: Clone the Repository

Open a terminal on your Raspberry Pi and run the following command to clone the repository to your `/tmp` directory:

```bash
cd /tmp
git clone https://github.com/yourusername/PiBackupSystem.git
```

### Step 2: Navigate to the Repository Directory
Once cloned, navigate into the repository directory:

```bash
cd PiBackupSystem
```


### Step 3: Run the Install Script

Run the install.sh The sh script is used with sudo to set up the system. This script will copy files to the appropriate directories, set permissions, and configure the environment.

```bash
sudo ./install.sh
```

### Step 4: Verify the Installation

After the script completes, you can verify that the setup was successful by checking for any log messages or verifying the cron job (if one was set up).


### Updating the Project

To update the project with the latest changes from GitHub.

Navigate to the repository directory on your Raspberry Pi:
```bash
cd /tmp/PiBackupSystem
```

### Pull the latest changes:
```bash
git pull
```

### Re-run the install script if needed:
```bash
sudo ./install.sh
```
