!TCL=15, 
!TITLE=PowerShell 5
!SORT=Y
!CHARSET=ANSI

!TEXT=Cmdlet - Advanced Function
<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
#>
function Verb-Noun {
    [CmdletBinding()]
    [Alias()]
    [OutputType([int])]
    Param (
        # Param1 help description
        [Parameter(Mandatory=$true,
        		   HelpMessage="",
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)] $Param1,

        # Param2 help description
        [int]
        $Param2
    )

    Begin {
    	#
    }
    Process {
    	#
    }
    End {
    	#
    }
}

!
!TEXT=Cmdlet - Advanced Function (Complete)
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
function Verb-Noun {
    [CmdletBinding(DefaultParameterSetName='Parameter Set 1',
                  SupportsShouldProcess=$true,
                  PositionalBinding=$false,
                  HelpUri = 'http://www.microsoft.com/',
                  ConfirmImpact='Medium')]
    [Alias()]
    [OutputType([String])]
    Param (
        # Param1 help description
        [Parameter(Mandatory=$true,
        		   HelpMessage="",
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true,
                   ValueFromRemainingArguments=$false,
                   Position=0,
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
        [int]
        $Param2,

        # Param3 help description
        [Parameter(ParameterSetName='Another Parameter Set')]
        [ValidatePattern("[a-z]*")]
        [ValidateLength(0,15)]
        [String]
        $Param3
    )

    Begin {
    	#
    }

    Process {
        if ($pscmdlet.ShouldProcess("Target", "Operation")) {
        	#
        }
    }

    End {
    	#
    }
}
!
!TEXT=Document - Heading 1
<#
.SYNOPSIS
	Brief description

.DESCRIPTION
	Detailed description

.PARAMETER name
	[required] [string] Description...

.NOTES
	Version...........:
	Author............:
	Date Created......:
	Date Modified.....:

.EXAMPLE

#>

!
!TEXT=Document - Heading 2 - w/Requires
#requires -version 3
#requires -RunAsAdministrator
#requires -module ActiveDirectory

<#
.SYNOPSIS
	Brief description

.DESCRIPTION
	Detailed description

.PARAMETER name
	[required] [string] Description...

.NOTES
	Version...........:
	Author............:
	Date Created......:
	Date Modified.....:

.EXAMPLE

#>

!
!TEXT=Function - Basic
function MyFunction ($param1, $param2) {

}
!
!TEXT=Iteration - Do Until
do {

}
until ($x -gt 0)

!
!TEXT=Iteration - Do While
do {

}
while ($x -gt 0)

!
!TEXT=Iteration - For
for ($i = 1; $i -lt 99; $i++) {

}

!
!TEXT=Iteration - Foreach
foreach ($item in $collection) {

}

!
!TEXT=Iteration - While
while ($x -gt 0) {

}

!
!TEXT=Logic - If / Else
if ($Variable1 -eq "ABC") {
	# do something
}
else {
	# if nothing else is valid - do this
}

!
!TEXT=Logic - If / ElseIf / Else
if (!($Variable1)) {
	# do something
}
elseif ($Variable1 -eq "ABC") {
	# do something
}
elseif ($Variable1 -gt 1) {
	# do something
}
else {
	# if nothing else is valid - do this
}

!
!TEXT=Sample - Custom Object
$os = Get-CimInstance -ClassName Win32_OperatingSystem
$cs = Get-CimInstance -ClassName Win32_ComputerSystem

$properties = @{
	ComputerName = $env:COMPUTERNAME;
	SPVersion = $os.ServicePackMajorVersion;
	OSVersion = $os.Version;
	Model = $cs.Model;
	Mfgr  = $cs.Manufacturer
}

$obj = New-Object -TypeName PSObject -Property $properties
Write-Output $obj

!
!TEXT=Sample - Parameter Set 1
[CmdletBinding()]
param (
	[parameter(
		Mandatory=$True,
		ValueFromPipeline=$True,
		ValueFromPipelineByPropertyName=$True,
		HelpMessage="This is variable 1"
	)]
	[Alias('V1','var1')]
	[ValidateNotNullOrEmpty()]
	[ValidateSet('A','B','C')]
	[string] $Variable1
)

!
!TEXT=Switch
switch ($x) {
    'value1' {
        break;
    }
    'value2' {
        break;
    }
    {$_ -in 'A','B','C'} {
        break;
    }
    Default {
        break;
    }
}
!
!TEXT=Try Catch Finally
try {
    1/0
}
catch [DivideByZeroException] {
    Write-Host "Divide by zero exception"
}
catch [System.Net.WebException],[System.Exception] {
    Write-Host "Other exception"
}
finally {
    Write-Host "cleaning up ..."
}

!
!TEXT=Try Finally
try {

}
finally {

}

!
