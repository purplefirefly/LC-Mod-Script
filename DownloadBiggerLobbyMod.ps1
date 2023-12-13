#Tutorial video: https://www.youtube.com/watch?v=pefi48O-giU

If (Test-Path -Path "BepInEx")
{
  Remove-Item -Recurse CHANGELOG.md, changelog.txt, doorstop_config.ini, icon.png, manifest.json, README.md, winhttp.dll, BepInEx\
  Write-Host "Old Version Removed"
}

Invoke-WebRequest https://github.com/BepInEx/BepInEx/releases/download/v5.4.22/BepInEx_x64_5.4.22.0.zip -O bebin.zip
Invoke-WebRequest https://thunderstore.io/package/download/2018/LC_API/2.1.1/ -O lc_api.zip 
Invoke-WebRequest https://thunderstore.io/package/download/bizzlemip/BiggerLobby/2.4.0/ -O biggerlobby.zip

$bebinHash = Get-FileHash bebin.zip -Algorithm "SHA256"
$lc_apiHash = Get-FileHash lc_api.zip -Algorithm "SHA256"
$biggerlobbyHash = Get-FileHash biggerlobby.zip -Algorithm "SHA256"

$bebinHashComp="4c149960673f0a387ba7c016c837096ab3a41309d9140f88590bb507c59eda3f"
$lc_apiHashComp="c4a6ab0bf321968524a3342757a00f04db2ad36a41e742b5d2d40cbfb7f02a8f"
$biggerlobbyHashComp="c751d9b8ab91d922884d84e597ba6c6083459d284af7a82389752adce70cf85a"

If (($bebinHash.Hash -eq $bebinHashComp) -and ($lc_api.Hash -eq $lc_apiComp) -and ($biggerlobbyHash.Hash -eq $biggerlobbyHashComp))
{
  Expand-Archive bebin.zip .
  Expand-Archive -Force lc_api.zip .
  Expand-Archive -Force biggerlobby.zip .

  Write-Host "Finished!"
}
Else
{
  Write-Host "Error, hashes don't match."
}

Remove-Item -Recurse bebin.zip, lc_api.zip, biggerlobby.zip, DownloadBiggerLobbyMod.ps1


Write-Host "Press any key to continue..."
$Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")