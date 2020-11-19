function Get-CountryCodes {
  param()
  try {
    $allCountries = Invoke-RestMethod "https://restcountries.eu/rest/v2/all" -ErrorAction Stop
    $table = $allCountries | Foreach-Object {
        $cn  = $_.name 
        $c2  = $_.alpha2code 
        $c3  = $_.alpha3code 
        $cap = $_.capital
        $nc  = $_.numericCode
        # match the time zone using the capital city name, and grab the first std name value in the list
        $tz  = (Get-TimeZone -ListAvailable | Where-Object {$_.displayName -match $cap} | Select-Object -First 1 StandardName)
        if ($null -ne $tz) { $tz = $tz.StandardName }
        [pscustomobject]@{
            Country  = $cn
            CODE2    = $c2 
            CODE3    = $c3
            TimeZone = $tz
            CountryCode = $nc 
        }
    }
  }
  catch {
    Write-Error $_.Exception.Message 
  }
}
