<#
.DESCRIPTION
  Example of using Dynamic Parameters in a function
.EXAMPLE
  Show-FreeSpace -Drive <tab>
#>

function Show-FreeSpace {
    [CmdletBinding()]
    Param()
    DynamicParam {
        $ParamAttrib  = New-Object System.Management.Automation.ParameterAttribute
        $ParamAttrib.Mandatory  = $true
        $ParamAttrib.ParameterSetName  = '__AllParameterSets'
        $AttribColl = New-Object  System.Collections.ObjectModel.Collection[System.Attribute]
        $AttribColl.Add($ParamAttrib)
        $configurationFileNames = Get-WmiObject -Class Win32_Volume | % {$_.driveletter} | Sort-Object
        $AttribColl.Add((New-Object  System.Management.Automation.ValidateSetAttribute($configurationFileNames)))
        $RuntimeParam  = New-Object System.Management.Automation.RuntimeDefinedParameter('Drive',  [string], $AttribColl)
        $RuntimeParamDic  = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        $RuntimeParamDic.Add('Drive',  $RuntimeParam)
        return  $RuntimeParamDic
    }
    begin{
        $drive = $PSBoundParameters.Drive
    }
    process{
        $vol = Get-WmiObject -Class Win32_Volume -Filter "driveletter='$drive'"
        "{0:N2}% free on {1}" -f ($vol.Capacity / $vol.FreeSpace),$drive
    }
}
