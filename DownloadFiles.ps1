$TempDir = ".\tmp"
New-Item -ItemType Directory -Path $TempDir -ErrorAction SilentlyContinue | Out-Null

# Class object for each file download.
class Config
{
  [string]$Url
  [string]$Hash
  [string]$SrcFilePath
  [string]$DestFilePath
}

# Array of above objects to make iterating over them easier. Import from file.
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

function OldClean
{
  Remove-Item -ErrorAction SilentlyContinue -ErrorVariable RemoveError -Recurse -Path CHANGELOG.md, changelog.txt, doorstop_config.ini, icon.png, manifest.json, README.md, winhttp.dll, .doorstop_version, BepInEx\
  if ($RemoveError)
  {
    # If there was an error and the BepInEx folder still exists, we did not correctly remove the old version.
    # This could happen in situations where we don't have proper permissions.
    # Otherwise continue without printing errors for the cases where a file we don't care as much about remained, such as "CHANGELOG.md"
    If (Test-Path -Path "BepInEx")
    {
      # Print the error message and end the script. Ignore errors for "does not exist" as that will match other files and clutter error output.
      throw "An error occurred: $($RemoveError | Where-Object {$_ -notmatch "because it does not exist"})"
    }
  }
}

# Remove old mod files.
If (Test-Path -Path "BepInEx")
{
  OldClean
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

Remove-Item -Recurse -Path $TempDir, DownloadConfig.txt, DownloadFiles.ps1, run.bat


Write-Host "Press any key to continue..."
$Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
