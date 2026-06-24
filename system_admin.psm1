<#
===========================================================================
Assessment2: Operating System Information Configuration
Author: Veasna Rong
Script Name: system_admin.psm1

Virtual Machines:

    Windows Server 2022: Server1
    ip address: 192.168.1.2 255.255.255.0
    NIC: VMnet1 (Host-Only)

    Windows 11: W11Client1
    ip address: 192.168.1.102 255.255.255.0
    NIC: VMnet1 (Host-Only)

VMware network setting configured:
    Network Type: Host-Only VMnet1
    Subnet IP address: 192.168.1.0
    Subnet Mask: 255.255.255.0
=========================================================================== 
#>

#==================================================================================================
# Task 1 – Logging Function and Test Function
#==================================================================================================
# Function: Test-ServerConnection
# Purpose: Tests connectivity to a specified server and records the result in a log file.

function Test-ServerConnection {

    # Define the parameters accepted by the function
    param(

        # Computer name to test connectivity to.
        # If no value is supplied, "Server1" will be used.
        [string]$ComputerName = "Server1"
    )

    # Define the folder where log files will be stored
    $LogFolder = "C:\MyLogs"

    # Define the full path of the log file
    $LogFile = "$LogFolder\logs.txt"

    # Begin error handling block
    try {

        # Check whether the log folder exists
        if (!(Test-Path $LogFolder)) {

            # Create the log folder if it does not exist
            # Folder path to create
            # Create a directory
            # Force creation and suppress output
            New-Item `
                -Path $LogFolder `
                -ItemType Directory `
                -Force | Out-Null
        }

        # Check whether the log file exists
        if (!(Test-Path $LogFile)) {

            # Create the log file if it does not exist
            # File path to create
            # Create a file
            # Force creation and suppress output
            New-Item `
                -Path $LogFile `
                -ItemType File `
                -Force | Out-Null
        }

        # Test network connectivity to the specified computer
        if (Test-Connection -ComputerName $ComputerName -Count 1 -Quiet) {

            # Create a log entry indicating a successful connection
            $LogEntry = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Connection Successful"

            # Append the log entry to the log file
            # Log file location
            # Text to add to the file
            Add-Content `
                -Path $LogFile `
                -Value $LogEntry

            # Display the log entry on the screen
            Write-Host $LogEntry
        }
        else {

            # Create a log entry indicating the connection failed
            $LogEntry = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Connection Failed"

            # Append the log entry to the log file
            # Log file location
            # Text to add to the file
            Add-Content `
                -Path $LogFile `
                -Value $LogEntry

            # Display the log entry on the screen
            Write-Host $LogEntry
        }
    }
    catch {

        # Create a log entry containing the error message
        $LogEntry = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Error: $($_.Exception.Message)"

        # Write the error information to the log file
        # Log file location
        # Error message to record
        Add-Content `
            -Path $LogFile `
            -Value $LogEntry

        # Display the error message in PowerShell
        Write-Error $_.Exception.Message
    }
}

#==================================================================================================
# Task 2 – Promote Server to Domain Controller
#==================================================================================================

# Function: Install-MicksAndMacksAD
# Purpose: Installs the Active Directory Domain Services (AD DS) role and
# promotes Server1 to a Domain Controller for the domain VRmicksandmacks.local.

function Install-MicksAndMacksAD {

    # Define the function parameters
    param(

        # Domain name to be created.
        # If no value is supplied, VRmicksandmacks.local will be used.
        [string]$DomainName = "VRmicksandmacks.local"
    )

    # Begin error handling block
    try {

        # Check if the C:\MyLogs directory exists
        if (!(Test-Path "C:\MyLogs")) {

            # Create the C:\MyLogs directory if it does not exist
            # Directory path to create
            # Specify a folder will be created
            # Force creation and suppress output
            New-Item `
                -Path "C:\MyLogs" `
                -ItemType Directory `
                -Force | Out-Null
        }

        # Check whether the Active Directory Domain Services role
        # is installed on the server
        $ADDSRole = Get-WindowsFeature `
            -Name AD-Domain-Services

        # If the AD DS role is not installed
        if (-not $ADDSRole.Installed) {

            # Install the Active Directory Domain Services role
            # and associated management tools
            Install-WindowsFeature `
                -Name AD-Domain-Services `
                -IncludeManagementTools

            # Record the installation in the log file
            Add-Content `
                -Path "C:\MyLogs\logs.txt" `
                -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Installed Active Directory Domain Services"
        }

        # Prompt the administrator to enter a Directory Services
        # Restore Mode (DSRM) password.
        # This password is required when restoring Active Directory.
        $DSRMPassword = Read-Host `
            "Enter DSRM Password" `
            -AsSecureString

        # Promote the server to a Domain Controller and create
        # a new Active Directory forest.
        # Domain name to create
        # DSRM password
        # Install DNS service automatically
        # Skip confirmation prompts
        Install-ADDSForest `
            -DomainName $DomainName `
            -SafeModeAdministratorPassword $DSRMPassword `
            -InstallDNS `
            -Force

        # Record successful Domain Controller promotion in the log file
        Add-Content `
            -Path "C:\MyLogs\logs.txt" `
            -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Promoted Server to Domain Controller ($DomainName)"
    }

    # Catch any errors that occur during execution
    catch {

        # Record the error details in the log file
        Add-Content `
            -Path "C:\MyLogs\logs.txt" `
            -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - ERROR: $($_.Exception.Message)"

        # Display the error message in PowerShell
        Write-Error $_.Exception.Message
    }
}

#==================================================================================================
# Task 3 – add Computer client to domain
#================================================================================================== 

# Function: New-ADComputerObject
# Purpose: Prompts the administrator for a computer name and creates a new computer object in Active Directory.

function New-ADComputerObject {

    try {

        # Define log file location
        $LogFolder = "C:\MyLogs"
        $LogFile = "$LogFolder\logs.txt"

        # Create log folder if it does not exist
        if (!(Test-Path $LogFolder)) {

            New-Item `
                -Path $LogFolder `
                -ItemType Directory `
                -Force | Out-Null
        }

        # Create log file if it does not exist
        if (!(Test-Path $LogFile)) {

            New-Item `
                -Path $LogFile `
                -ItemType File `
                -Force | Out-Null
        }

        # Prompt user to enter computer name
        $ComputerName = Read-Host `
            "Enter the Computer Name to create in Active Directory"

        # Check that a computer name was entered
        if ([string]::IsNullOrWhiteSpace($ComputerName)) {

            throw "Computer name cannot be blank."
        }

        # Get the current domain distinguished name
        $DomainDN = (Get-ADDomain).DistinguishedName

        # Create the computer object in the default Computers container
        New-ADComputer `
            -Name $ComputerName `
            -SamAccountName "$ComputerName$" `
            -Path "CN=Computers,$DomainDN"

        # Create success log entry
        $LogEntry = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Created Computer Object: $ComputerName"

        # Write entry to log file
        Add-Content `
            -Path $LogFile `
            -Value $LogEntry

        # Display success message
        Write-Host "Computer object '$ComputerName' created successfully."

        Write-Host $LogEntry
    }

    catch {

        # Create error log entry
        $LogEntry = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - ERROR creating computer object: $($_.Exception.Message)"

        # Write error to log file
        Add-Content `
            -Path $LogFile `
            -Value $LogEntry

        # Display error message
        Write-Error $_.Exception.Message
    }
}

#==================================================================================================
# Task 4 – Adding OUs and new users
#================================================================================================== 

# Function: New-NewUsersOU
# Purpose: Creates a new Organizational Unit (OU) called "New_Users" in Active Directory if it does not already exist.
# All activities are recorded in a log file.

function New-NewUsersOU {

    # Enable advanced PowerShell function features
    [CmdletBinding()]
    param()

    # Define the OU name to be created
    $OUName = "New_Users"

    # Define the Active Directory domain path
    $DomainDN = "DC=VRmicksandmacks,DC=local"

    # Define the log file location
    $LogFile = "C:\MyLogs\logs.txt"

    try {

        # Load the Active Directory module
        Import-Module ActiveDirectory -ErrorAction Stop

        # Create the log directory if it does not already exist
        if (!(Test-Path "C:\MyLogs")) {

            New-Item `
                -Path "C:\MyLogs" `
                -ItemType Directory `
                -Force | Out-Null
        }

        # Check whether the OU already exists in Active Directory
        $ExistingOU = Get-ADOrganizationalUnit `
            -Filter "Name -eq '$OUName'" `
            -ErrorAction SilentlyContinue

        # If the OU exists, log the result and stop processing
        if ($ExistingOU) {

            $Message = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - OU '$OUName' already exists"

            # Write the message to the log file
            Add-Content `
                -Path $LogFile `
                -Value $Message

            # Display the message on screen
            Write-Host $Message

            # Exit the function
            return
        }

        # Create the new Organizational Unit in Active Directory
        New-ADOrganizationalUnit `
            -Name $OUName `
            -Path $DomainDN `
            -ProtectedFromAccidentalDeletion $false

        # Create a success message
        $Message = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Created OU '$OUName'"

        # Record the successful creation in the log file
        Add-Content `
            -Path $LogFile `
            -Value $Message

        # Display the success message
        Write-Host $Message
    }
    catch {

        # Create an error message if the operation fails
        $Message = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - ERROR creating OU '$OUName' : $($_.Exception.Message)"

        # Record the error in the log file
        Add-Content `
            -Path $LogFile `
            -Value $Message

        # Display the error message
        Write-Error $_.Exception.Message
    }
}

<#

# Create the Destination Folder on Server1 directory "C:\Import"
Invoke-Command `
    -Session $Session `
    -ScriptBlock {

        if (!(Test-Path "C:\Import")) {

            New-Item `
                -Path "C:\Import" `
                -ItemType Directory `
                -Force
        }
    }

# Copy "Users.csv" to Server1 directory "C:\Import"
Copy-Item `
    -Path "C:\Import\Users.csv" `
    -Destination "C:\Import\Users.csv" `
    -ToSession $Session `
    -Force

# Verify the File Exists on Server1 directory "C:\Import"
Invoke-Command `
    -Session $Session `
    -ScriptBlock {

        Get-Item `
            "C:\Import\Users.csv"
    }

#>

# Function: Import-NewUsers
# Purpose: Imports user accounts from a CSV file and creates them in the "New_Users" Organizational Unit within Active Directory.

function Import-NewUsers {

    # Define the CSV file path parameter.
    # If no path is supplied, the default location is used.
    param(
        [string]$CsvPath = "C:\Import\Users.csv"
    )

    # Load the Active Directory module so AD cmdlets can be used.
    Import-Module ActiveDirectory

    # Define the destination Organizational Unit (OU)
    # where new user accounts will be created.
    $OUPath = "OU=New_Users,DC=VRmicksandmacks,DC=local"

    # Import all user records from the CSV file.
    $Users = Import-Csv $CsvPath

    # Process each user record in the CSV file.
    foreach ($User in $Users) {

        # Convert the plain text password from the CSV file
        # into a SecureString required by Active Directory.
        $SecurePassword = ConvertTo-SecureString `
            $User.Password `
            -AsPlainText `
            -Force

        # Extract the username portion from the email-style
        # User Logon Name to create the SamAccountName.
        $SamAccountName = $User.UserLogonName.Split("@")[0]

        # Create a new Active Directory user account.
        New-ADUser `
            -Name "$($User.FirstName) $($User.LastName)" `
            -GivenName $User.FirstName `
            -Surname $User.LastName `
            -DisplayName "$($User.FirstName) $($User.LastName)" `
            -SamAccountName $SamAccountName `
            -UserPrincipalName $User.UserLogonName `
            -AccountPassword $SecurePassword `
            -Enabled $true `
            -Path $OUPath

        # Check if the CSV specifies that the user's
        # password should never expire.
        if ($User.PasswordNeverExpires -eq "True") {

            # Configure the account so the password
            # never expires.
            Set-ADUser `
                -Identity $SamAccountName `
                -PasswordNeverExpires $true
        }

        # Display a confirmation message showing
        # which user account was created.
        Write-Host "Created user: $($User.UserLogonName)"
    }
}


#==================================================================================================
# Task 5 – Join Computer to Domain
#================================================================================================== 

# This is done on the client's System.

#==================================================================================================
# Task 6 – Configure DHCP Scope
#================================================================================================== 

# Function: Install-DHCPServer
# Purpose: Installs and configures the DHCP Server role on Windows Server 2022.
# The function creates a DHCP scope, configures gateway and DNS settings and records all activities in a log file.

function Install-DHCPServer {

    # Enable advanced PowerShell function features
    [CmdletBinding()]
    param()

    # Define the log folder and log file locations
    $LogFolder = "C:\MyLogs"
    $LogFile   = "$LogFolder\logs.txt"

    try {

        # Create the log folder if it does not already exist
        if (!(Test-Path $LogFolder)) {

            New-Item `
                -Path $LogFolder `
                -ItemType Directory `
                -Force | Out-Null
        }

        # Create the log file if it does not already exist
        if (!(Test-Path $LogFile)) {

            New-Item `
                -Path $LogFile `
                -ItemType File `
                -Force | Out-Null
        }

        # Check whether the DHCP Server role is already installed
        $DHCPFeature = Get-WindowsFeature `
            -Name DHCP

        # Install the DHCP role if it is not currently installed
        if (-not $DHCPFeature.Installed) {

            Install-WindowsFeature `
                -Name DHCP `
                -IncludeManagementTools

            # Record successful installation in the log file
            Add-Content `
                -Path $LogFile `
                -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Installed DHCP Server Role"
        }
        else {

            # Record that DHCP was already installed
            Add-Content `
                -Path $LogFile `
                -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - DHCP Server Role already installed"
        }

        # Authorize the DHCP Server in Active Directory
        # so it can issue IP addresses to clients
        Add-DhcpServerInDC `
            -DnsName "Server1.VRmicksandmacks.local" `
            -IPAddress "192.168.1.2" `
            -ErrorAction SilentlyContinue

        # Check whether the DHCP scope already exists
        $ExistingScope = Get-DhcpServerv4Scope `
            -ErrorAction SilentlyContinue |
            Where-Object { $_.ScopeId -eq "10.1.1.0" }

        # If the scope exists, record the event and stop processing
        if ($ExistingScope) {

            $Message = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - DHCP Scope 10.1.1.0 already exists"

            Add-Content `
                -Path $LogFile `
                -Value $Message

            Write-Host $Message

            return
        }

        # Create a new DHCP scope for the 10.1.1.0/24 network
        Add-DhcpServerv4Scope `
            -Name "MicksAndMacksScope" `
            -StartRange 10.1.1.10 `
            -EndRange 10.1.1.254 `
            -SubnetMask 255.255.255.0 `
            -State Active

        # Configure the default gateway option
        # that DHCP clients will receive
        Set-DhcpServerv4OptionValue `
            -ScopeId 10.1.1.0 `
            -Router 10.1.1.1

        # Configure the DNS server and DNS domain
        # that DHCP clients will receive
        Set-DhcpServerv4OptionValue `
            -ScopeId 10.1.1.0 `
            -DnsServer 192.168.1.2 `
            -DnsDomain "VRmicksandmacks.local"

        # Create a success message
        $Message = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Created DHCP Scope 10.1.1.0/24"

        # Record successful DHCP configuration in the log file
        Add-Content `
            -Path $LogFile `
            -Value $Message

        # Display success message on screen
        Write-Host $Message
    }
    catch {

        # Create an error message if the installation or configuration fails
        $Message = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - ERROR installing DHCP: $($_.Exception.Message)"

        # Record the error in the log file
        Add-Content `
            -Path $LogFile `
            -Value $Message

        # Display the error message
        Write-Error $_.Exception.Message
    }
}


#==================================================================================================
# Task 7 – Top Ten System Errors
#================================================================================================== 

# Function: Get-TopTenSystemErrors
# Purpose: Retrieves the top 10 System Error events from the Windows Event Viewer on a specified computer and saves the results to a text file.
# All activity is recorded in a log file.

function Get-TopTenSystemErrors {

    # Enable advanced PowerShell function features
    [CmdletBinding()]
    param(

        # Specify the target computer.
        # If no computer name is supplied, the local computer is used.
        [string]$ComputerName = "localhost"
    )

    # Define the log folder and file locations
    $LogFolder  = "C:\MyLogs"
    $OutputFile = "$LogFolder\toptenerrors.txt"
    $LogFile    = "$LogFolder\logs.txt"

    try {

        # Create the log directory if it does not already exist
        if (!(Test-Path $LogFolder)) {

            New-Item `
                -Path $LogFolder `
                -ItemType Directory `
                -Force | Out-Null
        }

        # Retrieve System log entries from Event Viewer
        # and select the first 10 events classified as Errors
        $Errors = Get-WinEvent `
            -ComputerName $ComputerName `
            -LogName System `
            -MaxEvents 1000 |
            Where-Object { $_.LevelDisplayName -eq "Error" } |
            Select-Object `
                -First 10 `
                TimeCreated,
                Id,
                ProviderName,
                LevelDisplayName,
                Message

        # Save the error information to a text file
        # for later review or troubleshooting
        $Errors |
            Format-Table -AutoSize |
            Out-String |
            Set-Content $OutputFile

        # Record the successful operation in the log file
        Add-Content `
            -Path $LogFile `
            -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Retrieved top 10 System errors from $ComputerName"

        # Display the output file location to the user
        Write-Host "Top 10 System errors saved to:"
        Write-Host $OutputFile
    }
    catch {

        # Record any errors that occur during execution
        Add-Content `
            -Path $LogFile `
            -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - ERROR retrieving System errors from $ComputerName"

        # Display the error message
        Write-Error $_.Exception.Message
    }
}


#==================================================================================================
# Task 8 – Schedule Disk Cleanup
#================================================================================================== 

# Function: Register-DiskCleanupTask
# Purpose: Creates and registers a scheduled task that runs Disk Cleanup every day at 6:00 AM.
# The function can operate on either the local computer or a remote computer specified by the user.
# All activity is recorded in a log file.

function Register-DiskCleanupTask {

    # Enable advanced PowerShell function features
    [CmdletBinding()]
    param(

        # Specify the target computer.
        # If no computer name is supplied, localhost is used.
        [string]$ComputerName = "localhost"
    )

    # Define the log folder and log file locations
    $LogFolder = "C:\MyLogs"
    $LogFile   = "$LogFolder\logs.txt"

    try {

        # Check whether the task should be created locally
        if ($ComputerName -eq "localhost") {

            # Create the log directory if it does not exist
            if (!(Test-Path $LogFolder)) {

                New-Item `
                    -Path $LogFolder `
                    -ItemType Directory `
                    -Force | Out-Null
            }

            # Define the action that the scheduled task will perform
            # In this case, it runs the Windows Disk Cleanup utility
            $Action = New-ScheduledTaskAction `
                -Execute "cleanmgr.exe"

            # Create a trigger that runs every day at 6:00 AM
            $Trigger = New-ScheduledTaskTrigger `
                -Daily `
                -At 6:00AM

            # Register the scheduled task with Windows Task Scheduler
            Register-ScheduledTask `
                -TaskName "DailyDiskCleanup" `
                -Action $Action `
                -Trigger $Trigger `
                -RunLevel Highest `
                -Force

            # Record the successful task creation in the log file
            Add-Content `
                -Path $LogFile `
                -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Registered DailyDiskCleanup task on localhost"

            # Display a success message
            Write-Host "Disk Cleanup task registered successfully on localhost."
        }
        else {

            # Use PowerShell Remoting to create the task
            # on a remote computer
            Invoke-Command `
                -ComputerName $ComputerName `
                -ScriptBlock {

                    # Define log locations on the remote computer
                    $LogFolder = "C:\MyLogs"
                    $LogFile   = "$LogFolder\logs.txt"

                    # Create the log directory if required
                    if (!(Test-Path $LogFolder)) {

                        New-Item `
                            -Path $LogFolder `
                            -ItemType Directory `
                            -Force | Out-Null
                    }

                    # Create the Disk Cleanup task action
                    $Action = New-ScheduledTaskAction `
                        -Execute "cleanmgr.exe"

                    # Create a daily trigger for 6:00 AM
                    $Trigger = New-ScheduledTaskTrigger `
                        -Daily `
                        -At 6:00AM

                    # Register the scheduled task
                    Register-ScheduledTask `
                        -TaskName "DailyDiskCleanup" `
                        -Action $Action `
                        -Trigger $Trigger `
                        -RunLevel Highest `
                        -Force

                    # Record the successful task creation
                    # in the remote computer's log file
                    Add-Content `
                        -Path $LogFile `
                        -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Registered DailyDiskCleanup task"

                }

            # Display a success message for the remote computer
            Write-Host "Disk Cleanup task registered successfully on $ComputerName."
        }
    }
    catch {

        # Record any errors that occur during task creation
        Add-Content `
            -Path $LogFile `
            -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - ERROR registering DailyDiskCleanup task on $ComputerName"

        # Display the error message
        Write-Error $_.Exception.Message
    }
}

<#
#Check the Trigger
(Get-ScheduledTask `
    -TaskName "DailyDiskCleanup").Triggers
#>

#==================================================================================================
# Task 9 – Drive Mapping Script
#================================================================================================== 

# Function: New-SharedDriveGPO
# Purpose: Creates a Group Policy Object (GPO) that will be used to map the shared folder \\SERVER1\mickandmacks_share as drive S: for domain users.

function New-SharedDriveGPO {

    [CmdletBinding()]
    param()

    # Define log locations
    $LogFolder = "C:\MyLogs"
    $LogFile   = "$LogFolder\logs.txt"

    # Define GPO settings
    $GPOName = "GPO_MapSharedDrive"

    try {

        # Load required modules
        Import-Module GroupPolicy -ErrorAction Stop
        Import-Module ActiveDirectory -ErrorAction Stop

        # Create log folder if required
        if (!(Test-Path $LogFolder)) {

            New-Item `
                -Path $LogFolder `
                -ItemType Directory `
                -Force | Out-Null
        }

        # Create log file if required
        if (!(Test-Path $LogFile)) {

            New-Item `
                -Path $LogFile `
                -ItemType File `
                -Force | Out-Null
        }

        # Check whether the GPO already exists
        $ExistingGPO = Get-GPO `
            -Name $GPOName `
            -ErrorAction SilentlyContinue

        if (-not $ExistingGPO) {

            # Create the GPO
            New-GPO `
                -Name $GPOName

            Add-Content `
                -Path $LogFile `
                -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Created GPO '$GPOName'"
        }
        else {

            Add-Content `
                -Path $LogFile `
                -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - GPO '$GPOName' already exists"
        }

        # Get domain distinguished name
        $DomainDN = (Get-ADDomain).DistinguishedName

        # Link the GPO to the New_Users OU
        New-GPLink `
            -Name $GPOName `
            -Target "OU=New_Users,$DomainDN" `
            -LinkEnabled Yes `
            -ErrorAction SilentlyContinue

        Add-Content `
            -Path $LogFile `
            -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Linked GPO '$GPOName' to New_Users OU"

        Write-Host ""
        Write-Host "GPO Created Successfully"
        Write-Host "GPO Name: $GPOName"
        Write-Host ""
        Write-Host "Next Step:"
        Write-Host "Open Group Policy Management and configure:"
        Write-Host "User Configuration"
        Write-Host " -> Preferences"
        Write-Host " -> Windows Settings"
        Write-Host " -> Drive Maps"
        Write-Host ""
        Write-Host "Drive Letter : S:"
        Write-Host "Location     : \\SERVER1\mickandmacks_share"
    }

    catch {

        Add-Content `
            -Path $LogFile `
            -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - ERROR creating Shared Drive GPO : $($_.Exception.Message)"

        Write-Error $_.Exception.Message
    }
}