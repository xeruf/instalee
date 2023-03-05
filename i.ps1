# manual execution: Set-ExecutionPolicy Bypass -Scope Process -Force; .\i
(Test-Path "$PWD\instalee" -PathType Container) -and (cd instalee) | out-null
packages\chocolatey\powershell.ps1
Start-Process -Wait choco -Verb runAs -ArgumentList 'install git'
Start-Process -Wait "C:\Program Files\Git\git-bash.exe" -Verb runAs -ArgumentList "-c './instalee win/office; sleep 10 || bash'"
# Sleep 10
