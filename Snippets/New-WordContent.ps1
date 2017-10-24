$Word = New-Object -ComObject "Word.Application" -ErrorAction Stop
$wordVersion = $Word.Version

if ($WordVersion -ge "16.0") {
    $TableStyle = "Grid Table 4 - Accent 1"
    $TableSimpleStyle = "Grid Table 4 - Accent 1"
}
elseif ($WordVersion -eq "15.0") {
    $TableStyle = "Grid Table 4 - Accent 1"
    $TableSimpleStyle = "Grid Table 4 - Accent 1"
}
elseif ($WordVersion -eq "14.0") {
    $TableStyle = "Medium Shading 1 - Accent 1"
    $TableSimpleStyle = "Light Grid - Accent 1"
}

$Word.visible = $True
$Doc = $Word.documents.Add()

$Selection = $Word.Selection
$Word.Options.CheckGrammarAsYouType = $False
$Word.Options.CheckSpellingAsYouType = $False
$Word.Templates.LoadBuildingBLocks() | Out-Null
$BuildingBlocks = $Word.Templates | Where-Object {$_.name -eq "Built-In Building BLocks.dotx"}
$part = $BuildingBlocks.BuildingBlockEntries.Item("Slice (Light)")

$part.Insert($Selection.Range,$True) | Out-Null
$Selection.InsertNewPage()
$toc = $BuildingBlocks.BuildingBlockEntries.Item("Automatic Table 2")
$toc.Insert($Selection.Range, $True) | Out-Null
$Selection.InsertNewPage()
$currentView = $doc.ActiveWindow.ActivePane.view.SeekView

$doc.ActiveWindow.ActivePane.view.SeekView = 4
$Selection.HeaderFooter.Range.Text = "Copyright $([char]0x00A9) $((Get-Date).year) - PCM"
$Selection.HeaderFooter.PageNumbers.Add(2) | Out-Null
$doc.ActiveWindow.ActivePane.view.SeekView = $currentView

$Selection.EndKey(6,0) | Out-Null

function Write-TableGrid {
    param (
        [parameter(Mandatory=$True)]
        [string] $Caption,
        [parameter(Mandatory=$True)]
        [int] $Rows,
        [parameter(Mandatory=$True)]
        [string[]] $ColumnHeadings
    )
    $Selection.TypeText($Caption)
    $Selection.Style = "Heading 1"
    $Selection.TypeParagraph()

    $Cols  = $ColumnHeadings.Length
    $Table = $doc.Tables.Add($Selection.Range, $rows, $cols)
    #$Table.AutoFormat()
    $Table.Style = "Grid Table 4 - Accent 1"
    for ($col = 1; $col -le $cols; $col++) {
        $Table.Cell(1, $col).Range.Text = $ColumnHeadings[$col-1]
    }
    for ($row = 1; $row -lt $rows; $row++) {
        $Table.Cell($row+1, 1).Range.Text = $row.ToString()
    }
    $Table.PreferredWidthType = 2
    $Table.PreferredWidth = 100
    $Table.Columns.First.PreferredWidthType = 2
    $Table.Columns.First.PreferredWidth = 10

    if ($Cols -gt 2) {
        $Table.Columns(2).PreferredWidthType = 2
        $Table.Columns(2).PreferredWIdth = 10
    }
    $Selection.EndOf(15) | Out-Null
	$Selection.MoveDown() | Out-Null
	$doc.ActiveWindow.ActivePane.view.SeekView = 0
	$Selection.EndKey(6, 0) | Out-Null
	$Selection.TypeParagraph()
}

Write-TableGrid -Caption "Summary of Findings" -Rows 4 -ColumnHeadings ("Item", "Explanation")

Write-TableGrid -Caption "Summary of Recommendations" -Rows 4 -ColumnHeadings ("Item", "Severity", "Explanation")
