function Get-FolderSize {
	param (
		[parameter(Mandatory=$True, HelpMessage="Path and name of folder")]
		[ValidateNotNullOrEmpty()]
		[string] $FolderPath
	)
	$colItems = (Get-ChildItem "$FolderPath" -Recurse | Measure-Object -Property length -sum)
	"{0:N2}" -f ($colItems.sum/1GB) + " GB"
}
