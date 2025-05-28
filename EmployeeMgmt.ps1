#region Examples
<#
# Imports the CSV as a variable sorted by FirstName
$csv = Import-Csv -Path '.\5.12.25 CM Hiring Day Activation.csv' -Delimiter ',' | Sort-Object -Property "FirstName"

# Gets the first user
$csv | Select-Object -First 1

# Cycle through ALL new employees
#   and get First and Last names
$csv | ForEach-Object {
    Write-Output "$($_.FirstName) $($_.LastName)"
}

# Cycle through ALL new employees
#   and get First and Last names
#   Sorted by First Name
$csv | Sort-Object -Property "FirstName" | ForEach-Object {
    Write-Output "$($_.FirstName) $($_.LastName)"
}

# Connect to AD and pull a User
$filter = "(&(objectClass=user)(sAMAccountName=joshuam))"
$domain = New-Object System.DirectoryServices.DirectoryEntry
$searcher = New-Object System.DirectoryServices.DirectorySearcher($domain)
$searcher.Filter = $filter
$result = $searcher.FindOne()

$user = $result.Properties
$user["displayname"]
$user["mail"]
#>
#endregion

function New-LocalADUser {
    [CmdletBinding(
        ConfirmImpact = 'Medium'
        #SupportsShouldProcess = $true
    )]

    param(
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = "The USERNAME this user will use to sign in"
            )]
        [Alias("login,account,userID,user")]
        [String] $UserName,
        
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = "What kind of employee is this?",
            ParameterSetName = "Employee Classification"
        )]
        [ValidateSet("Seasonal", "Temporary", "Part Time", "Full Time")]
        [String] $Classification,

        [Alias("OU")]
        [String] $OrganizationalUnit

        [String] $FirstName
        [String] $LastName
        [String] $NickName
        [ValidateSet("AIG", "CWC", "PF")]
        [String] $Company
        [String] $Department
        [String] $Manager
        [Switch] $EnableImmediately
    )
    begin {

    }
    process {
        $tempOU = $organizationalUnitTranslation[$($WorkSite)];
        $OrganizationalUnit = "LDAP://$($tempOU),OU=Seasonal_Accounts,OU=AiG_Users,DC=aigdomain,DC=local"
        $directory = New-Object System.DirectoryServices.DirectoryEntry($OrganizationalUnit)

        # Create the User Object
        $newUser = $directory.Children.Add("CN=JSM - $($FirstName) $($LastName)", "user")
        
        # Translate Email Domain from Company Employing
        $emailDomain = $emailTranslation[$($WorkSite)];
        $tempUPN = "$($UserName)@$($emailDomain)"
        $newUser.Properties["mail"].Value = "$($tempUPN)"
        $newUser.Properties["mailNickname"].Value = "$($UserName)"

        # Set User Object properties
        $newUser.Properties["sAMAccountName"].Value = "$($UserName)"
        $newUser.Properties["userPrincipalName"].Value = "$($UserName)@$($emailDomain)"
        $newUser.Properties["givenName"].Value = "$($FirstName)"
        $newUser.Properties["sn"].Value = "$($LastName)"

        $newUser.Properties["title"].Value = "Truth Traveler TN - $($Classification)"
        $newUser.Properties["description"].Value = "Truth Traveler TN - $($Classification)"
        $newUser.Properties["company"].Value = "$($Company)"
        $newUser.Properties["department"].Value = "$($Department)"
        
        $filter = "(&(objectClass=user)(CN=$($Manager)))"
        $domain = New-Object System.DirectoryServices.DirectoryEntry
        $searcher = New-Object System.DirectoryServices.DirectorySearcher($domain)
        $searcher.Filter = $filter
        $result = $searcher.FindOne()

        $mgr = $result.Properties
        
        "CN=Roger Mantel,OU=FullTime_PartTime_Accounts,OU=AiG_Users,DC=aigdomain,DC=local"

        $newUser.Properties["manager"].Value = "$($mgr["distinguishedName"])"

        # If we have a Nickname, we will use that for the Display Name
        # Otherwise, we will use their Legal First Name
        if($($NickName) -ne ""){
            $newUser.Properties["displayName"].Value = "$($NickName) $($LastName)"
        } else {
            $newUser.Properties["displayName"].Value = "$($FirstName) $($LastName)"
        }    
        
        if($EnableImmediately){
            #$newUser.CommitChanges()
            # Enable the account (userAccountControl: 512 = NORMAL_ACCOUNT)
            $newUser.Properties["userAccountControl"].Value = 512
        }
        
        # Commit the user creation
        $newUser.CommitChanges()
        Write-Output "User $($userName) created successfully."
        Write-Output "Email: $($tempUPN)"
    }
    finally {
        # Clean up
        $newUser.Dispose()
        $directory.Dispose()
    }
}

$emailTranslation = @{
    "AIG" = "answersingenesis.org";
    "CWC" = "arkencounter.com";
    "PF" = "pftt.aigus.org";
    "CM" = "creationmuseum.org";
    "AE" = "arkencounter.com"
}

$organizationalUnitTranslation = @{
    "AIG" = "OU=Seasonal_PigeonForge"; #"OU=Seasonal_AiG";
    "CWC" = "OU=Seasonal_Ark";
    "PF" = "OU=Seasonal_PigeonForge";
    "CM" = "OU=Seasonal_PigeonForge"; #"OU=Seasonal_Museum";
    "AE" = "OU=Seasonal_Ark"
}

$csv = Import-Csv -Path '.\Downloads\5.12.25 CM Hiring Day Activation.csv' -Delimiter ',' | Sort-Object -Property "FirstName"