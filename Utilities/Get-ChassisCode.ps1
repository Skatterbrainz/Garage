function Get-ChassisCode {
  <#
  .SYNOPSIS
    Return descriptive name for chassis type
  .DESCRIPTION
    Return descriptive name and code for chassis type
  .PARAMETER ChassisType
    [integer] chassis type number (0 to 36)
  #>
	param (
		[parameter(Mandatory=$True, HelpMessage="ChassisTypes integer value")]
		[ValidateNotNullOrEmpty()]
		[int] $ChassisType
	)
	switch ($ChassisType) {
		 1 {$ffname = "Other"; $ffcode = "X"; break }
		 2 {$ffname = "Unknown"; $ffcode = "X"; break }
		 3 {$ffname = "Desktop"; $ffcode = "D"; break }
		 4 {$ffname = "Low Profile Desktop"; $ffcode = "D"; break }
		 5 {$ffname = "Pizza Box"; $ffcode = "D"; break }
		 6 {$ffname = "Mini Tower"; $ffcode = "D"; break }
		 7 {$ffname = "Tower"; $ffcode = "D"; break }
		 8 {$ffname = "Portable"; $ffcode = "L"; break }
		 9 {$ffname = "Laptop"; $ffcode = "L"; break }
		10 {$ffname = "Notebook"; $ffcode = "L"; break }
		11 {$ffname = "Hand Held"; $ffcode = "L"; break }
		12 {$ffname = "Docking Station"; $ffcode = "X"; break }
		13 {$ffname = "All in One"; $ffcode = "D"; break }
		14 {$ffname = "Sub Notebook"; $ffcode = "L"; break }
		15 {$ffname = "Space-Saving"; $ffcode = "D"; break }
		16 {$ffname = "Lunch Box"; $ffcode = "D"; break }
		17 {$ffname = "Main System Chassis"; $ffcode = "X"; break }
		18 {$ffname = "Expansion Chassis"; $ffcode = "X"; break }
		19 {$ffname = "SubChassis"; $ffcode = "X"; break }
		20 {$ffname = "Bus Expansion Chassis"; $ffcode = "X"; break }
		21 {$ffname = "Peripheral Chassis"; $ffcode = "X"; break }
		22 {$ffname = "RAID Chassis"; $ffcode = "X"; break }
		23 {$ffname = "Rack Mount Chassis"; $ffcode = "X"; break }
		24 {$ffname = "Sealed-case PC"; $ffcode = "X"; break }
		25 {$ffname = "Multi-system chassis"; $ffcode = "D"; break }
		26 {$ffname = "Compact PCI"; $ffcode = "D"; break }
		27 {$ffname = "Advanced TCA"; $ffcode = "D"; break }
		28 {$ffname = "Blade"; $ffcode = "S"; break }
		29 {$ffname = "Blade Enclosure"; $ffcode = "S"; break }
		30 {$ffname = "Tablet"; $ffcode = "T"; break }
		31 {$ffname = "Convertible"; $ffcode = "L"; break }
		32 {$ffname = "Detachable"; $ffcode = "X"; break }
		33 {$ffname = "IoT Gateway"; $ffcode = "X"; break }
		34 {$ffname = "Embedded PC"; $ffcode = "D"; break }
		35 {$ffname = "Mini PC"; $ffcode = "D"; break }
		36 {$ffname = "Stick PC"; $ffcode = "D"; break }
		default {$ffname = "Other"; $ffcode = "X"; break }
	}
	Write-Output @($ffname, $ffcode)
}
