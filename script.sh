#!/bin/bash

IPs=()
network_id="10.10"
number_of_teams=10
host_ids=(10 20 30 40 50)
admin="admin1"
default_password="Password1!"
timeout_duration=1

update_passwords() {
    read -p "Team to update passwords: " team_number
    read -p "New password to set: " new_password

    for IP in "${IPs[@]}"; do
        team_number_from_IP=$(echo "$IP" | cut -d'.' -f3)

        if [[ "$team_number_from_IP" == "$team_number" ]]; then
            echo "Updating passwords for team $team_number on IP: $IP"

            sshpass -p "$default_password" ssh -o StrictHostKeyChecking=no -o ConnectTimeout=$timeout_duration "$admin@$IP" "
                echo \"$default_password\" | sudo -S bash -c '
                    for user in \$(cut -d: -f1 /etc/passwd); do
                        echo \"$user:$new_password\" | sudo -S chpasswd
                    done
                '
            "
        fi
    done
}


main() {
    # Populate the IP list
    for ((team=1; team<=number_of_teams; team++)); do
        for host_id in "${host_ids[@]}"; do
            IPs+=("$network_id.$team.$host_id")
        done
    done

    # Menu loop
    while true; do
        echo "DAKOTA CONQUEST SCRIPTS"
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
