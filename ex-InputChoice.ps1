#----------------------------------------------------------------
# Filename...: input_choice.ps1
# Author.....: 
# Date.......: 
# Purpose....: demonstrate getting user input choice (Y or N)
#----------------------------------------------------------------

$choice = Read-Host `n "Display a question preposition here." `
"`nDo you want to continue? [Y,N]"

if ($choice -eq "Y") {
	write-host -foregroundColor "Green" "You answered YES"
} else {
	write-host -foregroundColor "Yellow" "You did not answer yes."
}