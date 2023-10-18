@echo OFF
if "%1" equ "me"(
	takeown /f "%2" /r /d y
	exit
)

if "%1" equ "admin"(
	takeown /f "%2" /a /r /d y
	exit
)

if "%1" equ "trusted"(
	icacls "%2" /grant administrators:F /T
	icacls "%2" /setowner "NT Service\TrustedInstaller"
	exit
)
if "%1" equ "user"(
	icacls "%2" /grant administrators:F /T
	icacls "%2" /setowner "%3"
	exit
)

echo "Change the ownership of a file"
echo "Usage chown.bat <me|admin|trusted|user [username]> file"
exit