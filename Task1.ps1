# Author   : Dr Rajeev Khoodeeram
# Location : Trios College, Ontario, Canada
# Email    : Rajeev.Khoodeeram@gmail.com


# TASK #1 : This script is used to perform user and group management in the Active directory and includes the following sub-tasks:
# Subtask #1 : List all user groups / departments in the company
# Subtask #2 : Add a department(group in AD)
# Subtask #3 : List all users / employees
# Subtask #4 : Add a user / employee


# This is a function to display the menu for the administrator to perform
# ActiveDirectory activities add group, list groups, add a user to a group and display all users
function main_menu {
    Clear-Host
    Write-Host "*************************************"
    Write-Host "TASK#1 :  MANAGING ACTIVE DIRECTORY  " -ForegroundColor Yellow
    Write-Host "*************************************"
    Write-Host "1. List departments"
    Write-Host "2. Add Department"
    Write-Host "3. List AD Employees"
    Write-Host "4. Add Employee"
    Write-Host "*************************************"
}


# This is a function which is used to add an employee in the active directory with the following parameters
# @param1 : name of employee
# @param2 : title of employee
# @param3 : email of employee
# @param4 : AD group
# @param5 : Department
# @param6 : Surname


function addEmployee {
    param(
        [string]$name,
        [string]$title,
        [string]$email,
        [string]$group,
        [string]$dept,
        [string]$surname
      )

      if ((Get-ADUser -Filter "SamAccountName -eq '$($name)'" -ErrorAction SilentlyContinue)) {
         #If user does exist, give a warning
         Write-Warning "A user account with username $($name) already exist in Active Directory."
         continue
       }
   
    # create a Hashtable with all properties you want to set for the new user
    $properties = @{
        'SamAccountName'        = $name
        'UserPrincipalName'     = '{0}@arfa.net' -f $name
        'Name'                  = '{0} {1}' -f $name, $surname
        'GivenName'             = $name
        'Surname'               = $surname
        'Enabled'               = $true
        'DisplayName'           = '{0}, {1}' -f $surname, $name
        'EmailAddress'          = $email
        'Title'                 = $title
        'Department'            = $dept
        'AccountPassword'       = (ConvertTo-SecureString "Test1234.;" -AsPlainText -Force) 
        'ChangePasswordAtLogon' = $true
    }

    # create the new user using the properties Hashtable (splat)
    Write-Host "Creating user $($_.username)" -ForegroundColor Green
    New-ADUser @properties
    Add-ADGroupMember -Identity $group -Members $name
}



# This is a function to handle the option selected by the administrator
function handler_menu {
    param (
        [int]$choice
    )


    $PSScriptRoot
    switch ($choice) {
        1 {
            Write-Host "Listing all departments  `n`n"
            # Display all the trios departments
            $departments  = Get-ADGroup -Filter 'Name -like "trios*"' | Select-Object Name
       
            Write-Host "++++++++++++++++++++++++++"
            Write-Host "There are "  $departments.Length  " main departments" -ForegroundColor Green
            Write-Host "++++++++++++++++++++++++++"

            ForEach ($dept in $departments) {
                Write-Host $dept.Name.Substring(6,$dept.Name.Length-6)
            }

            Write-Host `n`n
            $otherDepts  = Get-ADGroup -Filter 'Name -ne "trios*"' | Select-Object Name
            ForEach ($dept in $otherDepts) {
                Write-Host $dept
            }
        }
        2 {
            Write-Host "Add a department (group in AD)"
            $group = Read-Host "Name of AD Group " 
            $desc =  Read-Host "Description " 
            New-ADGroup -Name $group -Description $desc -GroupScope DomainLocal

            Write-Host "Group $group has been added" -ForegroundColor Green
        }
        3 {
            Write-Host "Listing all employees"
            Write-Host "---------------------`n`n"
            # Display all the trios employees
            $employees = Get-ADUser -Filter *
            Write-Host "++++++++++++++++++++++++++"
            Write-Host "There are "  $employees.Length  " employees" -ForegroundColor Green
            Write-Host "++++++++++++++++++++++++++"

            ForEach ($emp in $employees) {
                Write-Host $emp.Name
            }
        }
        4 {
            Write-Host "Adding a new employee"
            $name = Read-Host "First Name of employee  "
            $surname = Read-Host "Last Name of employee  "
            $title = Read-Host "Title  "
            $email = Read-Host "Email  "
            $group = Read-Host "Group  "
            $dept = Read-Host "Department "

   
            addEmployee -name $name -title $title -email $email -group $group -dept $dept -surname $surname
            Write-Host "Employee added to AD`n" -ForegroundColor Green
        }
        5 {
            Write-Host "Leaving PowerShell...." -ForegroundColor Green
            exit
        }
        default {
            Write-Host "Please choose 1 to 5 from the menu" -ForegroundColor Green
        }
    }
}

# This is the main program which display the main menu and handle the administrator input
do {
    main_menu
    $task = Read-Host "Please choose administrative task (1-5)"
    handler_menu -choice $task
    Write-Host `n
    Pause
} while ($true)