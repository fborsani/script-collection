#!/bin/bash

file_path=$2
entry_delimiter=":"
managed_group="managed"
default_shell="/bin/bash"

function install_pubkey(){
  local user="$1"
  local pubkey="$2"
  if [ -n "$pubkey" ]; then 
    usermod -aG "$managed_group" "$user"
    mkdir -p "/home/$user/.ssh"
    touch "/home/$user/.ssh/authorized_keys"
    echo "$pubkey" >> "/home/$user/.ssh/authorized_keys"
    
    chown -R "$user":"$user" "/home/$user/.ssh/authorized_keys"
    chmod 600 "/home/$user/.ssh/authorized_keys"
    chmod 700 "/home/$user/.ssh"
  fi
}

function config_users():
    echo "[*] Cleaning up users"
    current_ansible_users=$(grep ^ansible: /etc/group | awk '{split($a0,out,":"); print out[4]}')
    IFS=',' read -r -a ansible_user_array <<< "$current_ansible_users"
    for user in "${ansible_user_array[@]}"
    do
    if [[ "$user" != "$ansible_user" && "$user" != "$(whoami)" ]]; 
    then
        userdel "$user"
        rm -rf "/home/${user:?}"
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
        groups="$managed_group"
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
    echo "[-] This script must be executed with elevated privileges"
fi

if [ ! -f "$file_path" ]; then
    echo "configure users. Requires a file with usernames, public keys and permissions separated by a ${entry_delimiter}."
    echo "Example row: USERNAME${entry_delimiter}PKEY${entry_delimiter}<admin|docker|limited>"
    echo "All users are assigned to the group $managed_group. All users missing from the file excluding the one running the script"
    echo "and users not part of the group $managed_group will be removed."
    echo "The allowed permissions are:"
    echo "  -admin: full access and sudo privileges"
    echo "  -docker: can execute docker commands (i.e. create an image, run a new container or log into the container"
    echo "  -limited: default user permissions"
fi

create_users


