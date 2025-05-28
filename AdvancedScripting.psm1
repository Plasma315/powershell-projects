<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
.INPUTS
   Inputs to this cmdlet (if any)
.OUTPUTS
   Output from this cmdlet (if any)
.NOTES
   General notes
.COMPONENT
   The component this cmdlet belongs to
.ROLE
   The role this cmdlet belongs to
.FUNCTIONALITY
   The functionality that best describes this cmdlet
#>

# https://learn.microsoft.com/en-us/powershell/scripting/developer/cmdlet/approved-verbs-for-windows-powershell-commands?view=powershell-7.5

function Verb-Noun
{
    [CmdletBinding(DefaultParameterSetName='Parameter Set 1', 
                  SupportsShouldProcess=$true, 
                  PositionalBinding=$false,
                  HelpUri = 'http://www.microsoft.com/',
                  ConfirmImpact='Medium')]
    [Alias()]
    [OutputType([String])]
    Param
    (
        # Param1 help description that shows in Get-Help
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=0,
                   HelpMessage = 'Fill this parameter, please',
                   ParameterSetName='Parameter Set 1')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [ValidateCount(0,5)]
        [ValidateSet("sun", "moon", "earth")]
        [Alias("p1")] 
        $Param1,

        # Param2 help description
        [Parameter(ParameterSetName='Parameter Set 1')]
        [AllowNull()]
        [AllowEmptyCollection()]
        [AllowEmptyString()]
        [ValidateScript({$true})]
        [ValidateRange(0,5)]
        #[Parameter(Mandatory = $true)]
        #[ValidateScript({ Test-Path $_ })]
        [int]
        $Param2,

        # Param3 help description
        [Parameter(ParameterSetName='Another Parameter Set')]
        [ValidatePattern("[a-z]*")]
        [ValidateLength(0,15)]
        [String]
        $Param3,
        
        # Param4 help description
        [Parameter(ParameterSetName='Another Parameter Set 1')]
        [ValidatePattern("\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b")]
        [ValidateLength(0,15)]
        [String]
        $IPAddress
    )

    Begin
    {
        $ConfirmPreference = 'Low'
    }
    Process
    {
        if ($pscmdlet.ShouldProcess("Target", "Operation"))
        {
            Write-Verbose "$($pscmdlet.ShouldProcess)"
        }
        else
        {
            # Get-Content -Path "Bad Path" -ErrorAction SilentlyContinue -ErrorVariable MyError
            # $MyError | Out-File
            # Get-Content -Path "Bad Path" -ErrorAction Stop -ErrorVariable MyError
            # Get-Content -Path "Bad Path" -ErrorAction Inquire -ErrorVariable MyError
            <#
            $Prop = [Ordered] @{
                'Name' = "Name"
                'Item' = "Item"
            }
            Write-Output $Prop


            $obj = New-Object -TypeName PSObject -Property $Prop
            Write-Output $obj

            $myObj = New-Object -TypeName [PSCustomObject]@{
                Name = JasonObject
            }
            Write-Output $myObj
            $myObj | ConvertToJson
            $myObj | Clip
            #>
        }
    }
    End
    {
    }
}

<#
    [function Verb-Noun {
        [CmdletBinding()]
        param (
            [String] $versionNumber = '',
            [Switch] $ErrorLog,
            [String] $LogFile = 'E:\errorLog.txt' 
            [Parameter(ValueFromPipeline = $true, Mandatory = $true)]
            [int[]] $x
        )
        begin { 
            $total = 0
            # Connect to DB
            if ($ErrorLog) {
                # Need to run with -Verbose to see Verbose logging
                Write-Verbose 'Error logging turned on'
            } Else {
                Write-Verbose 'Error logging turned off'
            }
        }
        process { 
            $total += $x
            # Run SQL Queries

            # Invoke-Command will automatically run con-currently
            Invoke-Command -ComputerName (Get-Content Servers.txt) {}
            #foreach ($s in (Get-Content Servers.txt)) { Invoke-Command -ComputerName $s }
        }
        end { 
            "End Total: $total"
            # Close Connection to DB
        }
    }]
#>
