Param(
    [string]$Loc
)

if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
        [Security.Principal.WindowsBuiltInRole] 'Administrator')
)
{
    Write-Host "Not elevated, relaunching $($MyInvocation.MyCommand.Path)..."
    $Loc = Get-Location

    $Arguments = @(
        '-NoProfile',
        '-ExecutionPolicy Bypass',
        '-File',
        "`"$($MyInvocation.MyCommand.Path)`"",
        "\`"$Loc\`""
    )
    Start-Process -Wait -FilePath PowerShell.exe -Verb RunAs -ArgumentList $Arguments
    Return
}
if($Loc.Length -gt 1){
    Set-Location $Loc.Substring(1,$Loc.Length-2)
}
# https://github.com/lukegackle/PowerShell-Self-Elevate-Keeping-Current-Directory/blob/master/Self%20Elevate%20Keeping%20Directory.ps1

function Install-ChocolateyFromPackage {
param (
  [string]$chocolateyPackageFilePath = ''
)

  if ($chocolateyPackageFilePath -eq $null -or $chocolateyPackageFilePath -eq '') {
    throw "You must specify a local package to run the local install."
  }

  if (!(Test-Path($chocolateyPackageFilePath))) {
    throw "No file exists at $chocolateyPackageFilePath"
  }

  $chocTempDir = Join-Path $env:TEMP "chocolatey"
  $tempDir = Join-Path $chocTempDir "chocInstall"
  if (![System.IO.Directory]::Exists($tempDir)) {[System.IO.Directory]::CreateDirectory($tempDir)}
  $file = Join-Path $tempDir "chocolatey.zip"
  Copy-Item $chocolateyPackageFilePath $file -Force

  # unzip the package
  Write-Output "Extracting $file to $tempDir..."
  if ($unzipMethod -eq '7zip') {
    $7zaExe = Join-Path $tempDir '7za.exe'
    if (-Not (Test-Path ($7zaExe))) {
      Write-Output 'Downloading 7-Zip commandline tool prior to extraction.'
      # download 7zip
      Download-File $7zipUrl "$7zaExe"
    }

    $params = "x -o`"$tempDir`" -bd -y `"$file`""
    # use more robust Process as compared to Start-Process -Wait (which doesn't
    # wait for the process to finish in PowerShell v3)
    $process = New-Object System.Diagnostics.Process
    $process.StartInfo = New-Object System.Diagnostics.ProcessStartInfo($7zaExe, $params)
    $process.StartInfo.RedirectStandardOutput = $true
    $process.StartInfo.UseShellExecute = $false
    $process.StartInfo.WindowStyle = [System.Diagnostics.ProcessWindowStyle]::Hidden
    $process.Start() | Out-Null
    $process.BeginOutputReadLine()
    $process.WaitForExit()
    $exitCode = $process.ExitCode
    $process.Dispose()

    $errorMessage = "Unable to unzip package using 7zip. Perhaps try setting `$env:chocolateyUseWindowsCompression = 'true' and call install again. Error:"
    switch ($exitCode) {
      0 { break }
      1 { throw "$errorMessage Some files could not be extracted" }
      2 { throw "$errorMessage 7-Zip encountered a fatal error while extracting the files" }
      7 { throw "$errorMessage 7-Zip command line error" }
      8 { throw "$errorMessage 7-Zip out of memory" }
      255 { throw "$errorMessage Extraction cancelled by the user" }
      default { throw "$errorMessage 7-Zip signalled an unknown error (code $exitCode)" }
    }
  } else {
    if ($PSVersionTable.PSVersion.Major -lt 5) {
      try {
        $shellApplication = new-object -com shell.application
        $zipPackage = $shellApplication.NameSpace($file)
        $destinationFolder = $shellApplication.NameSpace($tempDir)
        $destinationFolder.CopyHere($zipPackage.Items(),0x10)
      } catch {
        throw "Unable to unzip package using built-in compression. Set `$env:chocolateyUseWindowsCompression = 'false' and call install again to use 7zip to unzip. Error: `n $_"
      }
    } else {
      Expand-Archive -Path "$file" -DestinationPath "$tempDir" -Force
    }
  }

  # Call Chocolatey install
  Write-Output 'Installing chocolatey on this machine'
  $toolsFolder = Join-Path $tempDir "tools"
  $chocInstallPS1 = Join-Path $toolsFolder "chocolateyInstall.ps1"

  & $chocInstallPS1

  Write-Output 'Ensuring chocolatey commands are on the path'
  $chocInstallVariableName = 'ChocolateyInstall'
  $chocoPath = [Environment]::GetEnvironmentVariable($chocInstallVariableName)
  if ($chocoPath -eq $null -or $chocoPath -eq '') {
    $chocoPath = 'C:\ProgramData\Chocolatey'
  }

  $chocoExePath = Join-Path $chocoPath 'bin'

  if ($($env:Path).ToLower().Contains($($chocoExePath).ToLower()) -eq $false) {
    $env:Path = [Environment]::GetEnvironmentVariable('Path',[System.EnvironmentVariableTarget]::Machine);
  }

  Write-Output 'Ensuring chocolatey.nupkg is in the lib folder'
  $chocoPkgDir = Join-Path $chocoPath 'lib\chocolatey'
  $nupkg = Join-Path $chocoPkgDir 'chocolatey.nupkg'
  if (!(Test-Path $nupkg)) {
    Write-Output 'Copying chocolatey.nupkg is in the lib folder'
    if (![System.IO.Directory]::Exists($chocoPkgDir)) { [System.IO.Directory]::CreateDirectory($chocoPkgDir); }
    Copy-Item "$file" "$nupkg" -Force -ErrorAction SilentlyContinue
  }
}

$ChocoInstallPath = "$($env:SystemDrive)\ProgramData\Chocolatey\bin"
# Idempotence - do not install Chocolatey if it is already installed
if (!(Test-Path $ChocoInstallPath)) {
  # Install Chocolatey
  try {
    # Set TLS 1.2 (3072) as that is the minimum required by Chocolatey.org
    # Use integers because the enumeration value for TLS 1.2 won't exist
    # in .NET 4.0, even though they are addressable if .NET 4.5+ is
    # installed (.NET 4.5 is an in-place upgrade).
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
  } catch {
    Write-Warning 'Unable to set PowerShell to use TLS 1.2. This is required for contacting Chocolatey as of 03 FEB 2020. https://blog.chocolatey.org/2020/01/remove-support-for-old-tls-versions/. If you see underlying connection closed or trust errors, you may need to do one or more of the following: (1) upgrade to .NET Framework 4.5+ and PowerShell v3+, (2) Call [System.Net.ServicePointManager]::SecurityProtocol = 3072; in PowerShell prior to attempting installation, (3) specify internal Chocolatey package location (set $env:chocolateyDownloadUrl prior to install or host the package internally), (4) use the Download + PowerShell method of install. See https://docs.chocolatey.org/en-us/choco/installation for all install options.'
    # https://docs.chocolatey.org/en-us/choco/setup#completely-offline-install
    $scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
    Install-ChocolateyFromPackage $scriptPath\chocolatey*.nupkg
  }
}
choco feature enable -n allowGlobalConfirmation
choco upgrade all