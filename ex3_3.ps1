#printing the environment we are using
echo $host
Write-Output $host

#EX 4 
Write-Host "red on blue" -f green -b white


$l = "left"
$r = "right"
Write-Host $l $r -f green -b white -s ","
Write-Host $l $r -f green -b white -s "`t"
Write-Host $l $r -f green -b white -s "`n"


#EX 5
Write-Output "My home is $home" 
Write-Output 'My home is $home'
Write-Output My home is `$home
Write-Output "My home is `
$home"


# Ex 3.5
$wmi = get-wmiobject -class __Namespace -namespace root
echo $wmi




# Ex 3.7

# Part A : Using if statements
$objCPU = get-wmiObject win32_processor

# Write-Output $objCPU.Architecture
# Write-Output $objCPU.Description

if ($objCPU.architecture -eq 0)
{"This is an x86 architechure"}
elseif($objCPU.architecture -eq 5)
{"This is a ARM architechure"}
elseif($objCPU.architecture -eq 9)
{"This is an x64 architechure"}
else
{"This is an alien architechture”}


# Part B : Using switch 
$objCPU = get-wmiObject win32_processor

switch ($objCPU.architecture)
{
0 {"This is an x86 architechure"}
5 {"This is an ARM architechure"}
9 {"This is an x64 architechure"}
default {"This is an alien architechture"}
}