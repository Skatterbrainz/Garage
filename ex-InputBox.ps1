
$VBScript = New-Object  MSScriptControl.ScriptControl
$VBScript.language = "vbscript"
$VBScript.addcode("function getInput() getInput = inputbox(`"Guy Says Hello`",`"Guy's box`") End Function" )
$Input = $VBScript.eval("getInput")