# Security and Monitoring
The scripts in this folder are used to setup access control, monitoring and accountability facilities on the standard Ubuntu machines used on AWS EC2.

## setUsers.sh
Configures the users allowed to access the machine via ssh and assigns groups and permissions. The script parses a txt file containing a list of users where each represents a tuple containing username, public key and role (admin, docker or limited).
For each user the script creates a new user and home folder and configures the ssh service to accept the provided public key.
There are three levels of permissions that can be granted to a user:
* admin: the user is added to the sudo and docker group. Full administrative access to the machine
* docker: the user is added to the docker group. The user is able to manage docker instances and images
* limited: standard low level user with no special privileges

## logServiceSetup.sh
This script installs and configures auditd to keep track of all commands executed by the user and configures the rsyslog client service to transmit both the standard ubuntu logs and the auditd logs to the remote log aggregator server

## logAggregatorSetup.sh
This script configures the syslog server and logrotate service to receive and manage incoming logs from remote hosts. The logs are stored by default in /var/log/remote-hosts/<hostname> separated in the following categories:
kernel warnings and errors, auth events, auditd command exeuction, cron execution, syslog client events. The logrotate service is configured to compress each host folder every week and to create a new log file once the original file reaches 20MB in size.
