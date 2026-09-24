#!/bin/zsh

export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

readonly CURRENT_NETWORK="SSID_Name"
readonly -a DIRECT_SSIDS=("Trusted SSID 1" "Trusted SSID 2" "SSID3")

if command -v tailscale &>/dev/null; then
    TAILSCALE_BIN="$(command -v tailscale)"
elif [[ -x "/Applications/Tailscale.app/Contents/MacOS/Tailscale" ]]; then
    TAILSCALE_BIN="/Applications/Tailscale.app/Contents/MacOS/Tailscale"
else
    exit 0
fi

if [[ -z "${CURRENT_NETWORK}" ]]; then
    exit 0
fi

# Determine if CURRENT_NETWORK exists within the DIRECT_SSIDS array
is_direct=0
for ssid in "${DIRECT_SSIDS[@]}"; do
    if [[ "${ssid}" == "${CURRENT_NETWORK}" ]]; then
        is_direct=1
        break
    fi
done

if [[ ${is_direct} -eq 1 ]]; then
    # Disable Exit Node if currently active
    output=$(tailscale exit-node list 2>/dev/null)
    if echo "${output}" | grep -q "selected"; then
        tailscale set --exit-node=
    fi
else
    # Enable Exit Node if not currently active
    output=$(tailscale exit-node list 2>/dev/null)
    if ! echo "${output}" | grep -q "selected"; then
        tailscale set --exit-node=auto:any
    fi
fi

exit 0