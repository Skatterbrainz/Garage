param (
  [parameter(Mandatory=$True)]
    [ValidateNotNullOrEmpty()]
    [string] $Caption,
  [parameter(Mandatory=$True)]
    [ValidateNotNullOrEmpty()]
    [string] $Message
)
try {
    $VBScript = New-Object  MSScriptControl.ScriptControl
}
catch {
    Write-Warning "unable to instantiate ScriptControl COM interface"
    break
}
$VBScript.language = "vbscript"
$VBScript.addcode("Function GetInput() getInput = inputbox(`"$Message`",`"$Caption`") End Function" )
$Input = $VBScript.eval("GetInput")
