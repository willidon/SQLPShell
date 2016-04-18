# Code to delete folders older than DaysToKeep
# Make sure to update $DaysToKeep and #TargetFolder variables for each environment you are deploying this to
# if this code is put into production, make sure to test values for $LastWrite for what you want,
# time is taken into account when doing day calc
cd c:

function Is-Numeric ($Value) {
    return $Value -match "^[\d\.]+$"
}

$Today = Get-Date
$DaysToKeep = "3"
$TargetFolder = "\\phwnas2\remotebackups\Full\"
$LastWrite = $Today.AddDays(-$DaysToKeep)
$LastWriteString = $LastWrite.ToString("yyyyMMdd")
$FldrExclusion1 = "Simple"
$FldrExclusion2 = "installer"
$Folders = Get-ChildItem -path $TargetFolder -Recurse |
Where {$_.psIsContainer -eq $true} |
Where {Is-Numeric $_.name} |
Where {$LastWriteString - $_.name -gt 0} | #Where {$_.LastWriteTime -le "$LastWrite"} |
Where {$_.fullname -notcontains $FldrExclusion1} |
Where {$_.fullname -notcontains $FldrExclusion2}

    foreach ($Folder in $Folders)
    {
        #$Folder.FullName
        if ($Folder -eq $null) {
            #throw "No further folders to delete"
        }
        else {
            #write-host "Deleting $Folder folder" -foregroundcolor "Red"
            Remove-Item $Folder.FullName -recurse -Confirm:$false
        }
    }