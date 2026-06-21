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
function Test-ServerConnection {

    param(
        [string]$ComputerName = "Server1"
    )

    $LogFolder = "C:\myLogs"
    $LogFile = "$LogFolder\logs.txt"

    try {

        # Create log folder if it doesn't exist
        if (!(Test-Path $LogFolder)) {

            New-Item `
                -Path $LogFolder `
                -ItemType Directory `
                -Force | Out-Null
        }

        # Create log file if it doesn't exist
        if (!(Test-Path $LogFile)) {

            New-Item `
                -Path $LogFile `
                -ItemType File `
                -Force | Out-Null
        }

        # Test connectivity
        if (Test-Connection -ComputerName $ComputerName -Count 1 -Quiet) {

            $LogEntry = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Connection Successful"

            Add-Content `
                -Path $LogFile `
                -Value $LogEntry

            Write-Host $LogEntry
        }
        else {

            $LogEntry = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Connection Failed"

            Add-Content `
                -Path $LogFile `
                -Value $LogEntry

            Write-Host $LogEntry
        }
    }
    catch {

        $LogEntry = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Error: $($_.Exception.Message)"

        Add-Content `
            -Path $LogFile `
            -Value $LogEntry

        Write-Error $_.Exception.Message
    }
}

#==================================================================================================
# Task 2 – Promote Server to Domain Controller
#==================================================================================================

function Install-MicksAndMacksAD {

    param(
        [string]$DomainName = "VRmicksandmacks.local"
    )

    try {

        # Create log folder if required
        if (!(Test-Path "C:\myLogs")) {

            New-Item `
                -Path "C:\myLogs" `
                -ItemType Directory `
                -Force | Out-Null
        }

        # Install AD DS Role if not already installed
        $ADDSRole = Get-WindowsFeature `
            -Name AD-Domain-Services

        if (-not $ADDSRole.Installed) {

            Install-WindowsFeature `
                -Name AD-Domain-Services `
                -IncludeManagementTools

            Add-Content `
                -Path "C:\myLogs\logs.txt" `
                -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Installed Active Directory Domain Services"
        }

        # Prompt for DSRM Password
        $DSRMPassword = Read-Host `
            "Enter DSRM Password" `
            -AsSecureString

        # Promote Server to Domain Controller
        Install-ADDSForest `
            -DomainName $DomainName `
            -SafeModeAdministratorPassword $DSRMPassword `
            -InstallDNS `
            -Force

        Add-Content `
            -Path "C:\myLogs\logs.txt" `
            -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Promoted Server to Domain Controller ($DomainName)"
    }

    catch {

        Add-Content `
            -Path "C:\myLogs\logs.txt" `
            -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - ERROR: $($_.Exception.Message)"

        Write-Error $_.Exception.Message
    }
}



# Task 3 – Connect to Domain Computer

# Task 4a – Create OUs from CSV

# Task 4b – Create Users from CSV

# Task 5 – Join Computer to Domain

# Task 6 – Configure DHCP Scope

# Task 7 – Top Ten System Errors

# Task 8 – Schedule Disk Cleanup

# Task 9 – Drive Mapping Script