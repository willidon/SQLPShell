Import-Module "SQLPS" -DisableNameChecking

$ServerName = $ENV:ComputerName #"PHWSQL1"
$SQLSvr = New-Object -TypeName  Microsoft.SQLServer.Management.Smo.Server($ServerName)
$SQLSvr.ConnectionContext.StatementTimeout = 0

$DbName = "DiaWebDSL_Attachments"
$Db = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Database
$Db = $SQLSvr.Databases.Item("DiaWebDSL_Attachments")

$Backup = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Backup
$Backup.Action = [Microsoft.SQLServer.Management.SMO.BackupActionType]::Database
$Backup.BackupSetDescription = "Full Back of "+$Db.Name
$Backup.CompressionOption = 1
$Backup.Database = $db.Name

cd c:
# Create a backup folder for this database and day, check if that folder exists, if not create it
$BackupFolder = "\\phwnas2\remotebackups\Full\"+$Db.name+"\"+[DateTime]::Now.ToString("yyyyMMdd")+"\"
if ((Test-Path $BackupFolder) -eq $False){
    New-Item $BackupFolder -type Directory
}

#$BackupName = $BackupFolder+$Db.Name+"_"+[DateTime]::Now.ToString("yyyyMMdd_HHmmss")+".bak"
#$DeviceType = [Microsoft.SqlServer.Management.Smo.DeviceType]::File
#$BackupDevice = New-Object -TypeName Microsoft.SQLServer.Management.Smo.BackupDeviceItem($BackupName,$DeviceType)
 
#$Backup.Devices.Add($BackupDevice)
#$Backup.SqlBackup($SQLSvr)
#$Backup.Devices.Remove($BackupDevice)

# the following code uses a new cmdlet that removes need to manually build the SMO Objects
$BackupFile = $BackupFolder+$Db.Name+"_"+[DateTime]::Now.ToString("yyyyMMdd_HHmmss")+".bak"
#Backup-SqlDatabase -Database $DbName -ServerInstance $ServerName -BackupAction Database -BackupFile $BackupFile -BackupSetDescription $Backup.BackupSetDescription -CompressionOption On
Backup-SqlDatabase -Database $DbName -InputObject $SQLSvr -BackupAction Database -BackupFile $BackupFile -BackupSetDescription $Backup.BackupSetDescription -CompressionOption On


