function Get-ScriptPath {
	Split-Path -Parent $MyInvocation.MyCommand.Definition
}
