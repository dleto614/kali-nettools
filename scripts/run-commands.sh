#!/usr/bin/env bash

CERT=""
OUTPUT_FILE=""
ESSID=""
CHANNEL=""
INTERFACE=""
AUTH=""

SHOW_CREDS=false
EXTRACT_HOSTAPD=false
START_DOCKER=false
STOP_DOCKER=false

CONTAINER_FILE=".container_id"
CONTAINER_NAME="kali-nettools"

usage() {
    echo "Usage: $0 [ -c CERT ]
                  [ -o OUTPUT FILE ]
                  [ -e ESSID ]
                  [ -C CHANNEL ]
                  [ -i INTERFACE ]
                  [ -a AUTH ]
				  [ --start-docker START DOCKER CONTAINER ]
				  [ --stop-docker STOP DOCKER CONTAINER ]
                  [ --creds SHOW CREDENTIALS ]
                  [ --extract-hostapd EXTRACT EAP FROM EAPHAMMER HOSTAPD LOG ]
                  [ -h HELP ]" 1>&2
}

exit_error() {
    usage
    echo "-------------"
    echo "Exiting!"
    exit 1
}

# Manual argument parsing
while [[ $# -gt 0 ]]; do
    case "$1" in
        -c)
            CERT="$2"
            shift 2
            ;;
        -o)
            OUTPUT_FILE="$2"
            shift 2
            ;;
        -e)
            ESSID="$2"
            shift 2
            ;;
        -C)
            CHANNEL="$2"
            shift 2
            ;;
        -i)
            INTERFACE="$2"
            shift 2
            ;;
        -a)
            AUTH="$2"
            shift 2
            ;;
		--start-docker)
			START_DOCKER=true
			shift
			;;
		--stop-docker)
			STOP_DOCKER=true
			shift
			;;
        --creds)
            SHOW_CREDS=true
            shift
            ;;
        --extract-hostapd)
            EXTRACT_HOSTAPD=true
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit_error
            ;;
    esac
done

# Start Docker container
start_container() {

	if [[ -f "$CONTAINER_FILE" ]]
    then
        CONTAINER_ID=$(cat "$CONTAINER_FILE")
        RUNNING=$(sudo docker ps -q -f id="$CONTAINER_ID")

        if [[ -n "$RUNNING" ]]
        then
            echo "[*] Using existing container: $CONTAINER_ID"
        else
            echo "[*] Previous container not running."
            rm "$CONTAINER_FILE"
            CONTAINER_ID=""
        fi
    fi

    if [[ -z "$CONTAINER_ID" ]]
    then
        echo "[*] Starting Docker container..."
        CONTAINER_ID=$(sudo docker run -d -it \
            --net=host \
            --privileged \
            -v "$(pwd)/certs/generated:/certs" \
            -v "$(pwd)/logs:/opt/eaphammer/logs" \
            kali-nettools)

        echo "$CONTAINER_ID" > "$CONTAINER_FILE"
        echo "[*] Docker started with ID: $CONTAINER_ID"
    fi
}

# Stop Docker container
stop_docker() {
	
	echo "[*] Stopping Docker container..."

	if [[ -f "$CONTAINER_FILE" ]]
	then
    	CONTAINER_ID=$(cat "$CONTAINER_FILE")
    	sudo docker stop "$CONTAINER_ID"
    	sudo docker rm "$CONTAINER_ID"
    	rm "$CONTAINER_FILE"
	fi

    echo "[*] Done. You can check if the container is still running with: sudo docker ps."

}

# Start Docker container if requested
if [[ "$START_DOCKER" == true ]]
then
    start_container
fi

# Stop Docker container if requested
if [[ "$STOP_DOCKER" == true ]]
then
	stop_docker
fi

# If cert is set, import it using Eaphammer's import command.
if [[ -n "$CERT" ]]
then
	echo "[*] Checking if Docker container is running..."
	start_container

	CERT_ABS=$(realpath "$CERT")
    CERT_FILE=$( realpath --relative-to="$(pwd)/certs/generated" "$CERT_ABS")

	# Run Eaphammer inside container using mounted path
	sudo docker exec -it "$CONTAINER_ID" ./eaphammer/eaphammer \
		--cert-wizard import \
		--server-cert /certs/"$CERT_FILE"

	echo "[*] Done"
fi

# Check if we need to show credentials.
if [[ "$SHOW_CREDS" == true && -n "$ESSID" && -n "$CHANNEL" && -n "$INTERFACE" && -n "$AUTH" ]]
then
	echo "[*] Checking if Docker container is running..."
	start_container

	sudo docker exec -it "$CONTAINER_ID" ./eaphammer/eaphammer \
		--essid "$ESSID" \
		--channel "$CHANNEL" \
		--interface "$INTERFACE" \
		--auth "$AUTH" \
		--creds

# Check if creds was not set.
elif [[ -n "$ESSID" && -n "$CHANNEL" && -n "$INTERFACE" && -n "$AUTH" ]]
then
	echo "[*] Checking if Docker container is running..."
	start_container

	sudo docker exec -it "$CONTAINER_ID" ./eaphammer/eaphammer \
		--essid "$ESSID" \
		--channel "$CHANNEL" \
		--interface "$INTERFACE" \
		--auth "$AUTH"
fi

# Check if we need to extract EAP and output is set.
if [[ "$EXTRACT_HOSTAPD" == true && -n "$OUTPUT_FILE" ]]
then
    LOGFILE="./logs/hostapd-eaphammer.log"

    if [[ -f "$LOGFILE" ]]
    then
        echo "[*] Extracting from hostapd log"

        ./scripts/log-to-json.sh \
            --extract-hostapd \
            --output "$OUTPUT_FILE" \
            -l "$LOGFILE"

        echo "[*] Done"
    fi
fi
