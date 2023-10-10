#!/usr/bin/bash

file_path=$2
entry_delimiter=":"
ansible_group="ansible"
#-----USER CONFIG-----
ansible_user="ansible-user"
ansible_group="ansible"
ansible_home="/home/$ansible_user"
default_shell="/usr/bin/bash"

#-----KEYS CONFIG----
host_public_key=""
ansible_users_key_storage="/etc/ssh/keys-ansible"

#-----FILES CONFIG-----
ssh_conf_file="ansible-ssh"
sudo_conf_file="ansible-users"

function error(){
  echo "[-] ERROR: $1"
  exit 1
}

function install_pubkey(){
  local user="$1"
  local pubkey="$2"
  if [ -n "$pubkey" ]; then 
    usermod -aG "$ansible_group" "$user"
    mkdir -p "$ansible_users_key_storage/$user/"
    touch "$ansible_users_key_storage/$user/authorized_keys"
    echo "$pubkey" >> "$ansible_users_key_storage/$user/authorized_keys"
    
    chown -R "$user":"$user" "$ansible_users_key_storage"/"$user"
    chmod 700 "$ansible_users_key_storage/$user/"
    chmod 600 "$ansible_users_key_storage/$user/authorized_keys"
  fi
}

function create_users(){
  if [ ! -f "$file_path" ]; then
    error "File not found"
  fi
  
  echo "[*] Cleaning up users"
  current_ansible_users=$(grep ^ansible: /etc/group | awk '{split($a0,out,":"); print out[4]}')
  IFS=',' read -r -a ansible_user_array <<< "$current_ansible_users"
  for user in "${ansible_user_array[@]}"
  do
    if [[ "$user" != "$ansible_user" && "$user" != "$(whoami)" ]]; 
    then
        userdel "$user"
        rm -rf "${ansible_users_key_storage:?}/${user:?}"
        echo "[+] Removed user $user"
    fi
  done

  echo "[*] Creating users"
  while IFS="" read -r part || [ -n "$part" ]
  do
    IFS="$entry_delimiter" read -r -a rowData <<< "$part"
    user=${rowData[0]}
    pubkey=${rowData[1]}
    user_type=${rowData[2]}
    
    if [[ -n $user &&  -n $pubkey ]];
    then 
      groups="$ansible_group"
      case "$user_type" in
        "admin")
          groups="${groups},docker,sudo"
        ;;
        "docker")
          groups="${groups},docker"
        ;;
        *)
        ;;
      esac
      
      useradd -G "$groups" -m "$user"
      usermod --shell "$default_shell"  "$user"
      install_pubkey "$user" "$pubkey"
      
      echo "[+] Created user $user with $user_type privileges and public key $pubkey"
    else
      echo "[-] Row $part is invalid. Skipped"
    fi
    
  done < "$file_path"
  
  echo "[+] All users created"
}

if [ $EUID -ne 0 ]; then
  error "This script must be executed with elevated privileges"
fi

case $1 in
  "all")
    configure
    create_users
  ;;
  "config")
    configure
  ;;
  "user")
    create_users
  ;;
  *)
    echo "Usage: $0 <all|config|user> [filename]"
    echo "Arguments:"
    echo "    -config: run system setup (create groups, sudo and ssh policies) this should be run only once"
    echo "    -user: configure users. Requires a file with usernames, public keys and permissions separated by a ${entry_delimiter}."
    echo "           The allowed permissions are:"
    echo "               -admin: full access and sudo privileges"
    echo "               -docker: can execute docker commands (i.e. create an image, run a new container or log into the container"
    echo "               -limited: can only access the ansible home folder"
    echo "           Example row: USERNAME${entry_delimiter}PKEY${entry_delimiter}<admin|docker|limited>"
    echo "    -all: perform a full installation. Same requirements as user"
    exit 1
  ;;
esac
