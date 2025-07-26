# Import the Active Directory module

$cred = Get-Credential
Enter-PSSession -ComputerName Win25Server -Credential $cred
$s = New-PSSession Win25Server
Invoke-Command -Session $s -ScriptBlock {Import-Module ActiveDirectory}
Import-PSSession -Session $s -Module ActiveDirectory -Prefix REM

# Get all groups from Active Directory

Get-ADGroup -Filter *

# Display all the trios departments
$departments  = Get-ADGroup -Filter 'Name -like "trios*"' | Select-Object Name

ForEach ($dept in $departments) {
Write-Host $dept.Name.Substring(6,$dept.Name.Length-6)
}

Get-ADComputer -Filter *
Get-WMIObject win32_diskdrive -ComputerName RajeevOne | Where-Object MediaType -eq 'Fixed hard drive media' | Select SystemName,Model
