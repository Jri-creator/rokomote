#!/bin/bash

# Function to scan network for Roku devices
find_roku_devices() {
    echo "Scanning network for Roku devices..."
    devices=()
    for ip in $(nmap -p 8060 --open -n 192.168.1.0/24 2>/dev/null | grep "Nmap scan report" | awk '{print $NF}'); do
        name=$(curl -s "http://$ip:8060/query/device-info" | grep -oP '(?<=<user-device-name>).*?(?=</user-device-name>)')
        if [[ -z "$name" ]]; then
            name="Unknown Roku at $ip"
        fi
        devices+=("$name|$ip")
    done

    if [[ ${#devices[@]} -eq 0 ]]; then
        echo "No Roku devices found."
        exit 1
    fi

    echo "Found the following Roku devices:"
    for i in "${!devices[@]}"; do
        echo "$((i + 1)). ${devices[i]%%|*}"
    done
}

# Function to send a command to the Roku
send_command() {
    local ip="$1"
    local key="$2"
    curl -s -X POST "http://$ip:8060/keypress/$key" >/dev/null
}

# Function to send text input to the Roku
send_text() {
    local ip="$1"
    local text="$2"
    for ((i = 0; i < ${#text}; i++)); do
        char="${text:$i:1}"
        if [[ "$char" == " " ]]; then
            curl -s -d "" "http://$ip:8060/keypress/Lit_%20" >/dev/null
        else
            curl -s -d "" "http://$ip:8060/keypress/Lit_$char" >/dev/null
        fi
    done
}

# Function to map keypress to Roku commands
key_to_command() {
    case "$1" in
        $'\x1b[A') echo "Up" ;;       # Arrow up
        $'\x1b[B') echo "Down" ;;     # Arrow down
        $'\x1b[C') echo "Right" ;;    # Arrow right
        $'\x1b[D') echo "Left" ;;     # Arrow left
        $'\x7f') echo "Home" ;;       # Backspace key for Home
        '.') echo "Back" ;;           # Period for Back
        ',') echo "Info" ;;           # Comma for Info
        '/') echo "Select" ;;         # Slash for OK
        '-') echo "VolumeDown" ;;     # Volume down
        '=') echo "VolumeUp" ;;       # Volume up
        "'") echo "TEXT_MODE" ;;      # Single quote for text mode
        'p') echo "POWER_MODE" ;;     # Power prompt
        $'\x1b') echo "EXIT" ;;       # Esc key exits
        *) echo "" ;;                 # Invalid key
    esac
}

# Main script execution
find_roku_devices

# Ask user to select a Roku device
read -p "Enter the number of the Roku device to connect to: " choice
if [[ ! "$choice" =~ ^[0-9]+$ ]] || [[ $choice -lt 1 ]] || [[ $choice -gt ${#devices[@]} ]]; then
    echo "Invalid choice."
    exit 1
fi

selected_device="${devices[$((choice - 1))]}"
roku_ip="${selected_device#*|}"

clear

echo "Connected to ${selected_device%%|*} at $roku_ip."
echo "Control instructions:"
echo "  Arrow keys: navigation"
echo "  /: OK (Select)"
echo "  Backspace: Home"
echo "  .: Back"
echo "  -: Volume Down"
echo "  =: Volume Up"
echo "  ': Text mode (type and press Enter)"
echo "  P: Power menu (toggle power state)"
echo "  ,: Info"
echo "  Esc: Exit the script"

# Raw input mode for listening to keypresses
stty -echo -icanon time 0 min 0

trap "stty sane; echo; exit" SIGINT SIGTERM

# Listen for keys and send corresponding commands or text
key_buffer=""
while :; do
    # Read one character at a time
    read -r -n1 key

    # Only process the key if it's non-empty
    if [[ -n "$key" ]]; then
        # Handle multi-character sequences (e.g., arrow keys)
        if [[ "$key" == $'\x1b' ]]; then
            # Possible multi-character sequence
            key_buffer="$key"
            read -r -n1 key
            if [[ "$key" == "[" ]]; then
                key_buffer+="$key"
                read -r -n1 key
                key_buffer+="$key"
            fi
        else
            key_buffer="$key"
        fi

        # Map the key sequence to a Roku command
        command=$(key_to_command "$key_buffer")
        if [[ -n "$command" ]]; then
            if [[ "$command" == "TEXT_MODE" ]]; then
                # Text mode triggered by single quote
                stty echo icanon
                echo -n "Type text to send to Roku: "
                read text
                send_text "$roku_ip" "$text"
                stty -echo -icanon
                # Clear the terminal and show controls again
                clear
                echo "Connected to ${selected_device%%|*} at $roku_ip."
                echo
                echo "Control instructions:"
                echo "  Arrow keys: navigation"
                echo "  /: OK (Select)"
                echo "  .: Back"
                echo "  Backspace: Home"
                echo "  ,: Options"
                echo "  -: Volume Down"
                echo "  =: Volume Up"
                echo "  ': Text mode (type and press Enter)"
                echo "  p: Power mode (prompt)"
                echo "  Esc: Exit the script"
            elif [[ "$command" == "Power" ]]; then
                echo -n "Power off/on device? (y/n): "
                stty echo icanon
                read power_action
                stty -echo -icanon
                if [[ "$power_action" =~ ^[Yy]$ ]]; then
                    send_command "$roku_ip" "Power"
                    echo "Power command sent."
                else
                    echo "Power command canceled."
                fi
            elif [[ "$command" == "EXIT" ]]; then
                echo "Exiting the script. Goodbye!"
                break
            else
                send_command "$roku_ip" "$command"
            fi
        fi

        # Clear the buffer after processing
        key_buffer=""
    fi
done

# Restore terminal to normal mode
stty sane
