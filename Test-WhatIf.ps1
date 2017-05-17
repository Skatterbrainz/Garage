function Foo {
    [CmdletBinding(SupportsShouldProcess=$True)]
    param (
        [string] $Test
    )
    if ($WhatIfPreference) {
        Write-Output "-WhatIf was requested"
        # do something with $Test
    }
    else {
        # do something with $Test
    }
}
