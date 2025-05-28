<#
.SYNOPSIS
  This script attempts to make Galaxy upgrade processes more consistent and efficient.

.DESCRIPTION
  Functionality allows upgrading the Galaxy WebStores that are hosted on-prem. 
  Currently supported are Ark Encounter, Creation Museum, and Pigeon Forge WebStores.
  Additional stores could be added fairly reasonably however.

.PARAMETER VersionNumber
  Galaxy Version Number as prescribed by Galaxy.
  Example set: 
  Galaxy version 8.0.0.0: 08000000
  Galaxy version 7.8.15.7: 07081507

.PARAMETER SandboxEnv
  This switch tells the script that we want to modify the Sandbox Galaxy Environment and not the Production or Test Environments
  NOTE!!: Sandbox is the equivalent of OLD Test Galaxy. New naming scheme below

  OLD Name      NEW Name        OLD Environment     NEW Environment
  ---------     ---------       ---------------     ---------------
  PROD          PRD             Production          Production
  STG           TST             Staging             Testing
  TST           DEV             Testing             Development

.EXAMPLE
   # Load Config.xml file from Path (NOT IMPLEMENTED YET)
   Get-Config -Path "C:\Users\Public\Desktop\config.xml"
#>

#region Upgrade Preparation
[function Reload-Module {
    #Remove-Module GalaxyWebStoreUpgrade; Import-Module GalaxyWebStoreUpgrade
    #$modPath = $env:PSModulePath -Split ";"
    #$modPath[0]
}]
[function Get-Config {
    $config = ([xml](Get-Content ".\config.xml")).root
}]
[function Set-BackupFolder {
    [CmdletBinding()]
    param(
        [string] $Path,
        [Switch] $SandboxEnv
    )
    # Confirm Old exists and Create if Not
    if (-not (Test-Path -Path (Join-Path $Path "Old"))) 
    {
        Write-Verbose "'Old' directory doesn't exist..."
        Write-Verbose "Creating 'Old' directory..."
        New-Item -ItemType Directory -Path "." -Name "Old"
    }
    else # Clean existing OLD Folder
    {
        Write-Verbose "'Old' directory found..."
        Write-Verbose "Sandbox mode: $SandboxEnv"
        if ($SandboxEnv) 
        {
            Write-Verbose "Removing all DEV Environment- files from the 'Old' directory"
            Get-ChildItem -Path ".\Old" -Filter "*sandbox*" | Remove-Item -Recurse -Force
        <#
        # If Script runs properly... delete this section
            if (Test-Path -Path ".\Old\sandbox.eGalaxy") {
                Remove-Item -Path ".\Old\sandbox.eGalaxy" -Recurse -Force
            }
            if (Test-Path -Path ".\Old\sandbox.WebAdmin") {
                Remove-Item -Path ".\Old\sandbox.WebAdmin" -Recurse -Force
            }
            if (Test-Path -Path ".\Old\sandbox.WebStore") {
                Remove-Item -Path ".\Old\sandbox.WebStore" -Recurse -Force
            }
        #>
        }
        else
        {
            Write-Verbose "Removing all Test Environment folders from the 'Old' directory"
            Get-ChildItem -Path ".\Old" -Exclude "*sandbox*" | Remove-Item -Recurse -Force
        <#
        # If Script runs properly... delete this section
            if (Test-Path -Path ".\Old\eGalaxy") {
                Remove-Item -Path ".\Old\eGalaxy" -Recurse -Force
            }
            if (Test-Path -Path ".\Old\WebAdmin") {
                Remove-Item -Path ".\Old\WebAdmin" -Recurse -Force
            }
            if (Test-Path -Path ".\Old\WebStore") {
                Remove-Item -Path ".\Old\WebStore" -Recurse -Force
            }
        #>
        }
    }
}]
[function Move-OriginalToBackupFolder {
    [CmdletBinding()]
    param(
        [Switch] $SandboxEnv
    )
    if ($SandboxEnv) 
    {
        #Get-ChildItem -Path "." -Filter "*sandbox*" | Move-Item -Recurse -Force
        Move-Item -Path ".\sandbox.eGalaxy" -Destination ".\Old"
        Move-Item -Path ".\sandbox.WebAdmin" -Destination ".\Old"
        Move-Item -Path ".\sandbox.WebStore" -Destination ".\Old"
    }
    else
    {
        #Get-ChildItem -Path "." -Exclude "*sandbox*" | Move-Item -Recurse -Force
        Move-Item -Path ".\eGalaxy" -Destination ".\Old"
        Move-Item -Path ".\WebAdmin" -Destination ".\Old"
        Move-Item -Path ".\WebStore" -Destination ".\Old"
    }
}]
[function New-GalaxyInstallFolder {
    [CmdletBinding()]
    param(
        [Switch] $SandboxEnv
    )
    if ($SandboxEnv) 
    {
        # Make a String[] and cycle through them
        New-Item -ItemType Directory -Path "." -Name "sandbox.eGalaxy"
        New-Item -ItemType Directory -Path "." -Name "sandbox.WebAdmin"
        New-Item -ItemType Directory -Path "." -Name "sandbox.WebStore"
    }
    else
    {
        New-Item -ItemType Directory -Path "." -Name "eGalaxy"
        New-Item -ItemType Directory -Path "." -Name "WebAdmin"
        New-Item -ItemType Directory -Path "." -Name "WebStore"
    }
}]
#endregion

#region Upgrade Installation
[function Copy-GalaxyExecutable {
    [CmdletBinding()]
    param(
        [Switch] $SandboxEnv
    )
    $eGalaxyExe = Join-Path $config.SourceFolder "Gateway.eGalaxy.exe"
    $WebAdminExe = Join-Path $config.SourceFolder "Gateway.WebAdmin.exe"
    $WebStoreExe = Join-Path $config.SourceFolder "Gateway.WebStore.exe"

    if ($SandboxEnv) {
        Copy-Item -Path $eGalaxyExe -Destination ".\sandbox.eGalaxy\Gateway.eGalaxy.exe"
        Copy-Item -Path $WebAdminExe -Destination ".\sandbox.WebAdmin\Gateway.WebAdmin.exe"
        Copy-Item -Path $WebStoreExe -Destination ".\sandbox.WebStore\Gateway.WebStore.exe"
    }
    else {
        Copy-Item -Path $eGalaxyExe -Destination ".\eGalaxy\Gateway.eGalaxy.exe"
        Copy-Item -Path $WebAdminExe -Destination ".\WebAdmin\Gateway.WebAdmin.exe"
        Copy-Item -Path $WebStoreExe -Destination ".\WebStore\Gateway.WebStore.exe"
    }
}]
[function Invoke-GalaxyExecutable {
    [CmdletBinding()]
    param(
        [Switch] $SandboxEnv
    )
    if ($SandboxEnv) 
    {
        Start-Process ".\sandbox.eGalaxy\Gateway.eGalaxy.exe"
        Start-Process ".\sandbox.WebAdmin\Gateway.WebAdmin.exe"
        Start-Process ".\sandbox.WebStore\Gateway.WebStore.exe"
    }
    else {
        Start-Process ".\eGalaxy\Gateway.eGalaxy.exe"
        Start-Process ".\WebAdmin\Gateway.WebAdmin.exe"
        Start-Process ".\WebStore\Gateway.WebStore.exe"
    }
}]
[function Move-eGalaxyConfig {
    [CmdletBinding()]
    param(
        [Switch] $SandboxEnv
    )
    if ($SandboxEnv) 
    {
        Copy-Item -Path ".\Old\sandbox.eGalaxy\config\connectionStrings.config" -Destination ".\sandbox.eGalaxy\config\connectionStrings.config"
        Copy-Item -Path ".\Old\sandbox.eGalaxy\config\globalization.config" -Destination ".\sandbox.eGalaxy\config\globalization.config"
    }
    else {
        Copy-Item -Path ".\Old\eGalaxy\config\connectionStrings.config" -Destination ".\eGalaxy\config\connectionStrings.config"
        Copy-Item -Path ".\Old\eGalaxy\config\globalization.config" -Destination ".\eGalaxy\config\globalization.config"
    }
}]
[function Move-WebAdminConfig {
    [CmdletBinding()]
    param(
        [Switch] $SandboxEnv
    )
    if ($SandboxEnv) 
    {
        Copy-Item -Path ".\Old\sandbox.WebAdmin\config\connectionStrings.config" -Destination ".\sandbox.WebAdmin\config\connectionStrings.config"
        if (Test-Path -Path ".\Old\sandbox.WebAdmin\config\customerAppSettingsOverride.config") {
            Copy-Item -Path ".\Old\sandbox.WebAdmin\config\customerAppSettingsOverride.config" -Destination ".\sandbox.WebAdmin\config\customerAppSettingsOverride.config"
        }
    }
    else {
        Copy-Item -Path ".\Old\WebAdmin\config\connectionStrings.config" -Destination ".\WebAdmin\config\connectionStrings.config"
        if (Test-Path -Path ".\Old\WebAdmin\config\customerAppSettingsOverride.config") {
            Copy-Item -Path ".\Old\WebAdmin\config\customerAppSettingsOverride.config" -Destination ".\WebAdmin\config\customerAppSettingsOverride.config"
        }
    }
}]
[function Move-WebStoreConfig {
    [CmdletBinding()]
    param(
        [Switch] $SandboxEnv
    )
    if ($SandboxEnv) 
    {
        Copy-Item -Path ".\Old\sandbox.WebStore\config\connectionStrings.config" -Destination ".\sandbox.WebStore\config\connectionStrings.config"
        Copy-Item -Path ".\Old\sandbox.WebStore\config\globalization.config" -Destination ".\sandbox.WebStore\config\globalization.config"

        Copy-Item -Path $themePath -Destination ".\sandbox.WebStore\FrontEnd" -Recurse
        Copy-Item -Path $appleWalletPath -Destination ".\sandbox.WebStore\AppleWalletCert" -Recurse
        if (Test-Path -Path ".\Old\sandbox.WebStore\config\customerAppSettingsOverride.config") {
            Copy-Item -Path ".\Old\sandbox.WebStore\config\customerAppSettingsOverride.config" -Destination ".\sandbox.WebStore\config\customerAppSettingsOverride.config"
        }
        else {
            # GET LICENSE KEY
            #$licenseKey = Get-Content -Path ".\Old\sandbox.WebStore\config\appSettings.config"
        }
    }
    else {
        Copy-Item -Path ".\Old\WebStore\config\connectionStrings.config" -Destination ".\WebStore\config\connectionStrings.config"
        Copy-Item -Path ".\Old\WebStore\config\globalization.config" -Destination ".\WebStore\config\globalization.config"

        Copy-Item -Path $themePath -Destination ".\WebStore\FrontEnd" -Recurse
        Copy-Item -Path $appleWalletPath -Destination ".\WebStore\AppleWalletCert" -Recurse
        if (Test-Path -Path ".\Old\WebStore\config\customerAppSettingsOverride.config") {
            Copy-Item -Path ".\Old\WebStore\config\customerAppSettingsOverride.config" -Destination ".\WebStore\config\customerAppSettingsOverride.config"
        }
        else {
            # GET LICENSE KEY
            #$licenseKey = Get-Content -Path ".\Old\WebStore\config\appSettings.config"
        }
    }
}]
#endregion
#region Upgrade Clean Up
[function Start-GalaxyAppPool {
    [CmdletBinding(
        SupportsShouldProcess=$true,
        ConfirmImpact = 'Low'
    )]
    Get-Config
    foreach ($appPool in $config.appPools.ChildNodes) {
        Write-Host "`nLocation: $($appPool.Name)"
        foreach ($child in $appPool.ChildNodes) {
            Write-Output "   Starting $($child.InnerText)"
            Start-WebAppPool $child.InnerText
        }
    }
}]
[function Stop-GalaxyAppPool {
    [CmdletBinding(
        SupportsShouldProcess=$true,
        #[ValidateSet("sun", "moon", "earth")],
        ConfirmImpact = 'Medium'
    )]
    
    Get-Config
    Write-Host "Stopping these AppPools..."
    foreach ($appPool in $config.appPools.ChildNodes) {
        Write-Host "`nLocation: $($appPool.name)"
        foreach ($child in $appPool.ChildNodes) {
            Write-Output "   $($child.InnerText)"
        }
    }
    if ($pscmdlet.ShouldProcess("Testing", "Stop All Galaxy Web AppPools")){
        foreach ($appPool in $config.appPools.ChildNodes) {
            Write-Host "`nLocation: $($appPool.Name)"
            foreach ($child in $appPool.ChildNodes) {
                Write-Output "   Stopping $($child.InnerText)"
                Stop-WebAppPool $child.InnerText
            }
        }
    }
}]
#endregion

#region Function Export
Export-ModuleMember -Function Copy-GalaxyExecutable
Export-ModuleMember -Function Get-Config
Export-ModuleMember -Function Invoke-GalaxyExecutable
Export-ModuleMember -Function Set-BackupFolder
Export-ModuleMember -Function Start-GalaxyAppPool
Export-ModuleMember -Function Stop-GalaxyAppPool
Export-ModuleMember -Function Move-eGalaxyConfig
Export-ModuleMember -Function Move-OriginalToBackupFolder
Export-ModuleMember -Function Move-WebAdminConfig
Export-ModuleMember -Function Move-WebStoreConfig
Export-ModuleMember -Function New-GalaxyInstallFolder
#endregion

#$WhatIfPreference = 'Low'
#$ConfirmPreference = 'Low'