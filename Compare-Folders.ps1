param (
    [parameter(Mandatory=$True)] [string] $Path1,
    [parameter(Mandatory=$True)] [string] $Path2,
    [parameter(Mandatory=$False)] [switch] $FoldersOnly,
    [parameter(Mandatory=$False)] [switch] $Reverse,
    [parameter(Mandatory=$False)] [switch] $Copy,
    [parameter(Mandatory=$False)] [switch] $Move,
    [parameter(Mandatory=$False)] [string] $Filter = ""
)

if (!(Test-Path $Path1)) {
    Write-Error "Path not found: $Path1"
    break
}
if (!(Test-Path $Path2)) {
    Write-Output "Creating target path: $Path2"
    New-Item -Path $Path2 -ItemType Directory -Force
}

# fetch sorted list of subfolders or files for each path location

if ($FoldersOnly) {
    $f1 = Get-ChildItem -Path $Path1 -Directory | Select -ExpandProperty Name | Sort-Object
    $f2 = Get-ChildItem -Path $Path2 -Directory | Select -ExpandProperty Name | Sort-Object
}
else {
    $f1 = Get-ChildItem -Path $Path1 -File | Select -ExpandProperty Name | Sort-Object
    $f2 = Get-ChildItem -Path $Path2 -File | Select -ExpandProperty Name | Sort-Object
}

# filter out unwanted items if requested

if ($Filter -ne "") {
    $f1 | Where-Object {$_ -like $Filter}
    $f2 | Where-Object {$_ -like $Filter}
}

# compare P1 with P2 or P2 with P1 (reverse or not reverse)

if ($Reverse) {
    $cx = $f2 | Where-Object {$f1 -notcontains $_}
}
else {
    $cx = $f1 | Where-Object {$f2 -notcontains $_}
}

Write-Output $Path1
Write-Output "-----------------------------"
if ($Copy) {
    foreach ($f in $cx) {
        $fn = "$Path1" + "`\$f"
        write-output $fn
        Copy-Item $fn -Destination $Path2 -Force
    }
}
elseif ($Move) {
    foreach ($f in $cx) {
        $fn = "$Path1" + "`\$f"
        write-output $fn
        Move-Item $fn -Destination $Path2 -Force
    }
}
else {
    $cx
    Write-Output "$($cx.Count) items found"
}
