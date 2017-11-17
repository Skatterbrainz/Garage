# Task List

## Tasks to be Completed

- [x] First task
- [x] Second task
- [ ] Third task

# Ordered List

## This is an ordered list

1. First sentence
   a. Sub-section 1
   b. Sub-section 2

# Numeric List Format with Nesting

1. First sentenct
   1. Sub-section 1
       1. Sub-section nested 1
       1. Sub-section nested 2
   1. Sub-section 2

# Formatting Code

```powershell
function Write-StringValue () {
  param (
    [parameter(Mandatory=$True, HelpMessage="Text value to display")]
    [ValidateNotNullOrEmpty()]
    [string] $Message
  )
  Write-Host $Message -ForegroundColor Green
}
```
