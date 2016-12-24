# bbackup
A simple PowerShell backup script that uses 7-zip.

## Features
* differential backups
* backup encryption

## Requirements
* PowerShell
* 7-zip (http://7-zip.org)

## How to run the script

Enter all directories you want to backup in the bbackup-sources.txt file. Note: One Directory per line.
If you want to exclude directories or files from your backup, edit bbackup-excludes.txt and enter one exclusion per line.

Then you can run the script in PowerShell like this: `bbackup.ps1 -target <TARGET>`

## How the script works

The script will create a new folder on the specified target (if it does not exist) and then start a full backup. 
If there already is a full backup on the target it will start a differential backup.

## Options

To see all options run: `bbackup.ps1 -help`
