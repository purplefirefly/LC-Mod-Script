# LC-Mod-Script
Lethal Company Mod Install Script

A simple PowerShell script to automate installing the BiggerLobby Mod for Lethal Company v45.
https://thunderstore.io/c/lethal-company/p/bizzlemip/BiggerLobby/


Run this inside your Lethal Company folder to install the Bigger Lobby Mod.
To run a PowerShell file you must `Right Click -> Run with PowerShell` **double-click will open it in a text editor.**

If on Windows 11 (or have otherwise have a restrictive Execution Policy) you may have to run `powershell -ExecutionPolicy ByPass -File DownloadBiggerLobbyMod.ps1` in the game's directory.

Downloads and extracts; (the versions current as of 03-17-2024)
```
BepInEx_x64_v5.4.22
LC_API 3.4.5
BiggerLobby 2.7.0
ShipLoot 1.0.0
```

As well verifies all of their hashes for basic security.


Additional mods:
https://thunderstore.io/c/lethal-company/p/tinyhoot/ShipLoot/
