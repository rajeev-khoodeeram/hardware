/*
 * MainProgram.ps1
 * This script provides a menu-driven interface for administrative tasks such as Active Directory management, auditing, and security checks.
 * It uses PowerShell remoting to execute scripts on a remote server.
 * Created by: Dr Rajeev Khoodeeram
 * Date: 2025-04-10
 * Version: 1.0
 * License: Free
 */
$credential = Get-Credential -UserName Administrator -Message "Enter your credentials"
Enter-PSSession -ComputerName Win25Server -Credential $credential
$s = New-PSSession Win25Server
Invoke-Command -Session $s -ScriptBlock {Import-Module ActiveDirectory}
Import-PSSession -Session $s -Module ActiveDirectory -Prefix REM


function main_menu {
    Clear-Host
    Write-Host "*************************************"
    Write-Host "            ADMINISTRATIVE TASK           "   -ForegroundColor Yellow
    Write-Host "*************************************"
    Write-Host "1. Active Directory (User and Group Management)"
    Write-Host "2. Auditing (Disk, CPU and Memory usage)"
    Write-Host "3. Security (Enabled/Disabled, Antivirus,Password change, OS versioning for updates)"
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
              $testinc = "C:\Users\client1.ARFA\Documents\Task1.ps1"
            Invoke-Command -ComputerName RajeevOne -ScriptBlock {param($testinc)
            & $testinc} -ArgumentList $testinc
          
        }
        2 {
              $testinc = "C:\Users\client1.ARFA\Documents\Task2.ps1"
            Invoke-Command -ScriptBlock {param($testinc)
            & $testinc} -ArgumentList $testinc
        }
         3 {
             $testinc = "C:\Users\client1.ARFA\Documents\Task3.ps1"
            Invoke-Command -ComputerName RajeevOne -ScriptBlock {param($testinc)
            & $testinc} -ArgumentList $testinc
        }
        
        
        4 {
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
    $task = Read-Host "Please choose administrative task (1-5)"
    handler_menu -choice $task
    Write-Host `n`
    Pause
} while ($true)