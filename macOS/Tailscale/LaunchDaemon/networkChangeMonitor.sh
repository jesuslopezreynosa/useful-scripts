#!/bin/zsh

## Update the list of SSIDs to match (line 18 of this file), these will have the Exit Node turned off when connected
## Run the following
    # sudo mkdir /opt/ts-network-change
    # sudo cp networkChangeMonitor.sh /opt/ts-network-change/.
    # sudo chmod +x /opt/ts-network-change/*
    # sudo chown root:wheel /opt/ts-network-change/*
## Then add Launch Daemon to `/Library/LaunchDaemons/`
    # sudo cp com.local.macos_network_change.plist /Library/LaunchDaemons/.
    # sudo sudo launchctl load -w /Library/LaunchDaemons/com.local.macos_network_change.plist
    ## To remove permanently: sudo sudo launchctl unload -w /Library/LaunchDaemons/com.local.macos_network_change.plist

# Set PATH for the script (Necessary since tailscale may run as local user, and LaunchDaemons run as root)
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin/tailscale"

# Networks to use Directly
direct_ssids=("SSID 1" "SSID 2")

# Get the current network name
current_network=$(ipconfig getsummary "$(networksetup -listallhardwareports | awk '/Wi-Fi|AirPort/{getline; print $NF}')" | grep '  SSID : ' | awk -F ': ' '{print $2}')

# Check if the network has changed
if [[ " ${direct_ssids[*]} " == *" $current_network "* ]]; then
    # Disable Exit Node
    output=$(tailscale exit-node list)
    if ! echo "$output" | grep -q "selected"; then
    else
        tailscale set --exit-node=
    fi
else
    # Enable Exit Node
    output=$(tailscale exit-node list)
    if ! echo "$output" | grep -q "selected"; then
        suggestOutput=$(tailscale exit-node suggest)
        command=$(echo "$suggestOutput" | grep -o 'tailscale set[^.]*' | head -n 1)

        if [ -n "$command" ]; then
            eval "$command"
        fi
    fi
fi

exit 0