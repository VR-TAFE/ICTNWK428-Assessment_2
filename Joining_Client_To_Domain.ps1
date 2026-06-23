# Function: Join-MicksAndMacksDomainAuto
# Purpose:
# Automatically joins the local computer to the
# VRmicksandmacks.local Active Directory domain
# using predefined administrator credentials.
function Join-MicksAndMacksDomainAuto {

    # Store the Domain Administrator username.
    # This account has permission to join computers
    # to the Active Directory domain.
    $Username = "VRmicksandmacks\Administrator"

    # Store the Domain Administrator password.
    # NOTE: Hard-coded passwords should only be used
    # in lab or assessment environments.
    $Password = "Password1"

    # Convert the plain-text password into a SecureString.
    # PowerShell requires credentials to use SecureString
    # passwords instead of plain-text passwords.
    $SecurePassword = ConvertTo-SecureString `
        $Password `              # Password to convert
        -AsPlainText `           # Indicates the password is plain text
        -Force                   # Allows conversion from plain text

    # Create a PowerShell credential object containing
    # the username and encrypted password.
    # This object will be used to authenticate
    # against the Domain Controller.
    $Credential = New-Object `
        System.Management.Automation.PSCredential `
        ($Username, $SecurePassword)

    # Join the local computer to the specified
    # Active Directory domain.
    Add-Computer `
        -DomainName "VRmicksandmacks.local" `   # Domain to join
        -Credential $Credential `               # Domain Administrator credentials
        -Force                                  # Skip confirmation prompts

    # Restart the computer to complete the domain join process.
    # A reboot is required before the computer becomes
    # an active member of the domain.
    Restart-Computer -Force
}