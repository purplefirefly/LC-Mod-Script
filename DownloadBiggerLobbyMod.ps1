If (Test-Path -Path "BepInEx")
{
  Remove-Item -Recurse CHANGELOG.md, changelog.txt, doorstop_config.ini, icon.png, manifest.json, README.md, winhttp.dll, .doorstop_version, BepInEx\
  Write-Host "Old Version Removed"
}

Invoke-WebRequest https://github.com/BepInEx/BepInEx/releases/download/v5.4.23.2/BepInEx_win_x64_5.4.23.2.zip -O bebin.zip
Invoke-WebRequest https://thunderstore.io/package/download/notnotnotswipez/MoreCompany/1.9.4/ -O morecompany.zip
Invoke-WebRequest https://thunderstore.io/package/download/tinyhoot/ShipLoot/1.1.0/ -O shiploot.zip

$bebinHash = Get-FileHash bebin.zip -Algorithm "SHA256"
$morecompanyHash = Get-FileHash morecompany.zip -Algorithm "SHA256"
$shiplootHash = Get-FileHash shiploot.zip -Algorithm "SHA256"

$bebinHashComp="f752ce4e838f4c305b9da1404b6745f2cff23b8bfd494f79f0c84d0a01f59b46"
$morecompanyHashComp="1cae988f9b3562fda930fafd7b04984253591800095a542e1396905366da5866"
$shiplootHashComp="3a3937d03e27c467e6d538d9ae90d5cf3cb946a7740d656d7623a01058f602c3"

If (($bebinHash.Hash -eq $bebinHashComp) -and ($morecompanyHash.Hash -eq $morecompanyHashComp) -and ($shiplootHash.Hash -eq $shiplootHashComp))
{
  Expand-Archive -Force bebin.zip .
  Expand-Archive -Force morecompany.zip .

  Expand-Archive -Force shiploot.zip tmp\
  Move-Item -Path tmp\plugins\ShipLoot\ShipLoot.dll -Destination BepInEx\plugins

  Write-Host "Finished!"
}
Else
{
  Write-Host "Error, hashes don't match."
}

Remove-Item -Recurse bebin.zip, morecompany.zip, shiploot.zip, tmp\, DownloadBiggerLobbyMod.ps1


Write-Host "Press any key to continue..."
$Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
