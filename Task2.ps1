# Author   : Dr Rajeev Khoodeeram
# Location : Trios College, Ontario, Canada
# Email    : Rajeev.Khoodeeram@gmail.com


# TASK #2 : This script ised by the network administrator to carry out three main auditing tasks on all workstations on the network
# Subtask #1 : Verifying disk usage 
# Subtask #2 : Checking CPU usage 
# Subtask #3 : Getting Memory used by workstation

# Logic can be added to verify certain threshold for each subtask and warn respective users and actions to be taken
# For example - Disk usage is checked and if under certain value, warning message is displayed on the screen


# Define a credential if needed
$credential = Get-Credential -UserName Administrator -Message "Enter your credentials"
Enter-PSSession -ComputerName Win25Server -Credential $credential
$s = New-PSSession Win25Server
Invoke-Command -Session $s -ScriptBlock {Import-Module ActiveDirectory}
Import-PSSession -Session $s -Module ActiveDirectory -Prefix REM


# Define the list of remote computers
# $remoteComputers = @("RajeevOne", "RajeevTwo")
$remoteComputers = Get-ADComputer -Filter * | Select-Object -ExpandProperty Name
Write-Host "`n`n****************  VERIFYING HARD DISK, CPU AND MEMORY USAGE *********************" -ForegroundColor Yellow


function main_menu {
    Clear-Host
    Write-Host "*************************************"
    Write-Host "            AUDITING TASKS           "   -ForegroundColor Yellow
    Write-Host "*************************************"
    Write-Host "1. Check HARD DISK usage"
    Write-Host "2. Check CPU usage"
    Write-Host "3. Check Memory usage"
    Write-Host "4. Exit"
    Write-Host "*************************************"
}



# This is a function to handle the option selected by the administrator
function handler_menu {
    param (
        [int]$choice
    )


    $PSScriptRoot
    switch ($choice) {
        1 {
           Write-Host "`n`n++++++++++++++++++++++ HARD DISK VERIFICATION +++++++++++++++++++++++++" -ForegroundColor Green

           # Loop through each remote computer and gather disk information
            foreach ($computer in $remoteComputers) {
                try {
                    If (!($computer.Contains("SERVER"))){
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
                        Write-Host "`nWARNING : Must review for $computer (less than 20 GB disk space available)" -f Red
                        }
                    }
            }

            } catch {
                Write-Host "Failed to retrieve disk information from $computer"
            }
        }
                Write-Host "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
        }
        2 {
          
            Write-Host "`n`n+++++++++++++++++++++++++++ CPU VERIFICATION +++++++++++++++++++++++++++"  -ForegroundColor Green
            Write-Host `n
            # Loop through each remote computer and gather CPU information
            $count = 0
            foreach ($computer in $remoteComputers) {
                try {
                 If (!($computer.Contains("SERVER"))){
                Write-Host $count'.Workstation : '$computer  -ForegroundColor Green
                Invoke-Command -ComputerName  $computer -ScriptBlock {"CPU Usage :"+[math]::round((Get-Counter '\Processor(_Total)\% Processor Time').CounterSamples.CookedValue,2)+" %"}
                Write-Host `n
                }
              } catch {
                    Write-Host "Failed to retrieve disk information from $computer"
                }
                $count++
            }
            Write-Host "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
 
        }
        3 {
        Write-Host "`n`n++++++++++++++++++++++++ Memory VERIFICATION +++++++++++++++++++++++++++"  -ForegroundColor Green

        Write-Host "`n---------------------------------------------------------------------------"
        '{0,-15}{1,20}{2,30}' -f "Worstation","Total Visible Memory (GB)", "Free Physical Memory (GB)"
        Write-Host "---------------------------------------------------------------------------"
  
        # Loop through each remote computer and gather Memory information
        $count = 0
        foreach ($computer in $remoteComputers) {
            try {
             If (!($computer.Contains("SERVER"))){
            # Write-Host $count'.Workstation : '$computer
            $info = Invoke-Command -ComputerName $computer -ScriptBlock { Get-WmiObject -Class Win32_OperatingSystem | Select-Object  TotalVisibleMemorySize, FreePhysicalMemory} -Credential $credential
  
           
           # [PSCustomObject]@{
            #            ComputerName = $computer
            #            Total_Memory  = $info.TotalVisibleMemorySize
            #            Free_Memory = $info.FreePhysicalMemory
            #        }
            If ($count -eq 0){}
            else
            {Write-Host `n}
             $phy = [math]::round($info.FreePhysicalMemory / (1024 * 1024),2)
             $total  = [math]::round($info.TotalVisibleMemorySize / (1024 * 1024),2)
            '{0,-15}{1,20}{2,20}' -f $computer, $total, $phy
             

            If ($info.FreePhysicalMemory -lt 1700000)
            {
            Write-Host "Issue with $computer (Worstation is consuming too much memory  > 60%)" -ForegroundColor Red
            Write-Host `n
            }

             }
   
          } catch {
                Write-Host "Failed to retrieve disk information from $computer"
            }
    
        ++$count
        }
            
        }
       
        4 {
         Write-Host "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
         Write-Host "`n`n*********  END OF TASK #2 - VERIFYING HARD DISK, CPU AND MEMORY USAGE *********" -ForegroundColor Yellow
       
            Write-Host "Leaving PowerShell...." -ForegroundColor Green
            exit
        }
        default {
            Write-Host "Please choose 1 to 4 from the menu" -ForegroundColor Green
        }
    }
}


# This is the main program which display the main menu and handle the administrator input
do {
    main_menu
    $task = Read-Host "Please choose auditing task (1-4)"
    handler_menu -choice $task
    Write-Host `n`
    Pause
} while ($true)