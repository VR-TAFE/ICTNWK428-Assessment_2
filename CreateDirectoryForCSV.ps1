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