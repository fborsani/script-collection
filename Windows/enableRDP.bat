@echo OFF
for /f "tokens=3 delims= " %%i in ('reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server" /v fDenyTSConnections') do (
    if %ERRORLEVEL% equ 0 (
	    echo Missing key
	    set doWork=1
	)
    else(
	if "%%i" equ "0x1" (
            echo RDP is active
            set doWork=0
        ) 
        else (
            echo RDP not active
	    set doWork=1
       )
  )

if %doWork% equ 1(
	echo enabling RDP
	reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server" /v fDenyTSConnections /t REG_DWORD /d 0 /f && (echo Registry configured) || (echo Registry config failed; exit)
	netsh firewall add portopening TCP 3389 "Remote Desktop" && (echo Firewall configured) || (echo Firewall config failed; exit)
	for /f "tokens=2 delims=\" %%i IN ('whoami') do (net localgroup "Remote Desktop Users" "%%i" /add)  && (echo Current user added to RDP group) || (echo Failed to add to RDP group; exit)
	echo Done.
)

pause
