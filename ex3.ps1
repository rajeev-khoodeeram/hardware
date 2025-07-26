$name = "Rajeev"
Write-Output "$name"

$colors = @("Python", "Java", "C++")
Write-Output "The first element of the array " $colors[0]


foreach ($color in $colors){
    Write-Output $color
}


Write-Output $colors.Length
Write-Output $colors.Count

$val = 100
Write-Output ($val -gt 200)


$hashex = @{
    name = 'john'
    age = 23
}


Write-Output "Name of person : $($hashex['name'])"

#Multiline string
$longMsg = ("sdsds
sdsadasd
sdasdasd")

$longMsg2 = @"
I am 
from triOS
Toronto, CA
"@



Write-Output $longMsg

Write-Output $longMsg2

$longMsg2.Contains("toronto")


#Escaping charaters
$price = 345
Write-Output "The price of cake is $ $price"

$num = 10

for ($i=1; $i -lt 5; $i++){
    Write-Output "$num * $i ="($num * $i)
}


function addNum {
    param (
        [int] $a=2,
        [int] $b=3
    )
    
    $sum = $a + $b
    Write-Output $sum
}

addNum