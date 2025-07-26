#Import-Module activedirectory
$cred = Get-Credential
#$CimSession = New-CimSession -ComputerName Win25Server -SessionOption $DCOM -Credential $Cred
#Get-CimInstance -CimSession $CimSession -ClassName Win32_BIOS
Enter-PSSession -ComputerName Win25Server -Credential $cred



#Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
New-ADUser -Name "donjoe" -OtherAttributes @{
    "title"="direcsadsdstor" 
    "mail"="sdsds@fabrikam.com"
}