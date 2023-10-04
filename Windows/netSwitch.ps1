$testHost = "www.google.com"	#site to ping to verify connectivity
$ethAdapter = "Ethernet"		#name of the wired adapter
$wlanAdapter = "Wi-Fi"			#name of the wireless adpter to enable in case of connectivity issues
$wlanSsid = "Hotspot1"			#name of backup wireless connection to switch to if unable to ping the site with wired connection

$checkConnectionInterval = 30	#interval between pings to remote server
$checkEthStatusInterval = 30	#the amount of seconds to wait after a successful switch before trying to switch back to wired
$ethGracePeriod = 30			#grace period after switching back to wired connection before performing the first test

function Print-Event($strIn){
	$timestamp = Get-Date -Format "dd/MM/yyyy HH:mm:ss K"
	$output = "${timestamp}: $strIn"
	Write-Output $output
}

while($true){
	Print-Event "Testing connection..."
	if(-not (Test-Connection -ComputerName $testHost -Quiet -Count 2) ) {
		Print-Event "Connection is DOWN. Switching to wlan..."
		Disable-NetAdapter -Name $ethAdapter -Confirm:$false
		Enable-NetAdapter -Name $wlanAdapter -Confirm:$false
		netsh wlan connect name=$wlanSsid
		
		while((Get-NetAdapter -Name $wlanAdapter | select -ExpandProperty MediaConnectionState) -ne "Connected"){
			Start-Sleep -s 5
		}
		
		Print-Event "Switch completed"
		
		while($true){
			Start-Sleep -s $checkEthStatusInterval
			
			Print-Event "Testing connection with Ethernet..."
			Enable-NetAdapter -Name $ethAdapter -Confirm:$false
			
			while((Get-NetAdapter -Name $ethAdapter | select -ExpandProperty MediaConnectionState) -ne "Connected"){
					Start-Sleep -s 5
			}
			Start-Sleep -s $ethGracePeriod
			
			Print-Event "Interface enabled. Testing connection..."
			
			if(Test-Connection -ComputerName $testHost -Quiet -Count 2){
				Print-Event "Connection is operational again. Switching back to Ethernet"		
				break
			}
			
			Print-Event "Connection is still DOWN"
			Disable-NetAdapter -Name $ethAdapter -Confirm:$false
		}
		
		netsh wlan disconnect
	}	
	Print-Event "Connection is UP"
	Start-Sleep -s $checkConnectionInterval
}