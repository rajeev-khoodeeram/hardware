# Code to login to the server - here as administrator
$cred = Get-Credential
Enter-PSSession -ComputerName Win25Server -Credential $cred

 New-ADUser -Name "Jsadasdogn cena" -OtherAttributes @{
            "title"= "Mr" 
            "mail"= "testing@arfa.net"
          }


$users = Get-ADUser -Filter *

$groups  = Get-ADGroup -Filter *

