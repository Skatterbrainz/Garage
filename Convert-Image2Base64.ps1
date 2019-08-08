<# adapted from Paul Wetter's DocumentCMCB.ps1 script #>

function Convert-Image2Base64 {
    [CmdletBinding()]
    param (
        [parameter(
          ValueFromPipelineByPropertyName = $False,
          Mandatory = $True,
          ValueFromPipeline = $True,
          HelpMessage = "Path to either a file on the web or locally on the network to convert")]
        [string] $Path
    )
    if (($Path -match '^[A-z]:\\.*(\.png|\.jpg)$') -or ($Path -match '^\\\\*\\.*(\.png|\.jpg)$')) {
        if (Test-Path -Path "filesystem::$Path") {
            $EncodedImage = [convert]::ToBase64String((Get-Content $Path -Encoding byte))
        }
        else {
            Write-Error "Path not found: $path"
            return $false
        }
    }
    elseif ($Path -match '^http[s]://.*(\.png|\.jpg)$') {
        $ext = $Path.Substring($Path.Length-4)
        $tempfile = "${env:TEMP}\logo31337$ext"
        if (Test-Path $tempfile) {Remove-Item -Path $tempfile -Force}
        try {
          Invoke-WebRequest -Uri $Path -OutFile $tempfile
        }
        catch {
            Write-Warning "Image for title page not found. Building title page without image."
            return $false
        }
        $EncodedImage = [convert]::ToBase64String((Get-Content $tempfile -Encoding byte))
    }
    else {
        Write-Error "Path does not match pattern: $path"
        return $false
    }
    if ($path.EndsWith(".jpg")) {$imgtype = "jpg"}
    elseif ($path.EndsWith(".png")) {$imgtype = "png"}
    "data:image/$imgtype;base64,$EncodedImage"
}
