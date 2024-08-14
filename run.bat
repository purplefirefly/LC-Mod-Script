Powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "& .\DownloadFiles.ps1"
cd ..
START "" /B Powershell.exe -WindowStyle Hidden -Command Remove-Item -Recurse LC-Mod*
cd ..
START "" /B Powershell.exe -WindowStyle Hidden -Command Remove-Item -Recurse LC-Mod*
:: Running with START so it runs as its own process because otherwise it complained about being in-use.
:: Needed to run as PowerShell because CMD doesn't like to remove with wildcard.
:: Running twice in case nested twice.
:: Feels jank but it works.
