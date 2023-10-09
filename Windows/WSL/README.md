# WSL Network errors Troubleshooting Guide

## Introduction

The purpose of this guide is to fix configuration errors that may occure both on Windows and the *nix machine emulated through WSL.<br/>
The files and commands present in the linux section are not distro or version specific but can be run on any version of ubuntu, RHEL or other architectures.<br/>
You will need Administrative privileges on your Windows machine the run most of these commands.<br/>

## Troubleshooting

To verify the connection from your emulated machine start a wsl instance, login and run the following command to attempt to ping Google DNS server `ping 8.8.8.8`.<br/>
Let the command run for around 5 seconds then press CTRL+C to stop the execution.

If the command did not return any output or printed an error such as "Probe dropped" or "Connection timeout" then your WSL instance is unable to connect to the internet. See Case 1 for resolution

If you see an error message stating "Host is unreachable" then your network is working but your DNS queries are not being propagated correctly. In this situation check Case 2.

### Case 1: no connectivity

This error is usually caused by a misconfiguration on the Windows machine that is preventing your WSL instance from connecting properly to the web.
Start a new cmd session and as first step type the following command to shutdown any running WSL instances `wsl.exe --shutdown`.

#### Verify the network interface *nix side

in your linux machine execute `ip link eth0`. If the returned status is DOWN execute the following command to activate the interface `ip link eth0 up`.

#### Reset the Windows network configuration

Start a cmd terminal on your Windows machine and execute the following commands

    wsl.exe --shutdown
    
    ipconfig /release
    ipconfig /flushdns
    ipconfig /renew
    netsh winsock reset

Once executed launch a new WSL instance and try to execute the ping command again

### Case 2: DNS failure

On Windows run cmd and execute `ipconfig /all`. Take note of the IP address of the default gateway and the IPv4 (the ones formatted as xxx.xxx.xxx.xxx) address(es) of the known DNS servers returned under the interface you commonly use to connect to the internet (Ethernet or Wi-Fi).

In your WSL instance switch to the root user by running `sudo su` then check if the configuration file wsl.conf exists.
If the file is not present or missing create it by executing the following commands:

    sudo su
    echo "[network]" > /etc/wsl.conf
    echo "generateResolvConf = false" >> /etc/wsl.conf
    
If the file is already present append the following line: `generateResolvConf = false`

Execute the following commands to remove and then create a new DNS server config file where [GATEWAY] is the IP address of the default gateway and [DNS] is the IPv4 address of the DNS server(s) obtained by running `ipconfig /all` on your Windows machine. In case of multiple DNS server addresses you have to create a new row for each value by repeating the command `echo "nameserver [DNS]" >> /etc/resolv.conf`
    
    rm /etc/resolv.conf
    echo "nameserver [GATEWAY]" > /etc/resolv.conf
    echo "nameserver [DNS]" >> /etc/resolv.conf
    echo "nameserver 8.8.8.8" >> /etc/resolv.conf
    echo "nameserver 8.8.4.4" >> /etc/resolv.conf
    chattr +i /etc/resolv.conf

Once the new file is created close your WSL session and run `wsl.exe --shutdown` on your Windows cmd terminal. Start a new WSL session, login and execute `ping 8.8.8.8` you should see the reponses with their TTL times
