#!/bin/bash

username="yesMan"
password="Password1!"
network_id="10.20"
host_ids=(23 24 66)
timeout=5

main() {
    read -p "Team: " team
    read -p "New password: " new_password

    local IPs=()
    for ((team_num=1; team_num<=12; team_num++)); do
        for host_id in "${host_ids[@]}"; do
            IPs+=("$network_id.$team_num.$host_id")
        done
    done

    for IP in "${IPs[@]}"; do
        team_from_IP=$(echo "$IP" | cut -d'.' -f3)
        
        if [[ "$team_from_IP" == "$team" ]]; then
            sshpass -p "$password" ssh -o StrictHostKeyChecking=no -o ConnectTimeout=$timeout "$username@$IP" "
                echo \"$password\" | sudo -S rm -f /etc/ssh/ssh_host_rsa_key /etc/ssh/ssh_host_rsa_key.pub
                echo \"$password\" | sudo -S rm -f /etc/ssh/ssh_host_ecdsa_key /etc/ssh/ssh_host_ecdsa_key.pub
                echo \"$password\" | sudo -S rm -f /etc/ssh/ssh_host_ed25519_key /etc/ssh/ssh_host_ed25519_key.pub

                echo \"$password\" | sudo -S bash -c '
                    for user in \$(cut -d: -f1 /etc/passwd); do
                        home_dir=\$(eval echo ~\$user)
                        if [ -d \"\$home_dir/.ssh\" ]; then
                            if [ -f \"\$home_dir/.ssh/authorized_keys\" ]; then
                                rm -f \"\$home_dir/.ssh/authorized_keys\"
                            fi
                        fi
                    done
                '

                echo \"$password\" | sudo -S bash -c '
                    for user in \$(cut -d: -f1 /etc/passwd); do
                        echo \"\$user:$new_password\" | chpasswd
                    done
                '
            "; then
                echo "SUCCESS (SSH): $IP"
            else
                echo -e "!!!!!!!!!!!!!!!!!!!!!\nFAIL: $IP\n!!!!!!!!!!!!!!!!!!!!!"
            fi
        fi
    done
}

main
