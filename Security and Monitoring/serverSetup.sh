#!/bin/bash

port=514
server_conf_file='60-custom'
logorotate_conf_file="syslog-remote-hosts"
facility="6"
logs_folder="/var/log/remote-hosts"

#----LOGROTATE----
copies=10    	#keep the last n backups
max_size="20M"  #create a backup after the file reaches this size (can use K,M,G as size units)
freq="h"        #h -> hourly d -> daily w -> weekly m -> monthly

function error(){
    echo "[-] ERROR: $1"
    exit 1
}

if [ $EUID -ne 0 ]; then
    error "This script must be executed with elevated privileges"
fi

apt update && apt install rsyslog auditd
systemctl stop syslog.socket rsyslog.service

filepath="/etc/rsyslog.d/${server_conf_file}.conf"
echo "\$ModLoad imjournal" | tee "$filepath" > /dev/null
echo "\$imjournalRatelimitInterval 0" | tee -a "$filepath" > /dev/null
echo "\$imjournalRatelimitBurst 0" | tee -a "$filepath" > /dev/null
echo "\$ModLoad imtcp" | tee -a "$filepath" > /dev/null
echo "input(type=\"imtcp\" port=\"${port}\")" | tee -a "$filepath" > /dev/null
echo "\$template tmpAuth, \"${logs_folder}/%HOSTNAME%/auth.log\"" | tee -a "$filepath" > /dev/null
echo "\$template tmpKern, \"${logs_folder}/%HOSTNAME%/kernel.log\"" | tee -a "$filepath" > /dev/null
echo "\$template tmpAudit, \"${logs_folder}/%HOSTNAME%/audit.log\"" | tee -a "$filepath" > /dev/null
echo "\$template tmpCron, \"${logs_folder}/%HOSTNAME%/cron.log\"" | tee -a "$filepath" > /dev/null
echo "\$template tmpUser, \"${logs_folder}/%HOSTNAME%/user.log\"" | tee -a "$filepath" > /dev/null
echo "\$template tmpGeneric, \"/var/log/remote-hosts/%HOSTNAME%/%PROGRAMNAME%.log\"" | tee -a "$filepath" > /dev/null
echo "auth,authpriv.* ?tmpAuth" | tee -a "$filepath" > /dev/null
echo "local${facility},syslog.* ?tmpAudit" | tee -a "$filepath" > /dev/null
echo "user.info ?tmpUser" | tee -a "$filepath" > /dev/null
echo "kern.err ?tmpKern" | tee -a "$filepath" > /dev/null
echo "cron.* ?tmpCron" | tee -a "$filepath" > /dev/null
echo "& stop" | tee -a "$filepath" > /dev/null

filepath="/etc/logrotate.d/${logorotate_conf_file}"
echo "${logs_folder}/*/*.log {" | tee "$filepath" > /dev/null
echo "        rotate ${copies}" | tee -a "$filepath" > /dev/null
echo "        size ${max_size}" | tee -a "$filepath" > /dev/null
echo "        missingok" | tee -a "$filepath" > /dev/null
echo "        compress" | tee -a "$filepath" > /dev/null
echo "        delaycompress" | tee -a "$filepath" > /dev/null
echo "        copytruncate" | tee -a "$filepath" > /dev/null
echo "}" | tee -a "$filepath" > /dev/null

cron_logrotate_position=$(find /etc/cron.*/ -type f -name logrotate)

case "$freq" in
  "h") cron_dest="/etc/cron.hourly" ;;
  "w") cron_dest="/etc/cron.weekly" ;;
  "m") cron_dest="/etc/cron.monthly" ;;
    *) cron_dest="/etc/cron.daily" ;;
esac

mv "$cron_logrotate_position" "$cron_dest" > /dev/null
  

systemctl start syslog.socket rsyslog.service logrotate
systemctl restart cron

echo "[+] Done!"