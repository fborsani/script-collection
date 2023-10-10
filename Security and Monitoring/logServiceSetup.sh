auditd_conf_file="50-ansible"
rsyslog_conf_file="40-ansible"

log_burst=600
log_burst_time=5

log_service_addr="10.0.0.2"
log_service_port="514"
log_local_facility="6"

if [ $EUID -ne 0 ]; then
  echo "[-] This script must be executed with elevated privileges"
fi

echo "[*] Configuring logging tools..."
apt update
apt install auditd audispd-plugins rsyslog -y

auditd_conf_path="/etc/audit/rules.d/${auditd_conf_file}.rules"
echo "-a exit,always -F arch=b64 -S execve -k auditcmd" | tee "$auditd_conf_path" > /dev/null
echo "-a exit,always -F arch=b32 -S execve -k auditcmd" | tee -a "$auditd_conf_path" > /dev/null
echo "-a exclude,always -F msgtype=NETFILTER_CFG" | tee -a "$auditd_conf_path" > /dev/null
echo "-a exclude,always -F msgtype=ANOM_PROMISCUOUS" | tee -a "$auditd_conf_path" > /dev/null
echo "-a exclude,always -F msgtype=CWD" | tee -a "$auditd_conf_path" > /dev/null
echo "-a exclude,always -F msgtype=PROCTITLE" | tee -a "$auditd_conf_path" > /dev/null
echo "-a exclude,always -F msgtype=PATH" | tee -a "$auditd_conf_path" > /dev/null
echo "-a exclude,always -F auid=4294967295" | tee -a "$auditd_conf_path" > /dev/null

if [ -n "$log_service_addr" ]; then 

    file_audit_plugin="/etc/audisp/plugins.d/syslog.conf"
    echo "active = yes" | tee "$file_audit_plugin" > /dev/null
    echo "direction = out" | tee -a "$file_audit_plugin" > /dev/null
    echo "path = builtin_syslog" | tee -a "$file_audit_plugin" > /dev/null
    echo "type = builtin" | tee -a "$file_audit_plugin" > /dev/null
    echo "args = LOG_LOCAL${log_local_facility}" | tee -a "$file_audit_plugin" > /dev/null
    echo "format = string" | tee -a "$file_audit_plugin" > /dev/null

    file_rsyslog_conf="/etc/rsyslog.d/${rsyslog_conf_file}.conf"
    echo "\$SystemLogRateLimitInterval ${log_burst_interval}" | tee "$file_rsyslog_conf" > /dev/null
    echo "\$SystemLogRateLimitBurst ${log_burst}" | tee -a "$file_rsyslog_conf" > /dev/null
    echo ":programname, contains, \"networkd\" stop" | tee -a "$file_rsyslog_conf" > /dev/null
    echo ":programname, isequal, \"containerd\" stop" | tee -a "$file_rsyslog_conf" > /dev/null
    echo ":programname, isequal, \"dockerd\" stop" | tee -a "$file_rsyslog_conf" > /dev/null
    echo "*.*;news.none;mail.none @@${log_service_addr}:${log_service_port}" | tee -a "$file_rsyslog_conf" > /dev/null

else 
    echo "[*] Remote log server IP not defined. Configuration skipped"
fi

rm /etc/audit/audit.rules > /dev/null
auditctl -D
augenrules
service rsyslog restart
service auditd restart

echo "[+] Done"