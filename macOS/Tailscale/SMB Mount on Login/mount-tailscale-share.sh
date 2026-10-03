#!/bin/zsh

# Setup
    # - Edit `mount-tailscale-share.sh` first
    # In Terminal: 
        # mkdir -p ~/.local/bin
        # cp mount-tailscale-share.sh ~/.local/bin/.
        # chmod +x ~/.local/bin/mount-tailscale-share.sh
        # sudo cp com.user.mount-tailscale-share.plist ~/Library/LaunchAgents/.
        # launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/com.user.mount-tailscale-share.plist
# To disable LaunchAgent: `launchctl bootout gui/$(id -u)/com.user.mount-tailscale-share 2>/dev/null`

set -euo pipefail

readonly TAILSCALE_IP="100.x.x.x" # SMB Server's Tailscale IP or MagicDNS hostname
readonly SHARE_NAME="Share Name"    # Name of the SMB share
readonly SYSTEM_MOUNT_POINT="/Volumes/${SHARE_NAME}"

readonly MAX_RETRIES=30
readonly RETRY_INTERVAL=2

# --- Tailscale CLI Binary Resolution ---
if command -v tailscale >/dev/null 2>&1; then
    readonly TAILSCALE_BIN="$(command -v tailscale)"
elif [[ -x "/usr/local/bin/tailscale" ]]; then
    readonly TAILSCALE_BIN="/usr/local/bin/tailscale"
elif [[ -x "/opt/homebrew/bin/tailscale" ]]; then
    readonly TAILSCALE_BIN="/opt/homebrew/bin/tailscale"
else
    readonly TAILSCALE_BIN="/Applications/Tailscale.app/Contents/MacOS/Tailscale"
fi

# --- Logging Helper ---
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# --- Non-blocking Tailscale Status Check ---
is_tailscale_connected() {
    # Primary check: Verify kernel routing table routes target IP or CGNAT range via a utun interface
    if /sbin/route -n get "$TAILSCALE_IP" 2>/dev/null | /usr/bin/grep -q "interface: utun"; then
        return 0
    fi

    # Secondary check: Verify an active utun interface exists with a 100.x.y.z IP assignment
    if /sbin/ifconfig 2>/dev/null | /usr/bin/grep -A 4 -E "^utun" | /usr/bin/grep -q "inet 100\."; then
        return 0
    fi

    # Fallback CLI check: Execute status command in a subshell with a strict 1-second timeout
    if [[ -x "$TAILSCALE_BIN" ]]; then
        local ts_output=""
        ts_output=$( ( "$TAILSCALE_BIN" status --json 2>/dev/null ) & pid=$!; ( sleep 1; kill -9 $pid 2>/dev/null ) & watcher=$!; wait $pid 2>/dev/null; kill -9$watcher 2>/dev/null ) || true
        if echo "$ts_output" | /usr/bin/grep -q '"BackendState":"Running"'; then
            return 0
        fi
    fi

    return 1
}

# --- Pre-check: Verification if already mounted ---
if /sbin/mount | /usr/bin/grep -qE "on ${SYSTEM_MOUNT_POINT} \(smbfs,"; then
    log "Share '${SHARE_NAME}' is already mounted at '${SYSTEM_MOUNT_POINT}'. Exiting successfully."
    exit 0
fi

# --- Step 1: Wait for Active Local Network Interface ---
log "Checking for local network connectivity..."
network_ready=false
for ((i=1; i<=MAX_RETRIES; i++)); do
    if /sbin/route -n get default >/dev/null 2>&1; then
        network_ready=true
        break
    fi
    sleep "$RETRY_INTERVAL"
done

if [[ "$network_ready" == false ]]; then
    log "Error: Network interface failed to come online within timeout."
    exit 1
fi
log "Local network is active."

# --- Step 2: Wait for Tailscale Connection ---
log "Checking Tailscale connection..."
tailscale_ready=false
for ((i=1; i<=MAX_RETRIES; i++)); do
    if is_tailscale_connected; then
        tailscale_ready=true
        break
    fi
    sleep "$RETRY_INTERVAL"
done

if [[ "$tailscale_ready" == false ]]; then
    log "Error: Tailscale engine is not running or connected."
    exit 1
fi
log "Tailscale connection established."

# --- Step 3: Ping SMB Host over Tailscale ---
log "Pinging SMB server at ${TAILSCALE_IP}..."
host_reachable=false
for ((i=1; i<=MAX_RETRIES; i++)); do
    if /sbin/ping -c 1 -W 2000 "$TAILSCALE_IP" >/dev/null 2>&1; then
        host_reachable=true
        break
    fi
    sleep "$RETRY_INTERVAL"
done

if [[ "$host_reachable" == false ]]; then
    log "Error: SMB host ${TAILSCALE_IP} did not respond to ICMP ping."
    exit 1
fi
log "SMB host is reachable."

# --- Step 4: Mount SMB Share under /Volumes via macOS Finder ---
encoded_share_name="${SHARE_NAME// /%20}"
smb_uri="smb://${TAILSCALE_IP}/${encoded_share_name}"

log "Attempting to mount ${smb_uri} to /Volumes via Finder..."

if /usr/bin/osascript -e "mount volume \"${smb_uri}\"" >/dev/null 2>&1; then
    log "Successfully triggered mount for '${SHARE_NAME}' at '${SYSTEM_MOUNT_POINT}'."
    exit 0
else
    log "Error: Failed to mount SMB share via macOS Finder subsystem."
    exit 1
fi