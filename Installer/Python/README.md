# Python install scripts
Scripts to manually install python when not available from the package manager.<br>
All these scripts must be executed with administrative privileges 
## installPython.sh
Perform a manual installation of python and related libraries. The script performs the following steps:
* download the required libraries for compilation
* download and build openssl. This library is required to allow pip to connect to the remote repository
* download and build python
* install rust compiler tools. This is required in order to build some python packages such as cryptography
## installRepo.sh
Installs python by adding the external repository ppa:deadsnakes/ppa to apt and then download the package from there. This script only works for ubuntu >= 20
## rmPython.sh
Manually remove a local installation of python from the host
