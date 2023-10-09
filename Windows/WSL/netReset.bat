@echo off
wsl.exe --shutdown

ipconfig /release
ipconfig /flushdns
ipconfig /renew
netsh winsock reset