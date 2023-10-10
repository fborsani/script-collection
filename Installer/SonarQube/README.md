# SonarQube install scripts
this folder contains the scrpts used to configure and install the SonarQube server instance and the client setup to perform local scans. <br>
SonarQube is configured to work with OWASP dependency check to include external libraries in the vulnerability assessment
## Client 
The powershell script included in this folder cnfigures the local scanner and OWASP depency check tool by performing the following steps:
* Download the local scanner for Windows
* Download OWASP dependency check CLI tool
* Download and install NodeJS to allow support for JavaScript code analysis
* Download and install a JDK >= 8 to be used to run OWASP dependency check
* Create a configuration file to be used by the ant file <br>
The user will then include the .ant file in the project deploy procedure to start the scan
## Server
The install script downloads the docker image for SonarQube and the required database (postgres 9). <br>
After installing and configuring both containers the script downloads the following plugins for the server: Google Login, Groovy code analysis, plain-tesxt analysis plugin for extra rules and support for OWASP dependency check generated reports. <br>
Newer versions of SonarQube are not compatible with certain Docker security rules. To fix this problem the docker run command sets the file seccomp-profile.json as security option
