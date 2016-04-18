Import-Module "SQLPS" -DisableNameChecking

$ServerName = $ENV:ComputerName #"PHWSQL1"
$SQLSvr = New-Object -TypeName  Microsoft.SQLServer.Management.Smo.Server($ServerName)
$SQLSvr.ConnectionContext.StatementTimeout = 0

$Db = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Database

foreach ($db in $SQLSvr.Databases | Where-Object {$_.Name -ne "tempdb" -and $_.Name -ne "model" -and $_.RecoveryModel -eq "Full"}){
    $Backup = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Backup

    cd c:
    # Create a backup folder for each database and day, check if that folder exists, if not create it
    $BackupFolder = "\\phwnas2\remotebackups\Full\"+$Db.name+"\"+[DateTime]::Now.ToString("yyyyMMdd")+"\"
    if ((Test-Path $BackupFolder) -eq $False){
        New-Item $BackupFolder -type Directory
    }

    if ($Db.LastBackupDate -lt $Db.CreateDate){
        $Backup.Action = [Microsoft.SQLServer.Management.SMO.BackupActionType]::Database
        $BackupName = $BackupFolder + $db.Name+"_"+[DateTime]::Now.ToString("yyyyMMdd_HHmmss")+".bak"
        $Backup.BackupSetDescription = "Full Back of "+$db.Name
    }else{
        $Backup.Action = [Microsoft.SQLServer.Management.SMO.BackupActionType]::Log
        $BackupName = $BackupFolder +$db.Name+"_"+[DateTime]::Now.ToString("yyyyMMdd_HHmmss")+".trn"
        $Backup.BackupSetDescription = "Log Back of "+$Db.Name
        $Backup.LogTruncation = [Microsoft.SqlServer.Management.Smo.BackupTruncateLogType]::Truncate
    }

    $DeviceType = [Microsoft.SqlServer.Management.Smo.DeviceType]::File
    $Backup.Database = $Db.Name
    $Backup.CompressionOption = 1

    $BackupDevice = New-Object -TypeName Microsoft.SQLServer.Management.Smo.BackupDeviceItem($BackupName,$DeviceType)
    $Backup.Devices.Add($BackupDevice)
    $Backup.SqlBackup($SQLSvr)
    $Backup.Devices.Remove($BackupDevice)
}