# Function: Join-MicksAndMacksDomain
# Purpose: Joins the client computer to the VRmicksandmacks.local domain.
# The function verifies connectivity, checks DNS resolution,
# creates domain credentials, joins the computer to the domain,
# logs all activities, and restarts the computer when complete.

function Join-VRMicksAndMacksDomain {

    # Define default settings for the domain,
    # domain controller, and log file location.
    [CmdletBinding()]
    param()

    $DomainName = "VRmicksandmacks.local"
    $DomainController = "192.168.1.2"
    $LogFolder = "C:\myLogs"
    $LogFile = "$LogFolder\logs.txt"

    try {

        # Create log folder if needed
        if (!(Test-Path $LogFolder)) {

            New-Item `
                -Path $LogFolder `
                -ItemType Directory `
                -Force | Out-Null
        }

        # Create log file if needed
        if (!(Test-Path $LogFile)) {

            New-Item `
                -Path $LogFile `
                -ItemType File `
                -Force | Out-Null
        }

        # Verify Server1 is reachable
        if (-not (Test-Connection `
                    -ComputerName $DomainController `
                    -Count 2 `
                    -Quiet)) {

            throw "Cannot contact Domain Controller ($DomainController)"
        }

        # Prompt for Domain Administrator credentials
        $Credential = Get-Credential `
            -Message "Enter Domain Administrator credentials"

        # Join the domain
        Add-Computer `
            -DomainName $DomainName `
            -Credential $Credential `
            -Force `
            -ErrorAction Stop

        $Message = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - W11Client1 joined domain $DomainName"

        # Record that the computer is about to restart.
        Add-Content `
            -Path $LogFile `
            -Value $Message

        # Display status messages to the user.
        Write-Host $Message
        Write-Host "Restarting computer in 10 seconds..."

        Start-Sleep -Seconds 10

        # Restart the computer to complete
        # the domain join process.
        Restart-Computer -Force
    }
    catch {

        # Record any errors encountered during execution.
        $Message = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - FAILED to join domain $DomainName : $($_.Exception.Message)"

        Add-Content `
            -Path $LogFile `
            -Value $Message

        # Display the error message.
        Write-Error $_.Exception.Message
    }
}

Join-VRMicksAndMacksDomain