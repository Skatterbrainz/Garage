$ThisPath = $pwd.Path

$ThisComputer = $env:COMPUTERNAME

$ThisUser = $env:USERNAME

$String1 = "This is a test."

# walk through each character in $String1...

for ($i = 0; $i -lt $String.Length; $i++) {
  $String1.Substring($i,1)
}

