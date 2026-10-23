# Settings: change these to match your server.
$SourceVolume = "D:"
$BackupShare = "\\SERVER\Backups"

$pol = new-wbpolicy
$vol = get-wbvolume $SourceVolume
$tvol = New-WBBackupTarget -NetworkPath $BackupShare
add-wbvolume -policy $pol -volume $vol
Add-WBBackupTarget -Policy $pol -Target $tvol
Start-WBBackup -Policy $pol -Force
