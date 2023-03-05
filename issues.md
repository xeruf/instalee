https://superuser.com/questions/55809/how-to-run-program-from-command-line-with-elevated-rights

- auto-elevation of choco
- post-choco-install check if launching git bash works
- add choco to handlers

Set-Location : Illegales Zeichen im Pfad.
In K:\instalee\packages\chocolatey\powershell.ps1:24 Zeichen:5
+     Set-Location $Loc.Substring(1,$Loc.Length-1)
+     ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidArgument: (K:\instalee":String) [Set-Location], ArgumentException
    + FullyQualifiedErrorId : ItemExistsArgumentError,Microsoft.PowerShell.Commands.SetLocationCommand

Set-Location : Der Pfad "K:\instalee"" kann nicht gefunden werden, da er nicht vorhanden ist.
In K:\instalee\packages\chocolatey\powershell.ps1:24 Zeichen:5
+     Set-Location $Loc.Substring(1,$Loc.Length-1)
+     ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : ObjectNotFound: (K:\instalee":String) [Set-Location], ItemNotFoundException
    + FullyQualifiedErrorId : PathNotFound,Microsoft.PowerShell.Commands.SetLocationCommand

https://stackoverflow.com/questions/52223872/get-windows-version-from-git-bash

# Windows 7

https://dotnet.microsoft.com/en-us/download/dotnet-framework
-> Unsupported Versions: 4.5