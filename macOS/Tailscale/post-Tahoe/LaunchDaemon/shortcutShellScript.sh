#!/bin/zsh

export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

readonly CURRENT_NETWORK="SSID_Name"
readonly -a TRUSTED_SSIDS=("Trusted SSID 1" "Trusted SSID 2" "SSID3")

if [[ -z "${CURRENT_NETWORK}" ]]; then
    echo "Error: No network name provided."
    exit 1
fi

# Determine if CURRENT_NETWORK exists within the TRUSTED_SSIDS array
is_trusted=0
for ssid in "${TRUSTED_SSIDS[@]}"; do
    if [[ "${ssid}" == "${CURRENT_NETWORK}" ]]; then
        is_trusted=1
        break
    fi
done

if [[ ${is_trusted} -eq 1 ]]; then
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