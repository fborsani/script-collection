#!/bin/bash

pyver="3.11"
sslver="1.1.1g"

if [[ $UID != 0 ]]; then
	echo "root privileges required. Insert password..."
	sudo "$0" "$@"
fi

apt install wget build-essential libreadline-dev libncursesw5-dev libssl-dev libsqlite3-dev tk-dev libgdbm-dev libc6-dev libbz2-dev libffi-dev zlib1g-dev

wget https://www.openssl.org/source/openssl-${sslver}.tar.gz --no-check-certificate
tar -zxvf openssl-${sslver}.tar.gz
cd openssl-${sslver}
./config --prefix=/opt/openssl --openssldir=/opt/openssl
make && make install
export LD_LIBRARY_PATH=/opt/openssl/lib:$LD_LIBRARY_PATH
export PATH=/opt/openssl/bin:$PATH
cd /tmp
wget -c https://www.python.org/ftp/python/${pyver}.0/Python-${pyver}.0.tar.xz
tar -Jxf Python-${pyver}.0.tar.xz
cd Python-${pyver}.0/
./configure --enable-optimizations --enable-shared --with-openssl=/opt/openssl
make -j4 && make altinstall
python${pyver} -m pip install --upgrade pip
wget https://sh.rustup.rs -O rust.sh
chmod 770 ./rust.sh
./rust.sh
source "{$HOME}*.cargo/env"