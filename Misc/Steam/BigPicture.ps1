<#
.SYNOPSIS
Start Steam Big Picture with another audio source.

.DESCRIPTION
This script will change the default audio playback before luanching Steam Big Picture.
It will also revert back to a choosen audio playback upon exit.

.EXAMPLE
./BigPicture.ps1

.INFO
$AudiOutPutSteam is the playback device the script will switch to before starting Steam.
$AduiOutPutDefault is the playback device the script will switch to upon exit.

Right-click the "Audio Device" and change the values accordingly to your setup.

This script uses NirCmd (http://www.nirsoft.net/utils/nircmd.html) and will automaticly download it.

.LINK
https://github.com/christopher-swe
#>

### EDIT THIS ###########################################
$AudiOutPutSteam = "Samsung-C"
$AduiOutPutDefault = "Speakers"
#########################################################

$SteamFolder = (Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | where {$_.DisplayName -eq "Steam"}).UninstallString -replace "uninstall.exe",""
if ($SteamFolder.Length -le 1) {
    Write-Warning "[INFO] Can't find the path to your Steam-folder, is it installed?"
    Pause
    Exit
}

$SteamExecutable = ".\Steam.exe steam://open/bigpicture"
$NirCmd = "$env:TEMP\NirCmd\NirCmd.exe setdefaultsounddevice"

Write-host -ForegroundColor CYAN "[INFO] Checking if NirCmd exist."
$TestNirCmd = Test-Path "$env:TEMP\NirCmd\NirCmd.exe"
if ($TestNirCmd -eq $false) {
    Write-host -ForegroundColor CYAN "[INFO] Can't find NirCmd."
    Write-host -ForegroundColor CYAN "[INFO] Downloading NirCmd, please wait..."
    Invoke-WebRequest -Uri http://www.nirsoft.net/utils/nircmd.zip -OutFile "$env:TEMP\nircmd.zip"
    Write-host -ForegroundColor CYAN "[INFO] Extracting NirCmd.exe to $env:TEMP\NirCmd"
    Expand-Archive -Path "$env:TEMP\nircmd.zip" -DestinationPath "$env:TEMP\NirCmd"
    $NirCmd = "$env:TEMP\NirCmd\NirCmd.exe setdefaultsounddevice"
}
Else {
    Write-host -ForegroundColor CYAN "[INFO] NirCmd found."
}

Write-host -ForegroundColor CYAN "[INFO] Switching playback device to $AudiOutPutSteam."
Invoke-Expression "$NirCmd $AudiOutPutSteam"

Write-host -ForegroundColor CYAN "[INFO] Starting Steam BigPicture."
Set-Location $SteamFolder
Invoke-Expression $SteamExecutable

Write-Host
Write-Host
Write-host -ForegroundColor YELLOW "[INFO] Wait until you are done playing. Then press Enter to exit."
Write-host -ForegroundColor YELLOW "[INFO] Upon exit, the playback device will revert back to $AduiOutPutDefault."
Pause

Write-host -ForegroundColor CYAN "[INFO] Switching playback device to $AduiOutPutDefault."
Invoke-Expression "$NirCmd $AduiOutPutDefault"
Write-host -ForegroundColor CYAN "[INFO] Closing window in 5 seconds."
Wait-Event -Timeout 5
