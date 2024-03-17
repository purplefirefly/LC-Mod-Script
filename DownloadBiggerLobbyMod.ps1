If (Test-Path -Path "BepInEx")
{
  Remove-Item -Recurse CHANGELOG.md, changelog.txt, doorstop_config.ini, icon.png, manifest.json, README.md, winhttp.dll, BepInEx\
  Write-Host "Old Version Removed"
}

Invoke-WebRequest https://github.com/BepInEx/BepInEx/releases/download/v5.4.22/BepInEx_x64_5.4.22.0.zip -O bebin.zip
Invoke-WebRequest https://thunderstore.io/package/download/2018/LC_API/3.4.5/ -O lc_api.zip
Invoke-WebRequest https://thunderstore.io/package/download/bizzlemip/BiggerLobby/2.7.0/ -O biggerlobby.zip
Invoke-WebRequest https://thunderstore.io/package/download/tinyhoot/ShipLoot/1.0.0/ -O shiploot.zip

$bebinHash = Get-FileHash bebin.zip -Algorithm "SHA256"
$lc_apiHash = Get-FileHash lc_api.zip -Algorithm "SHA256"
$biggerlobbyHash = Get-FileHash biggerlobby.zip -Algorithm "SHA256"
$shiplootHash = Get-FileHash shiploot.zip -Algorithm "SHA256"

$bebinHashComp="4c149960673f0a387ba7c016c837096ab3a41309d9140f88590bb507c59eda3f"
$lc_apiHashComp="cb421a0b4802cedb62b5bc08f6e8831c9bb49d1647c2d5ede6e2696ff8fb233d"
$biggerlobbyHashComp="58ff5c44828206e614bb7a178b74dbdb3cb8f8c378d5edf729ac5232792b273d"
$shiplootHashComp="0c5bb6d1fef37318eaec72c65947b7a4102a00b484790d0ac7380c8959832c7f"

If (($bebinHash.Hash -eq $bebinHashComp) -and ($lc_api.Hash -eq $lc_apiComp) -and ($biggerlobbyHash.Hash -eq $biggerlobbyHashComp) -and ($shiplootHash.Hash -eq $shiplootHashComp))
{
  Expand-Archive bebin.zip .
  Expand-Archive -Force lc_api.zip .
  Expand-Archive -Force biggerlobby.zip .

  Expand-Archive -Force shiploot.zip tmp\
  Move-Item -Path tmp\plugins\ShipLoot\ShipLoot.dll -Destination BepInEx\plugins

  Write-Host "Finished!"
}
Else
{
  Write-Host "Error, hashes don't match."
}

Remove-Item -Recurse bebin.zip, lc_api.zip, biggerlobby.zip, shiploot.zip, tmp\, DownloadBiggerLobbyMod.ps1


Write-Host "Press any key to continue..."
$Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
