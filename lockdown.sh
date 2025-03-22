#!/bin/bash

username="yesMan"
password="Password1!"

network_id="10.20"
host_ids=(23 24 66)

timeout=5

main() {
    read -p "My Team: " my_team
    read -p "New Password: " new_password
    local IPs=()
    for ((team=1; team<=12; team++)); do
        for host_id in "${host_ids[@]}"; do
            IPs+=("$network_id.$team.$host_id")
        done
    done
    for IP in "${IPs[@]}"; do
        team_from_IP=$(echo "$IP" | cut -d'.' -f3)
        if [[ "$team_from_IP" == "$my_team" ]]; then
            sshpass -p "$password" ssh -o StrictHostKeyChecking=no -o ConnectTimeout=$timeout "$username@$IP" "
                echo \"$password\" | sudo -S echo \"PubkeyAuthentication no\" >> /etc/ssh/sshd_config
                echo \"$password\" | sudo -S echo \"PasswordAuthentication yes\" >> /etc/ssh/sshd_config
                echo \"$password\" | sudo -S bash -c '
                    for user in \$(cut -d: -f1 /etc/passwd); do
                        echo \"\$user:$new_password\" | chpasswd
                    done
                '
                echo \"$new_password\" | sudo -S apt reinstall libpam-modules
                echo \"$new_password\" | sudo -S systemctl restart sshd
            "; then
                echo "SUCCESS (SSH Config): $IP"
            else
                echo -e "!!!!!!!!!!!!!!!!!!!!!\nFAIL: $IP\n!!!!!!!!!!!!!!!!!!!!!"
            fi
        fi
    done
}

main
