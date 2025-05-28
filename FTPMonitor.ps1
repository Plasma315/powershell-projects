Start-Transcript -Path "C:\Galaxy PF Dynamic Pricing\Monitoring\output.log"
Write-Host "Hello World!!!!!"
Write-Host "Script Author: Jason Mahaney"
Write-Host "Last Edited: 2025-05-07"

try {
    # Prepare base email variables
    Write-Host "Preparing Email variables..."
    $smtp = New-Object System.Net.Mail.SmtpClient("answersingenesis-org.mail.protection.outlook.com", 25)
    $mail = New-Object System.Net.Mail.MailMessage
    $mail.From = "asyncritus.server@answersingenesis.org"
    $mail.To.Add("jmahaney@answersingenesis.org")

    # Attempt to Map Network Share from PET-GALAXYDB-01
    # This is where the FTP files are deposited
    Write-Host "Mapping Network Share: \\pet-galaxydb-01\DP_Dynamic_Digonex_Import"
    try {
        New-PSDrive -Name "Z" -PSProvider FileSystem -Root "\\pet-galaxydb-01\DP_Dynamic_Digonex_Import"
        Write-Host "Drive mapped successfully."
    } catch {
        Write-Error "Failed to map drive: $_"
        $mail.Subject = "FAIL - Asyncritus - FTPMonitor: Failed to Map Network Drive"
        $mail.Body = "Failed to map drive: $_"
        $smtp.Send($mail)
        Exit 1
    }

    # Moving script execution to Mapped Drive
    Write-Host "Moving script execution to Mapped Drive..."
    Set-Location "Z:"
    $todaysDate = Get-Date -Format "yyyyMMdd"

    # Checking for file for today's date
    Write-Host "Testing for file at path: Z:\DGX_Import_$($todaysDate).csv"
    if (-not (Test-Path -Path "Z:\DGX_Import_$($todaysDate).csv"))
    {
        $mail.Subject = "FAIL - Asyncritus - FTPMonitor: Failed to Get Today's File"
        $mail.Body = "FTP File not found. Check if FTP tool ran this morning."
        $smtp.Send($mail)
        Exit 1
    }

    # Gathering File details since file seems to exist
    Write-Host "Gathering  File details since it seems to exist..."
    $file = Get-Item -Path "Z:\DGX_Import_$($todaysDate).csv"
    $size = $file.Length
    [string] $ftpResult = ""
    
    # Checking File details to see what response we will give
    Write-Host "Determining current state..."
    if ($size -gt 0) {
        $ftpResult = "Success! Prices pulled by FTP Util"
        $mail.Subject = "Success"
    }
    elseif ($size -eq 0)
    {
        $ftpResult = "Partial Success: FTP ran but got empty Pricing from Digonex"
        $mail.Subject = "Partial Success"
    }
    else {
        $ftpResult = "Weird, file size not as expected: $size"
        $mail.Subject = "Failure: Weird File Size"
    }

    # Sending Status email
    Write-Host "Sending Status update email..."
    $mail.Body = "$ftpResult"
    $smtp.Send($mail)

    # Moving off of Z: drive so we can run Remove-PSDrive on it
    Write-Host "Closing Z: drive connection..."
    Set-Location "C:"
    Remove-PSDrive -Name "Z" -PSProvider FileSystem
}

finally {
    # Final clean up steps
    Write-Host "Ending transcript..."
    Stop-Transcript
    Exit 0
}

# Catch All in case something weird happens...
Write-Host "Hmm... you shouldn't see this... hypothetically"
Write-Host "Consider having the script reviewed by the original author"
Write-Host "Nothing should be impacted because of this..."
Write-Host "Ending transcript..."
Stop-Transcript
Exit 0