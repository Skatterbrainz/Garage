# disable AD password synch for domain-joined VM guests
New-Item -Path HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters -Name DisablePasswordChange -Value 1 -ItemType DWORD
