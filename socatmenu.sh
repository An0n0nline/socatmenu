#!/bin/bash
clear
echo
echo "========================"
echo "SOCAT MENU SYSTEM"
echo "========================"
echo "(1) Forward TCP port"
echo "(2) Create a TCP listener"
echo "(3) Forward UDP port"
echo "(4) Create a TCP proxy to forward traffic to another host"
echo "(5) Create a TCP listener that executes a command"
echo "(6) Create a TCP client that sends data to a server"
echo "(7) Create a UDP listener that echoes received data"
echo "(8) Create a TCP listener that logs received data to a file"
echo "(9) Create a TCP client that reads data from a file and sends it to a server"
echo "(10) Listen on specified port"
echo "(11) Connect to remote host"
echo "(12) Connect to remote port"
echo "(13) Reverse proxy"
echo "(14) Encrypt connections with specified encryption"
echo "(15) Create a tunnel to the specified host and port"
echo "(16) Forward connections to the specified host and port"
echo "(17) Increase verbosity of output"
echo "(18) Exit"
echo

read -p "ENTER SELECTION: " SELECTION

# helper function for reading ports and hosts
get_ports_hosts() {
    read -p "Enter local port: " LOCAL_PORT
    read -p "Enter remote host: " REMOTE_HOST
    read -p "Enter remote port: " REMOTE_PORT
}

# helper function for generic command input
get_command() {
    read -p "Enter command to execute: " COMMAND
}

case $SELECTION in
1)
    get_ports_hosts
    sudo socat TCP-LISTEN:$LOCAL_PORT,fork TCP:$REMOTE_HOST:$REMOTE_PORT
    ;;
2|10)
    read -p "Enter port to listen on: " LISTEN_PORT
    sudo socat TCP-LISTEN:$LISTEN_PORT,fork EXEC:/bin/cat
    ;;
3|7)
    read -p "Enter UDP port to listen on: " UDP_PORT
    read -p "Enter remote UDP host (optional, leave blank for echo): " REMOTE_HOST
    read -p "Enter remote UDP port (optional, leave blank for echo): " REMOTE_PORT
    if [ -z "$REMOTE_HOST" ] || [ -z "$REMOTE_PORT" ]; then
        sudo socat UDP-LISTEN:$UDP_PORT,fork EXEC:/bin/cat
    else
        sudo socat UDP-LISTEN:$UDP_PORT,fork UDP:$REMOTE_HOST:$REMOTE_PORT
    fi
    ;;
4|13|16)
    get_ports_hosts
    sudo socat TCP-LISTEN:$LOCAL_PORT,fork TCP:$REMOTE_HOST:$REMOTE_PORT
    ;;
5)
    read -p "Enter port to listen on: " LISTEN_PORT
    get_command
    sudo socat TCP-LISTEN:$LISTEN_PORT,fork SYSTEM:"$COMMAND"
    ;;
6)
    read -p "Enter server IP: " SERVER_IP
    read -p "Enter server port: " SERVER_PORT
    read -p "Enter data to send: " DATA
    echo "$DATA" | sudo socat - TCP:$SERVER_IP:$SERVER_PORT
    ;;
8)
    read -p "Enter port to listen on: " LISTEN_PORT
    read -p "Enter log file path: " LOG_FILE
    sudo socat TCP-LISTEN:$LISTEN_PORT,fork SYSTEM:"cat > $LOG_FILE"
    ;;
9)
    read -p "Enter server IP: " SERVER_IP
    read -p "Enter server port: " SERVER_PORT
    read -p "Enter file path to read from: " FILE_PATH
    sudo socat -u FILE:$FILE_PATH TCP:$SERVER_IP:$SERVER_PORT
    ;;
11)
    read -p "Enter remote host: " REMOTE_HOST
    read -p "Enter remote port: " REMOTE_PORT
    sudo socat TCP:$REMOTE_HOST:$REMOTE_PORT -
    ;;
12)
    read -p "Enter remote port: " REMOTE_PORT
    sudo socat TCP:localhost:$REMOTE_PORT -
    ;;
14)
    read -p "Enter encryption method (e.g., OPENSSL): " ENCRYPTION_METHOD
    get_ports_hosts
    sudo socat $ENCRYPTION_METHOD-LISTEN:$LOCAL_PORT,fork $ENCRYPTION_METHOD:$REMOTE_HOST:$REMOTE_PORT
    ;;
15)
    get_ports_hosts
    sudo socat TCP-LISTEN:$LOCAL_PORT,fork PROXY:localhost:$REMOTE_PORT,proxyport=$REMOTE_PORT
    ;;
17)
    read -p "Enter the socat command to run with verbosity: " SOCAT_COMMAND
    sudo socat -d -d $SOCAT_COMMAND
    ;;
18)
    echo "Exiting..."
    exit 0
    ;;
*)
    echo "Invalid selection"
    ;;
esac

read -p "WOULD YOU LIKE TO RETURN TO THE MENU? (y/n): " ANSWER
if [ "$ANSWER" = y ]; then
    sudo sh socatmenu.sh
fi
