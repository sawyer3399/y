#!/bin/bash

IPs=()
network_id="1.1"
number_of_teams=4
host_ids=(1 2 3 4)
admin="admin"
timeout_duration=3

clear_logs() {
    read -p "Team: " team
    read -p "Password: " password

    for IP in "${IPs[@]}"; do
        team_from_IP=$(echo "$IP" | cut -d'.' -f3)
        
        if [[ "$team_from_IP" == "$team" ]]; then
            echo "Trying to SSH @ $IP"
            
            sshpass -p "$password" ssh -o StrictHostKeyChecking=no -o ConnectTimeout=$timeout_duration "$admin@$IP" "
                echo "$password" | sudo -S bash -c '
                    cat /dev/null > /var/log/syslog
                    cat /dev/null > /var/log/auth.log
                    cat /dev/null > /var/log/kern.log
                '

                echo "Logs cleared successfully @ $IP"
            "

            if [[ $? -ne 0 ]]; then
                echo "SSH failed @ $IP"
            fi
        fi
    done
}

update_passwords() {
    read -p "Team number: " team_number
    read -p "Original password: " original_password
    read -p "Password: " password

    for IP in "${IPs[@]}"; do
        team_from_IP=$(echo "$IP" | cut -d'.' -f3)

        if [[ "$team_from_IP" == "$team" ]]; then
            echo "Trying to SSH @ $IP"

            sshpass -p "$original_password" ssh -o StrictHostKeyChecking=no -o ConnectTimeout=$timeout_duration "$admin@$IP" "
                echo "$original_password" | sudo -S rm -f ~/.ssh/authorized_keys

                echo "$original_password" | sudo -S bash -c '
                    for user in $(cut -d: -f1 /etc/passwd); do
                        echo "$user:$password" | chpasswd 
                        
                        if [[ $? -ne 0 ]]; then
                            echo "Password failed to update for $user @ $IP"
                        else
                            echo "Password successfully updated for $user @ $IP"
                        fi
                    done
                '
            "

            if [[ $? -ne 0 ]]; then
                echo "SSH failed @ $IP"
            fi
        fi
    done
}

main() {
    for ((team=1; team<=number_of_teams; team++)); do
        for host_id in "${host_ids[@]}"; do
            IPs+=("$network_id.$team.$host_id")
        done
    done

    while true; do
        echo "DAKOTA CONQUEST DEFENSIVE SCRIPTS"
        echo "1. Update Passwords"
        echo "2. Clear Logs"
        read -p "Choose an option: " choice

        case $choice in
            1) update_passwords ;;
            2) clear_logs ;;
            *) echo "Invalid choice. Please try again." ;;
        esac
    done
}

main
