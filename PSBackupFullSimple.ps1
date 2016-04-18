Import-Module "SQLPS" -DisableNameChecking

$ServerName = $ENV:ComputerName #"PHWSQL1"
$SQLSvr = New-Object -TypeName  Microsoft.SQLServer.Management.Smo.Server($ServerName)
$SQLSvr.ConnectionContext.StatementTimeout = 0

$Db = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Database

foreach ($db in $SQLSvr.Databases | Where-Object {$_.Name -ne "tempdb" -and $_.Name -ne "model" -and $_.RecoveryModel -eq "Simple"}){
    $Backup = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Backup
    $Backup.Action = [Microsoft.SQLServer.Management.SMO.BackupActionType]::Database
    $Backup.BackupSetDescription = "Full Back of "+$Db.Name
    $Backup.CompressionOption = 1
    $Backup.Database = $db.Name

    cd c:
    # Create a backup folder for each database and day, check if that folder exists, if not create it
    $BackupFolder = "\\phwnas2\remotebackups\Simple\"+$Db.name+"\"+[DateTime]::Now.ToString("yyyyMMdd")+"\"
    if ((Test-Path $BackupFolder) -eq $False){
        New-Item $BackupFolder -type Directory
    }

    $BackupName = $BackupFolder+$Db.Name+"_"+[DateTime]::Now.ToString("yyyyMMdd_HHmmss")+".bak"
    $DeviceType = [Microsoft.SqlServer.Management.Smo.DeviceType]::File
    $BackupDevice = New-Object -TypeName Microsoft.SQLServer.Management.Smo.BackupDeviceItem($BackupName,$DeviceType)
 
    $Backup.Devices.Add($BackupDevice)
    $Backup.SqlBackup($SQLSvr)
    $Backup.Devices.Remove($BackupDevice)
}