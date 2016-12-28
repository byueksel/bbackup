# bbackup
A simple PowerShell backup script that uses 7-Zip.

## Features
* differential backups
* backup encryption

## Requirements
* PowerShell
* 7-Zip (http://7-zip.org)

## How to run the script

Enter all directories you want to backup in the bbackup-sources.txt file. Note: One Directory per line.
If you want to exclude directories or files from your backup, edit bbackup-excludes.txt and enter one exclusion per line.

Then you can run the script in PowerShell like this: `bbackup.ps1 -target <TARGET>`

## How the script works

The script will create a new folder on the specified target (if it does not exist) and then start a full backup. 
If there already is a full backup on the target it will start a differential backup.

## Options

Option | Description | Default | Required?
--- | --- | --- | ---
`target` | Expects a location where to store the backup. | - | Yes
`name` | Expects a String that will be used as backup name. | Computername | No
`encrypt` | Backup will encrypted with AES-256 if this option is given. | false | No
`shutdown` | The Computer will shutdown after Backup if this option is given | false | No
`help` | Displays Help Text | false | No

To see all options run: `bbackup.ps1 -help`
