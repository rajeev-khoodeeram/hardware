# Import the Active Directory module

$cred = Get-Credential -UserName Administrator -Message "Enter your credentials"
Enter-PSSession -ComputerName Win25Server -Credential $cred
$s = New-PSSession Win25Server
Invoke-Command -Session $s -ScriptBlock {Import-Module ActiveDirectory}
Import-PSSession -Session $s -Module ActiveDirectory -Prefix REM

# Get all groups from Active Directory

Get-ADGroup -Filter *

Get-ADComputer -Filter *

# Get-WmiObject win32_diskdrive -ComputerName RajeevOne


# Get-CimInstance -ClassName win32_diskdrive -ComputerName RajeevOne


Write-Host "++++++++++++++++++++++++++++++++++++++++++++++++++"
Get-WmiObject -Class Win32_logicalDisk -ComputerName RajeevOne
Get-WmiObject -Class Win32_logicalDisk -ComputerName RajeevTwo
Write-Host "++++++++++++++++++++++++++++++++++++++++++++++++++"

#-Credential client1@arfa.net

Get-ADComputer -Identity "RajeevOne" -Properties *
Get-ADComputer -Identity "RajeevTwo" -Properties *
Get-ADComputer -Filter 'Name -like "Rajeev*"' -Properties IPv4Address |
    Format-Table Name, DNSHostName, IPv4Address -AutoSize


##########################    TASKS 2 - AUDITING #####################################
# Checks if computer is enabled or disabled in active directory --works 
Get-ADComputer -Filter * | select name, Enabled


# Checks OS version of all workstation --works 
Get-ADComputer -Filter 'Name -like "Rajeev*"' -Properties OperatingSystem, OperatingSystemVersion | Format-Table Name, DNSHostName, OperatingSystem -AutoSize


# Example 3: Gets all computers that have changed their password in specific time frame --works
$Date = [DateTime]::Today.AddDays(-90)
Get-ADComputer  -Filter 'PasswordLastSet -ge $Date'   -Properties PasswordLastSet |
    Format-Table Name, PasswordLastSet


Invoke-Command -ComputerName  RajeevOne -ScriptBlock {Get-MpComputerStatus} -Credential (Get-Credential $credential) 
Invoke-Command -ComputerName  RajeevOne -ScriptBlock {Get-MpComputerStatus} -Credential (Get-Credential $credential) | Format-Table AMRunningMode, AntivirusEnabled, AntispywareSignatureLastUpdated

##########################  END OF TASKS 2  #####################################


Get-PhysicalDisk


$workstations = Get-ADComputer -Filter * | Select-Object -ExpandProperty Name

ForEach ($node in $workstations) {
Write-Host $node
Write-Host $node.Substring($node.Length-6, 6)

# $disk =  Get-WmiObject Win32_LogicalDisk -ComputerName $node -Filter "DriverType=3"
If ($node.Substring($node.Length-6, 6) -ne  "Server"){
$disk =  Invoke-Command -ComputerName $node -ScriptBlock {
Get-WmiObject -Class Win32_LogicalDisk -Filter "DriveType=3"| Select-Object SystemName
}
}
Write-Host $disk

#$details  = Get-CimInstance -ComputerName $node win32_logicaldisk | where caption -eq "C:" | foreach-object {write " $ ($_.caption) $ (' {0:N2}' -f ($_.Size/1gb)) GB total, $ (' {0:N2}' -f ($_.FreeSpace/1gb)) GB free "}
#Write-Host $details

# Get-WmiObject -Class win32_logicaldisk -ComputerName $node
# Invoke-Command -ComputerName $node {Get-PSDrive C} | Select-Object PSComputerName,Used,Free | Format PSComputerName
}

# This works on the command line; replace $node with the computer name
Invoke-Command -ComputerName RajeevOne {Get-PSDrive C} | Select-Object PSComputerName,Used,Free | Format PSComputerName



#################################   TASK 2   #######################################################

# Define a credential if needed
$credential = Get-Credential -UserName Administrator -Message "Enter your credentials"

# Define the list of remote computers
$remoteComputers = @("RajeevOne", "RajeevTwo")
Write-Host "`n`n****************  VERIFYING HARD DISK, CPU AND MEMORY USAGE *********************" -ForegroundColor Yellow
Write-Host "`n`n++++++++++++++++++++++ HARD DISK VERIFICATION +++++++++++++++++++++++++"

# Loop through each remote computer and gather disk information
foreach ($computer in $remoteComputers) {
    try {

        # Use Get-WmiObject to retrieve disk information
        $disks =Invoke-Command -ComputerName $computer -ScriptBlock { Get-WmiObject -Class Win32_LogicalDisk  -Filter "DriveType=3"
        }


        # Display the disk information
        foreach ($disk in $disks) {
        
            [PSCustomObject]@{
                ComputerName = $computer
                DriveLetter  = $disk.DeviceID
                SizeGB       = [math]::round($disk.Size / 1GB, 2)
                FreeSpaceGB  = [math]::round($disk.FreeSpace / 1GB, 2)
            }
            
            If ([math]::round($disk.FreeSpace / 1GB, 2) -lt 20) {
            Write-Host "`nMust review for $computer (less than 20 GB disk space available)" -f Red
            }
        }

    } catch {
        Write-Host "Failed to retrieve disk information from $computer"
    }
}
Write-Host "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"


Write-Host "`n`n+++++++++++++++++++++++++++ CPU VERIFICATION +++++++++++++++++++++++++++"
Write-Host `n
# Loop through each remote computer and gather CPU information
$count = 1
foreach ($computer in $remoteComputers) {
    try {
    Write-Host $count'.Workstation : '$computer
    Invoke-Command -ComputerName  $computer -ScriptBlock {"CPU Usage :"+[math]::round((Get-Counter '\Processor(_Total)\% Processor Time').CounterSamples.CookedValue,2)+" %"}
    Write-Host `n
  } catch {
        Write-Host "Failed to retrieve disk information from $computer"
    }
    $count++
}
Write-Host "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"



Write-Host "`n`n+++++++++++++++++++++++++++ Memory VERIFICATION +++++++++++++++++++++++++++"
# Loop through each remote computer and gather Memory information

foreach ($computer in $remoteComputers) {
    try {
    # Write-Host $count'.Workstation : '$computer
    $info = Invoke-Command -ComputerName $computer -ScriptBlock { Get-WmiObject -Class Win32_OperatingSystem | Select-Object  TotalVisibleMemorySize, FreePhysicalMemory} -Credential $credential
  
    If ($info.FreePhysicalMemory -lt 1620000)
    {
    Write-Host "Issue with $computer" -ForegroundColor Red
    }
    [PSCustomObject]@{
                ComputerName = $computer
                Total_Memory  = $info.TotalVisibleMemorySize
                Free_Memory = $info.FreePhysicalMemory
            }

   
  } catch {
        Write-Host "Failed to retrieve disk information from $computer"
    }
    
}
Write-Host "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"






# Get status of antivirus (defender) - works
# Invoke-Command -ComputerName  RajeevOne -ScriptBlock {Get-MpComputerStatus} -Credential (Get-Credential $credential) 
# Invoke-Command -ComputerName  RajeevOne -ScriptBlock {Get-MpComputerStatus} -Credential (Get-Credential $credential) | Format-Table AMRunningMode, AntivirusEnabled, AntispywareSignatureLastUpdated


# Get CPU Usage - works
# Invoke-Command -ComputerName  RajeevOne -ScriptBlock {(Get-Counter '\Processor(_Total)\% Processor Time').CounterSamples.CookedValue} -Credential (Get-Credential) 
# Invoke-Command -ComputerName  RajeevTwo -ScriptBlock {(Get-Counter '\Processor(_Total)\% Processor Time').CounterSamples.CookedValue} -Credential (Get-Credential) 

# Get Memory-Usage
# Invoke-Command -ComputerName RajeevOne -ScriptBlock { Get-WmiObject -Class Win32_OperatingSystem | Select-Object  TotalVisibleMemorySize, FreePhysicalMemory} -Credential (Get-Credential) 