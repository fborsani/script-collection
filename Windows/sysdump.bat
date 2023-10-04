@echo off
cls
echo Script started
(echo %date% %time% & tzutil /g & echo. & hostname & whoami & systeminfo & echo. & echo. & ipconfig & echo. & echo. & wmic qfe get HotFixID, InstalledOn, Caption, Description & echo. & echo. & net user & whoami /groups & whoami /priv) | clip
echo Execution completed. The output is stored in your clipboard.
pause