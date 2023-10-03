#!/bin/bash

PING=1
UDP=0
TCP=0
VERBOSE=0
TIMEOUT=1

DOMAIN="192.168.0"
IPS="1-254"
PORTS="1-65535"

IPLIST=()
PORTLIST=()

createArrayIP () {
	case "$2" in
	*'-'*)
		low=$(echo "$2" | awk -F '-' {'print $1'})
		high=$(echo "$2" | awk -F '-' {'print $2'})
		for i in $(seq $low $high);do
			IPLIST+=("${1}.${i}")
		done
        	;;
	*','*)
		IFS=', ' read -r -a tmp <<< "$2"
		for ip in "${tmp[@]}"; do
			IPLIST+=("${1}.${ip}")
		done
		;;
	*)
		IPLIST+=("${1}.${2}")		
	esac
}

createArrayPort () {
	case "$1" in
	*'-'*)
		low=$(echo "$1" |awk -F '-' {'print $1'})
		high=$(echo "$1" |awk -F '-' {'print $2'})
		for i in $(seq $low $high);do
			PORTLIST+=("$i")
		done
        	;;
	*','*)
		IFS=', ' read -r -a tmp <<< "$1"
		PORTLIST+=("${tmp[@]}")
		;;
	*)
		PORTLIST+=("$1")		
	esac
}

pingSweep () {
	ipList=""
	for ip in "${IPLIST[@]}"; do
		host=$(ping -c 1 -W $TIMEOUT $ip | grep "bytes from" | cut -d " " -f 4 | cut -d ":" -f1)
		if [ "$host" != "" ]; then
			ipList="${ipList} ${ip}"
			echo "Host ${ip} is UP"
		else
			echo "Host ${ip} is DOWN"
		fi
	done
	IFS=', ' read -r -a tmp <<< "$ipList"
	IPLIST=("${tmp[@]}")
}

portSweep () {
	for port in "${PORTLIST[@]}"; do
		if [ $TCP == 1 ]; then
			if [ $VERBOSE == 0 ]; then
				nc -nvz -w $TIMEOUT "$1" $port 2>&1 | grep open | awk -F " " {'print "tcp: ",$3,$4'}
			else 
				nc -nvz -w $TIMEOUT "$1" $port
			fi
		fi
		if [ $UDP == 1 ]; then
			if [ $VERBOSE == 0 ]; then
				nc -nvzu -w $TIMEOUT "$1" $port 2>&1 | grep open | awk -F " " {'print "udp: ",$3,$4'}
			else 
				nc -nvzu -w $TIMEOUT "$1" $port
			fi
		fi		
	done
}

trap "exit" INT

while getopts "tuPvw:d:h:p:" option; do
	case $option in
	t)
		TCP=1
		;;
	u)
		UDP=1
		;;
	P)
		PING=0
		;;
	v)
		VERBOSE=1
		;;
	w)	
		TIMEOUT="${OPTARG}"
		;;
	d)	
		DOMAIN="${OPTARG}"
		;;
	h)	
		IPS="${OPTARG}"
		;;
	p)	
		PORTS="${OPTARG}"
		;;
	*)
        	echo "Incorrect options provided"
        	exit 1
        	;;
    esac
done

createArrayIP $DOMAIN $IPS
createArrayPort $PORTS


if [ $TCP == 0 ] && [ $UDP == 0 ] && [ $PING == 0 ]; then
	echo "No operations specified, use at least one option: -u -t -P"
	exit 0
fi

if [ $PING == 1 ]; then
	pingSweep
fi

if [ $TCP == 1 ] || [ $UDP == 1 ]; then 
	command -v nc >/dev/null 2>&1 || { echo >&2 "ERROR: Unable to find NetCat"; exit 1; }

	for host in "${IPLIST[@]}"; do
		echo "Host: $host"
		portSweep "$host"
	done
fi
