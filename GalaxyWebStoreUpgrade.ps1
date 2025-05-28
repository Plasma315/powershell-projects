$preTranscript = Set-Location "$PSScriptRoot" -Verbose
Start-Transcript -Path ".\transcript.log" -Force
Write-Verbose $preTranscript

Add-Type -AssemblyName System.Windows.Forms
Import-Module -Path ".\GalaxyWebStoreUpgrade.psm1" -Force
#Invoke-Command ". .\GalaxyWebStoreUpgrade.psm1"

[String] $ConfigPath = ".\config.xml"
Write-Verbose "Loading configuration from: $ConfigPath"
$config = ([xml](Get-Content "$ConfigPath")).root

[Switch] $test_env = $($config.SandboxMode)
#[Switch] $SandboxEnv:$configSettings.SandboxMode
[String] $themePath = ".\Themes\"
[String] $appleWalletPath = ".\AppleWalletCert\"
[String] $version = $($Config.versionNumber)
if ($version -eq "") {
    $version = "07081511"
}


$settings = [PSCustomObject]@{
    EnableLogging = $true  # This mimics a switch
    SandboxMode = $true
}
$settings | ConvertTo-Json | Out-File -FilePath ".\config.json" -Encoding UTF8

$configSettings = Get-Content ".\config.json" | ConvertFrom-Json

if ($configSettings.EnableLogging) {
    Write-Host "Logging is enabled"
} else {
    Write-Host "Logging is disabled"
}
if ($configSettings.SandboxMode) {
    Write-Host "Sandbox Mode is enabled"
} else {
    Write-Host "Sandbox Mode is disabled"
}








if ($test_env -eq $true) 
{
    $directoryPath = Join-Path $config.InstallPaths.WebStore.ArkEncounter "sandbox.eGalaxy"
    if (-not (Test-Path -Path $directoryPath)) 
    {
        Write-Host "Configuration is set to Test, but no test folders were found:"
        Write-Host "$directoryPath"
        Pause
        exit 1
    }
}
if (-not (Test-Path -Path $themePath)) 
{
    Write-Host "Couldn't Find Themes Folder"
    Pause
    exit 1
}
if (-not (Test-Path -Path $appleWalletPath)) 
{
    Write-Host "Couldn't Find AppleWalletCert Folder"
    Pause
    exit 1
}

#endregion
#region Check DB Status
$databaseBackedUp = [System.Windows.Forms.MessageBox]::Show(
    "Have you taken a Database Backup?",
    "Confirmation",
    [System.Windows.Forms.MessageBoxButtons]::YesNo,
    [System.Windows.Forms.MessageBoxIcon]::Question
)

if ($databaseBackedUp -ne [System.Windows.Forms.DialogResult]::Yes) {
    $null = Write-Output "WARNING: No Database Backup performed"
    Write-Host "A Database Backup is highly recommended before performing a Galaxy upgrade"
    $response = Read-Host "Do you want to continue? (y/n)"

    if (-not ($response -match '(?i)^y(es)?$')) {
        Write-Verbose "User canceled operation... or intent unclear"
        Write-Verbose "Ending script runtime..."
        Write-Verbose "User canceled."
        exit 100
    }
    <#elseif ($response -match '(?i)^n(o)?$') {
        Write-Output "User canceled."
    }#>
    else {
        Write-Verbose "WARNING: User BYPASSED backup check"
        
        continue
        #exit 100
    }
}

<#

Do-Stuff -SandboxEnv:$configSettings.SandboxMode


$config = [PSCustomObject]@{
    FirstName = "Jason"
    LastName = "Smith"
    Age = 35
    Active = $true
}

$config | ConvertTo-Json | Out-File -FilePath ".\config.json" -Encoding utf8
#>


#endregion
<# 
#region Fang

Stop-GalaxyAppPool

foreach ($location in $config.InstallPaths.WebStore.ChildNodes) {
    Write-Host "`nLocation: $($location.Name)"
    Pause
    foreach ($child in $location.ChildNodes) {
        Set-Location $($child.InnerText)
        Get-Location | Write-Host
        Set-BackupFolder -SandboxEnv:$configSettings.SandboxMode
        Move-OriginalToBackupFolder -SandboxEnv:$configSettings.SandboxMode
        
        New-GalaxyInstallFolder -SandboxEnv:$configSettings.SandboxMode
        Copy-GalaxyExecutable -SandboxEnv:$configSettings.SandboxMode
        Invoke-GalaxyExecutable -SandboxEnv:$configSettings.SandboxMode

        Move-WebAdminConfig -SandboxEnv:$configSettings.SandboxMode
        Move-eGalaxyConfig -SandboxEnv:$configSettings.SandboxMode
        Move-WebStoreConfig -SandboxEnv:$configSettings.SandboxMode
    }
}

if (-not (Test-Path -Path "E:\com\$($version)")) 
{
    New-Item -ItemType Directory -Path "E:\com" -Name $($version)
}
else
{
    Set-Location -Path "E:\com\$($version)"
    Move-Item -Path .\CartTrans$($oldVersion)_Neutral.dll -Destination .\CartTrans$($oldVersion)_Neutral_OLD.dll
    Move-Item -Path .\CartTrans$($oldVersion)_Neutral.ini -Destination .\CartTrans$($oldVersion)_Neutral_OLD.ini
    Move-Item -Path .\WebPublishing$($oldVersion)_Neutral.dll -Destination .\WebPublishing$($oldVersion)_Neutral_OLD.dll
    Move-Item -Path .\WebPublishing$($oldVersion)_Neutral.ini -Destination .\WebPublishing$($oldVersion)_Neutral_OLD.ini
}

Set-Location -Path "E:\com\$($version)"
Copy-Item -Path "$sourceFolder\CartTrans$($version)_Neutral.dll" -Destination ".\CartTrans$($version)_Neutral.dll"
Copy-Item -Path "$sourceFolder\CartTrans$($version)_Neutral.ini" -Destination ".\CartTrans$($version)_Neutral.ini"
Copy-Item -Path "$sourceFolder\WebPublishing$($version)_Neutral.dll" -Destination ".\WebPublishing$($version)_Neutral.dll"
Copy-Item -Path "$sourceFolder\WebPublishing$($version)_Neutral.ini" -Destination ".\WebPublishing$($version)_Neutral.ini"

Start-GalaxyAppPool
#endregion #>