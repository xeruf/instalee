
powershell -Command "Start-Process 'reg' -Verb runAs -ArgumentList 'add HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\TimeZoneInformation /v RealTimeIsUniversal /d 1 /f'"
