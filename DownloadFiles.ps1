$GameExecutable = "Lethal Company.exe"
$DestinationDir = "BepInEx"
$TempDir = ".\tmp"
$StartDir = Get-Location

# Class object for each file download.
class Config
{
  [string]$Url
  [string]$Hash
  [string]$SrcFilePath
  [string]$DestFilePath
}

function Clean-OldMods
{
  Remove-Item -ErrorAction SilentlyContinue -ErrorVariable RemoveError -Recurse -Path CHANGELOG.md, changelog.txt, doorstop_config.ini, icon.png, manifest.json, README.md, winhttp.dll, .doorstop_version, $DestinationDir
  if ($RemoveError)
  {
    # If there was an error and the BepInEx folder still exists, we did not correctly remove the old version.
    # This could happen in situations where we don't have proper permissions.
    # Otherwise continue without printing errors for the cases where a file we don't care as much about remained, such as "CHANGELOG.md"
    If (Test-Path -Path "$DestinationDir")
    {
      # Print the error message and end the script. Ignore errors for "does not exist" as that will match other files and clutter error output.
      throw "An error occurred: $($RemoveError | Where-Object {$_ -notmatch "because it does not exist"})"
    }
  }
}

function Clean-Success
{
  # We use $StartDir because the script files may not be relative to the GameDirectory later.
  Remove-Item -ErrorAction SilentlyContinue -ErrorVariable RemoveError -Recurse -Path $TempDir, $StartDir\DownloadConfig.txt, $StartDir\DestinationConfig.txt,  $StartDir\DownloadFiles.ps1, $StartDir\README.md
  # Couldn't get this to work: , $StartDir\..\LC-Mod-Script*
  # We only care about an error if its not a "does not exist" error because the above Remote-Item will not always find a match.
  if ($RemoveError)
  {
    $ErrorsWeCareAbout = $($RemoveError | Where-Object {$_ -notmatch "because it does not exist"})
    if ($($ErrorsWeCareAbout).Count -gt 0)
    {
      throw "An error occurred: $ErrorsWeCareAbout"
    }
  }
}

# === Importing DownloadConfig ===
# Config file Format: Url, Hash, SrcFilePath, DestFilePath.
$DownloadConfig = Get-Content -Path "DownloadConfig.txt" | ForEach-Object {
  $fields = $_ -split ',' # Split the line by comma
  [Config] @{
    Url = $fields[0]
    Hash = $fields[1]
    SrcFilePath = $fields[2]
    DestFilePath = $fields[3]
  }
  $ItemNumber++
}


# === Finding the Game directory ===
$GameDirectory = $null

# Nested breaks in PowerShell https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_break?view=powershell-7.4#using-break-in-loops
:GameDirectoryLoop foreach ($IterateDirectory in Get-Content -Path "DestinationConfig.txt")
{
  # If the first character in a directory is *, we're treating that as wanting to iterate over drive letters.
  # For instances where we are not iterating over drive letters, the later foreach statement is pointless as there will only be one object.
  if ($IterateDirectory[0] -eq "*")
  {
    $MountedDrives = (Get-PSDrive -PSProvider FileSystem).Root # Gets array of mounted drive letters ex: "C:/ D:/ E:/"
    $NewIterateDirectory = $IterateDirectory.TrimStart("*/") # Removes starting */ ex: "*/SteamLibrary/steamapps -> SteamLibrary/steamapps"
    $IterateDirectory = @() # Empties array
    foreach ($Drive in $MountedDrives)
    {
      $IterateDirectory += ($Drive + $NewIterateDirectory) # Combines. ex: "D:/SteamLibrary/steamapps E:/SteamLibrary/steamapps"
    }
  }

  foreach ($IterateSubDir in $IterateDirectory)
  {
    Write-Output "Checking $IterateSubDir/$GameExecutable"
    if (Test-Path -Path "$IterateSubDir/$GameExecutable")
    {
      $GameDirectory = $IterateSubDir
      Write-Output "Game Directory is $GameDirectory"
      break GameDirectoryLoop
    }
  }
}

if ($GameDirectory -eq $null)
{
  throw "Cannot find game directory! Try running the script again inside the game's directory."
}



Set-Location -Path $GameDirectory

# === Start making changes ===
New-Item -ItemType Directory -Path $TempDir -ErrorAction SilentlyContinue | Out-Null

# Remove old mod files.
If (Test-Path -Path "$DestinationDir")
{
  Clean-OldMods
  Write-Host "Old Version Removed"
}


# Download files and compare hashes.
# Used i instead of foreach to make it easier to reference files in temp directory by number.
$HashMatch = $true
$Count = $DownloadConfig.Count
for ($i = 0; $i -lt $Count; $i++)
{
  Invoke-WebRequest "$($DownloadConfig[$i].Url)" -O "$TempDir\$i.zip"
  $NewHash = Get-FileHash -Algorithm "SHA256" -Path "$TempDir\$i.zip"

  if ($($DownloadConfig[$i].Hash) -ne $NewHash.Hash)
  {
    $HashMatch = $false
    break
  }
}

# Extract files.
If ($HashMatch -eq $true)
{
  for ($i = 0; $i -lt $Count; $i++)
  {
    # Check to see if destination is empty.
    # If it is, parent and destination are intended to be current directory.
    # Otherwise find parent and set destination to include ".\"
    If ([string]::IsNullOrEmpty($($DownloadConfig[$i].DestFilePath)))
    {
      $Parentfolder = "."
      $Destination = "."
    }
    Else
    {
      $Parentfolder = Split-Path $($DownloadConfig[$i].DestFilePath) -Parent
      $Destination = ".\$($DownloadConfig[$i].DestFilePath)"
    }

    # Create temporary directory to extract to.
    New-Item -ItemType Directory -Path $TempDir\$i -ErrorAction SilentlyContinue | Out-Null
    
    # Create folder to move desired files to.
    New-Item -ItemType Directory -Path $Parentfolder -ErrorAction SilentlyContinue | Out-Null

    # Try catch block only here to avoid potential errors with creating folders that exist.
    $Error.Clear()
    try
    {
      Expand-Archive -Path "$TempDir\$i.zip" -DestinationPath "$TempDir\$i" -Force
      Move-Item -Path "$TempDir\$i\$($DownloadConfig[$i].SrcFilePath)" -Destination "$Destination" -Force
    }
    catch
    {
      Write-Error $_
      Write-Warning "Extract incomplete, see errors!"
      break
    }
  }
  if (!$Error)
  {
    Write-Host "Extract completed successfully!"
  }
}
Else
{
  Write-Error "Hashes don't match!"
}

Clean-Success
Pause
