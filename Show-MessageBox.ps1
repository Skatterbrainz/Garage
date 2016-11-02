
function Show-MessageBox {
    PARAM (
        [parameter(Mandatory=$True, Position=0)] [string] $Caption,
        [parameter(Mandatory=$True, Position=1)] [string] $Message,
        [parameter(Mandatory=$False, Position=2)] 
            [ValidateSet("OkOnly","OkCancel","AbortRetryIgnore","YesNo","YesNoCancel","RetryCancel")] 
            [string] $ButtonSet = "OkOnly",
        [parameter(Mandatory=$False, Position=3)]
            [ValidateSet("None","Information","Question","Exclamation")]
            [string] $IconType = "None"
    )
    switch ($ButtonSet) {
        'RetryCancel' {$buttons = 5; break}
        'YesNo' {$buttons = 4; break}
        'YesNoCancel' {$buttons = 3; break}
        'AbortRetryIgnore' {$buttons = 2; break}
        'OkCancel' {$buttons = 1; break}
        default {$buttons = 0}
    }
    switch ($IconType) {
        'Information' {$icon = 64; break}
        'Exclamation' {$icon = 48; break}
        'Question' {$icon = 32; break}
        'Critical' {$icon = 16; break}
        default {$icon = 0}
    }
    $result = [System.Windows.Forms.MessageBox]::Show($Message, $Caption, $buttons, $icon) 
    return $result
}

$x = Show-MessageBox -Caption "Testing" -Message "Do you want to continue?" -ButtonSet YesNo -IconType Question
