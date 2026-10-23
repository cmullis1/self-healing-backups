# Self-healing backups

Three small PowerShell scripts that keep Windows Server Backup running without anyone watching it:
one emails a report after each backup and kicks off a repair when the backup failed, one repairs
the Volume Shadow Copy (VSS) writers that usually cause those failures, and one runs a one-off
backup of a data drive to a network share.

![Two sample report emails: a green "Backup successful" and a red "Backup failed", each with start and finish times](screenshots/backup-report-email.png)

## What it does

- **Backup Report** (`Backup Reports/Backup Report.ps1`) reads the result of the last Windows
  Server Backup job and emails an HTML report with a green "Backup successful" or red "Backup
  failed" heading and the job's start and finish times. When the backup failed, it also starts
  VSS Repair, so the next backup has a good chance of working without anyone stepping in.
- **VSS Repair** (`VSS Repairs/VSSRepair.ps1`) runs `vssadmin list writers`, finds every VSS
  writer whose last error is not "No Error", and restarts the Windows service behind it (for
  example `SqlServerWriter` is `SQLWriter`, `WMI Writer` is `Winmgmt`). It knows the services for
  27 common writers, then restarts the Cryptographic Services, makes sure WMI is running and
  stops the SQL Server VSS Writer service.
- **D Drive Backup** (`D_Drive Backup/D_Drive Backup.ps1`) builds a one-off Windows Server Backup
  policy for one volume and backs it up to a network share straight away.

Each script has a `.bat` launcher with the same name. It runs the script with
`-ExecutionPolicy Bypass`, so the script can be started with a double-click or from Task
Scheduler.

## How to run it

You need Windows Server with the Windows Server Backup feature installed (it provides the
`Get-WBJob`, `Get-WBSummary` and `Start-WBBackup` commands), and an administrator account.

1. Copy the three folders to the server.
2. Open `Backup Reports/Backup Report.ps1` and change the settings at the top:
   - `$OfficeName`: the name shown in the email subject, such as `Office Name: Backup Report`.
   - `$MailMessageTo`, `$MailMessageFrom`: who gets the report and who it comes from.
   - `$MailMessageSMTPServer`: a mail server that accepts mail from this server without a login.
   - `$VSSRepairPath`: where you put `VSSRepair.bat`.
3. Open `D_Drive Backup/D_Drive Backup.ps1` and set `$SourceVolume` (the drive to back up) and
   `$BackupShare` (the network share, such as `\\SERVER\Backups`).
4. In Task Scheduler, run `Backup Report.bat` as an administrator after the nightly backup
   finishes.
5. Run `D_Drive Backup.bat` whenever you want an extra copy of the drive.

`VSSRepair.bat` can also be run by hand whenever `vssadmin list writers` shows a writer in a
failed state.

## How it was built

I wrote these scripts by hand, without AI help and without starting from scripts found online, to
look after the backups on a small office's Windows server. The report script does more than
report: when a backup fails, it starts the repair itself.

## License

MIT. See [LICENSE](LICENSE).
