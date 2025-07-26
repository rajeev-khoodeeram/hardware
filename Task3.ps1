# Author   : Dr Rajeev Khoodeeram
# Location : Trios College, Ontario, Canada
# Email    : Rajeev.Khoodeeram@gmail.com


# TASK #3 : This script is used to perform some auditing tasks on all workstations on the network :
# Subtask #1 : Check the list of workstations enabled / disabled
# Subtask #2 : Check OS type and version of all workstations - important for carrying out updates
# Subtask #3 : Check whether password is changed regularly (security policies)
# Subtask #4 : Check if antivirus and antispyware are installed, working and up-to-date (Defender)

#. "$PSScriptRoot\include.ps1"

$credential = Get-Credential -UserName Administrator -Message "Enter your credentials"
Enter-PSSession -ComputerName Win25Server -Credential $credential
$s = New-PSSession Win25Server
Invoke-Command -Session $s -ScriptBlock {Import-Module ActiveDirectory}
Import-PSSession -Session $s -Module ActiveDirectory -Prefix REM


function main_menu {
    Clear-Host
    Write-Host "*************************************"
    Write-Host "            SECURITY TASKS           "   -ForegroundColor Yellow
    Write-Host "*************************************"
    Write-Host "1. Check the list of workstations enabled / disabled"
    Write-Host "2. Check OS type and version of all workstations - important for carrying out updatest"
    Write-Host "3. Check whether password is changed regularly (security policies"
    Write-Host "4. Check if antivirus and antispyware are installed, working and up-to-date (Defender)"
    Write-Host "5. Exit"
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
            Write-Host "Checking the list of workstations enabled / disabled  `n" -ForegroundColor Green
            $workstations = Get-ADComputer -Filter * | select name, Enabled

            $countEnabled = 0
            $countDisabled = 0

            '{0,-15}{1,10:C}' -f "Workstation", "Status"
            '{0,-15}{1,10:C}' -f "-----------", "--------"
            foreach ($w in $workstations) {
               # Write-Host $w.name $w.Enabled
               '{0,-15}{1,10:C}' -f $w.name, $w.Enabled
               if ($w.Enabled -eq $true){
                  $countEnabled++}
               else{
                  $countDisabled++
               }
            }
            Write-Host "`n**Report**" -ForegroundColor Green
            Write-Host "$countEnabled Workstations are Enabled"
            Write-Host "$countDisabled Workstations are Disabled"
            Write-Host "======================================================"
        }
        2 {
            Write-Host "Checking OS type and version of all workstations - important for carrying out updates" -ForegroundColor Green
            Get-ADComputer -Filter 'Name -like "Rajeev*"' -Properties OperatingSystem, OperatingSystemVersion | Format-Table Name, DNSHostName, OperatingSystem -AutoSize

        }
        3 {
            Write-Host "Check whether password is changed regularly (security policies)" -ForegroundColor Green
            Write-Host "---------------------`n`n"
           $Date = [DateTime]::Today.AddDays(-90)
           Get-ADComputer  -Filter 'PasswordLastSet -ge $Date'   -Properties PasswordLastSet |
           Format-Table Name, PasswordLastSet
        }
        4 {
           Write-Host "Check if antivirus and antispyware are installed, working and up-to-date (Defender)" -ForegroundColor Green
           $remoteComputers = Get-ADComputer -Filter * | Select-Object -ExpandProperty Name
           foreach ($computer in $remoteComputers) {
            Invoke-Command -ComputerName  $computer -ScriptBlock {Get-MpComputerStatus} -Credential (Get-Credential $credential) 

            Write-Host "Security status of $computer" -ForegroundColor Green
            Invoke-Command -ComputerName  $computer -ScriptBlock {Get-MpComputerStatus} -Credential (Get-Credential $credential) | Format-Table AMRunningMode, AntivirusEnabled, AntispywareSignatureLastUpdated
            }
        }
        5 {
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
    $task = Read-Host "Please choose auditing task (1-5)"
    handler_menu -choice $task
    Write-Host `n`
    Pause
} while ($true)