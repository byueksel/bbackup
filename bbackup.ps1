# bbackup.ps1
# Copyright (C) 2016  Burak Yueksel <brkyksl58@gmail.com>
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

param (
    [string]$name = (get-item env:"COMPUTERNAME").Value,
    [string]$target = "",
	[switch]$encrypt=$false,
	[switch]$shutdown=$false,
	[switch]$help=$false
)

if($help) {
	write-host "BBackup  Copyright (C) 2016  Burak Yueksel <brkyksl58@gmail.com>"
	write-host "Usage: bbackup.ps1 -target <TARGET> <OPTIONS>"
	write-host "Options"
	write-host "  -target <TARGET> Target of the Backup"
	write-host "  -name <NAME>     The Name of the Backup"
	write-host "  -encrypt         Encrypt the Backup"
	write-host "  -shutdown        Shutdown Computer after Backup"
	write-host "  -help            Shows this Help information"
	write-host
	Return
}

# Check for 7zip
$p7z = (get-item env:"ProgramFiles(x86)").Value + "\7-Zip\7z.exe"
If ((Test-Path $p7z) -eq 0) {  
	$p7z = (get-item env:"ProgramFiles").Value + "\7-Zip\7z.exe"
}
If ((Test-Path $p7z) -eq 0) {
	write-host "7-Zip is not installed, please install it from http://7-zip.org/" -ForegroundColor red
	write-host ""
	Return
}

# Check Target
If ($target -eq "") {
	write-host "-target options is missing" -ForegroundColor red
	write-host ""
	Return
}
If ((Test-Path $target) -eq 0) {
	write-host "$target is not a valid backup destination" -ForegroundColor red
	write-host ""
	Return
}

# Switches
$switches="-t7z -ssw -slp -scsUTF-8 -sccUTF-8 -bd -bb1 -bsp0 -bso1 -bse2 -mtm=on -mtc=on -mta=on"

# Check encryption
if($encrypt) {
	$pass1 = Read-Host 'Please enter a Passowrd for encryption' -AsSecureString
	$pass2 = Read-Host 'Please re-enter encryption Passowrd   ' -AsSecureString
	$p1 = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($pass1))
	$p2 = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($pass2))
	if($p1 -ne $p2) {
		write-host "Password incorrect" -ForegroundColor red
		write-host
		Return
	}
	# -mem=AES256
	$switches = $switches + " -mhe -p$p1"
}

# Check sources
$sources="bbackup-sources.txt"
If ((Test-Path $sources) -eq 0) {
	write-host "File $sources not found" -ForegroundColor red
	write-host
	Return
}

# Check excludes
$excludes="bbackup-excludes.txt"
If ((Test-Path $excludes) -eq 0) {
	write-host "File $excludes not found" -ForegroundColor red
	write-host
	Return
}

$timestamp = Get-Date -UFormat "%Y-%m-%d_%H%M%S"
$dest = "$target\$name"
$diffname="$dest\$name-diff-$timestamp.7z"
$fullname="$dest\$name-full-$timestamp.7z"
$logFile = "$name-full-$timestamp.log"

If ((Test-Path $dest) -eq 0) {
	write-host "Creating new directory $dest" -ForegroundColor green
	New-Item -ItemType Directory -Path $dest
	write-host
}

$command="a $fullname $switches -xr@$excludes @$sources"
if((Test-Path "$dest\$name-full-*.7z") -eq 1) {
	$logFile = "$name-diff-$timestamp.log"
	$item = Get-Item "$dest\$name-full-*.7z"
	$command="u $item $switches -xr@$excludes -u- -up0q3r2x2y2z0w2!$diffname @$sources"
}

# Start Backup
write-host "Starting backup to $dest ..." -ForegroundColor green

$proc = Start-Process -FilePath $p7z -ArgumentList $command -Wait -WindowStyle Hidden -PassThru

switch ($proc.ExitCode) { 
	0 {
		write-host "Backup to $dest is complete" -ForegroundColor green
		write-host 
	} 
	1 {
		write-host "Backup to $dest completed with warnings " -ForegroundColor orange
		write-host "one or more files were locked by some other application, so they were not compressed"
		write-host
	} 
	2 {
		write-host "Backup to $dest failed" -ForegroundColor red
		write-host 
	} 
	7 {
		write-host "Backup to $dest failed with Command line error" -ForegroundColor red
		write-host 
	} 
	8 {
		write-host "Backup to $dest failed becasue there is not enough memory for operation" -ForegroundColor red
		write-host 
	} 
	255 {
		write-host "User stopped the process" -ForegroundColor red
		write-host 
	} 
	default {
		write-host "Unknown Exit Code: " + $proc.ExitCode -ForegroundColor orange
		write-host 
	}
}

if($shutdown) {
	Stop-Computer
}
