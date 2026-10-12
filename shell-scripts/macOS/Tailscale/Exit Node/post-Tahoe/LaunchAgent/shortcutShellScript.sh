#!/bin/zsh

export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

readonly -a DIRECT_SSIDS=("Trusted SSID 1" "Trusted SSID 2" "SSID3")

# Locate Tailscale binary path
if command -v tailscale &>/dev/null; then
    TAILSCALE_BIN="$(command -v tailscale)"
elif [[ -x "/Applications/Tailscale.app/Contents/MacOS/Tailscale" ]]; then
    TAILSCALE_BIN="/Applications/Tailscale.app/Contents/MacOS/Tailscale"
else
    exit 0
fi

# Parse network name passed from Shortcut action via argument ($1) or standard input
RAW_INPUT="$1"
if [[ -z "${RAW_INPUT}" ]]; then
    RAW_INPUT="$(cat)"
fi

# Trim whitespace and newlines from retrieved network name
CURRENT_NETWORK="$(echo "${RAW_INPUT}" | tr -d '\r\n' | xargs)"

if [[ -z "${CURRENT_NETWORK}" ]]; then
    exit 0
fi

# Evaluate if current network matches trusted SSIDs
is_direct=0
for ssid in "${DIRECT_SSIDS[@]}"; do
    if [[ "${ssid}" == "${CURRENT_NETWORK}" ]]; then
        is_direct=1
        break
    fi
done

# Adjust Tailscale exit node status based on network trust level
if [[ ${is_direct} -eq 1 ]]; then
    output=$("${TAILSCALE_BIN}" exit-node list 2>/dev/null)
    if echo "${output}" | grep -q "selected"; then
        "${TAILSCALE_BIN}" set --exit-node=
    fi
else
    output=$("${TAILSCALE_BIN}" exit-node list 2>/dev/null)
    if ! echo "${output}" | grep -q "selected"; then
        "${TAILSCALE_BIN}" set --exit-node=auto:any
    fi
fi

exit 0