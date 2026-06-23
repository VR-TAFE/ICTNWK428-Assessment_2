# Function: Initialize-LogFile
# Purpose: Creates the C:\MyLogs directory and logs.txt file if they do not already exist.

function Initialise-LogFile {

    # Define the folder path where log files will be stored
    $LogFolder = "C:\MyLogs"

    # Define the full path to the log file
    $LogFile = "$LogFolder\logs.txt"

    # Begin error handling block
    try {

        # Check if the log directory exists
        if (!(Test-Path $LogFolder)) {

            # Create the directory if it does not exist
            # Folder path to create
            # Specify that a directory is being created
            # Suppress output and force creation
            New-Item `
                -Path $LogFolder `
                -ItemType Directory `
                -Force | Out-Null

            # Display success message to the console
            Write-Host "Directory created: $LogFolder"
        }
        else {

            # Directory already exists, inform the user
            Write-Host "Directory already exists: $LogFolder"
        }

        # Check if the log file exists
        if (!(Test-Path $LogFile)) {

            # Create an empty log file if it does not exist
            # File path to create
            # Specify that a file is being created
            # Suppress output and force creation
            New-Item `
                -Path $LogFile `
                -ItemType File `
                -Force | Out-Null

            # Display success message to the console
            Write-Host "Log file created: $LogFile"
        }
        else {

            # Log file already exists, inform the user
            Write-Host "Log file already exists: $LogFile"
        }

        # Display completion message when all tasks are successful
        Write-Host "Initialisation completed successfully."

    }
    catch {

        # If an error occurs, display the error message
        Write-Error "Failed to create log directory or file: $($_.Exception.Message)"
    }
}