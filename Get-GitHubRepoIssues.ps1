#requires -modules PowerShellForGitHub

function Get-GitHubRepoIssues {
    [CmdletBinding()]
    param (
        [parameter(Mandatory=$True, HelpMessage="The name of your repository")]
        [ValidateNotNullOrEmpty()]
        [string] $RepoName,
        [parameter(Mandatory=$False, HelpMessage="GitHub site base URL")]
        [ValidateNotNullOrEmpty()]
        [string] $BaseUrl = "https://github.com/skatterbrainz"
    )
    try {
        $issues = Get-GitHubIssue -Uri "$BaseUrl/$RepoName" -NoStatus | 
            Where-Object {$_.state -eq 'open'} | 
                Sort-Object Id |
                    Select Id,Title,State,Labels,Milestone,html_url

        $issues | % {
            $labels = $null 
            if (![string]::IsNullOrEmpty($_.Labels.name)) {
                $labels = $_.Labels.name -join ';'
            }
            [pscustomobject]@{
                ID     = $_.Id
                Title  = $_.Title
                State  = $_.state
                Labels = $Labels
                Milestone = $_.milestone.title
                URL    = $_.html_url
            }
        }
    }
    catch {
        Write-Error $Error[0].Exception.Message
    }
}
