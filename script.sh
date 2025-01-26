#!/bin/bash

IPs=()
network_id="10.20"
number_of_teams=10
host_ids=(111 121 131)
admin="wburns"
timeout_duration=1

update_passwords() {
    read -p "Team to update passwords: " team_number
    read -p "Original password: " original_password
    read -p "New password: " new_password

    for IP in "${IPs[@]}"; do
        team_number_from_IP=$(echo "$IP" | cut -d'.' -f3)

        if [[ "$team_number_from_IP" == "$team_number" ]]; then
            echo "Updating passwords for team $team_number on IP: $IP"

            sshpass -p "$orginal_password" ssh -o StrictHostKeyChecking=no -o ConnectTimeout=$timeout_duration "$admin@$IP" "
                echo \"$original_password\" | sudo -S bash -c '
                    for user in \$(cut -d: -f1 /etc/passwd); do
                        echo \"\$user:$new_password\" |  chpasswd 
                        if [[ $? -ne 0 ]]; then
                            echo \"Password failed to updated for user \$user@$IP\"
                        else
                            echo \"Password updated for user \$user@$IP\"
                        fi
                    done
                '
            "
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
        echo "2. Exit"
        read -p "Choose an option: " choice

        case $choice in
            1) update_passwords ;;
            2) break ;;
            *) echo "Invalid choice. Please try again." ;;
        esac
    done
}

main
