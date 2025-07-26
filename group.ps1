 '
    New-ADUser -Name $name -Surname $surname -OtherAttributes @{
            "Title"= $title 
            "Mail"= $email
            "Department" = $dept
          }

 '


