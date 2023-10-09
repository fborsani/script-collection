if [[ $UID != 0 ]]; then
	echo "root privileges required. Insert password..."
	sudo "$0" "$@"
fi

apt update && apt upgrade -y
apt install software-properties-common -y
add-apt-repository ppa:deadsnakes/ppa
apt install python3.10