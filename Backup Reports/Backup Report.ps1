# Settings: change these to match your server and mail system.
$OfficeName = "Office Name"
$MailMessageTo = "admin@example.com"
$MailMessageFrom = "backups@example.com"
$MailMessageSMTPServer = "smtp.example.com"
$MailMessagePriority = "Normal"
$VSSRepairPath = "C:\Scripts\VSS Repairs\VSSRepair.bat"

$HTMLMessageSubject = $OfficeName+": Backup Report"

$WBJob = Get-WBJob -Previous 1
$WBSummary = Get-WBSummary
$WBJobStartTime = $WBJob.StartTime
$WBJobEndTime = $WBJob.EndTime


If ($WBSummary.LastBackupResultHR -eq 0) {
    $WBJobResult = "successful"
    $WBJobLog = $WBJobSuccessLog
} Else {
    start $VSSRepairPath
    $WBJobResult = "failed"
    $WBJobLog = $WBJobFailureLog
}


$HTMLMessage = @"
<!DOCTYPE html>
<html>
<head>
<title>$HTMLMessageSubject</title>
<style>
h1.successful {color:green;}
h1.failed {color:red;}
</style>
</head>
<body>
<h1 class="$WBJobResult">Backup $WBJobResult</h1>
Start: $WBJobStartTime<br>
Finished: $WBJobEndTime<br>
$WBJobLog
</body>
</html>
"@


$MailMessageOptions = @{
    From            = "$MailMessageFrom"
    To              = "$MailMessageTo"
    Subject         = "$HTMLMessageSubject"
    BodyAsHTML      = $True
    Body            = "$HTMLMessage"
    Priority        = "$MailMessagePriority"
    SmtpServer      = "$MailMessageSMTPServer"
}
Send-MailMessage @MailMessageOptions
