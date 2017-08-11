# Update-UserAttributs.ps1

## Overview: 

	Updates AD user accounts using the [samaccountname] column
	for the lookup value.  Additional columns specify the attributes to 
	apply to the accounts.  


## Sample files included:

	BHFECA1.xlsx, BHFECA1.csv

## Description:
	
	Required parameters: Filename = path/name of CSV input file
	
	You can specify individual (filtered) attributes/columns
	using the -Attributes parameter, or (default) process all of them.
	
	You can also limit the number of users (rows) to process in the CSV input file
	using the -RowLimit parameter.
	
	This script supports -WhatIf and -Verbose
	
## NOTES:

1. Cells which have values that contain embedded semi-colons ";" are 
   treated as multi-valued (the value is split into an array before
   assigning to the account attribute)

2. Attribute names are case-insensitive, as are sAMAccountName values
	
