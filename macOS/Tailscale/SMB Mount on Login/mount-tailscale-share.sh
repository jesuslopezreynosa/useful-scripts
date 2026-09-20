#!/zsh

# Setup
# - Edit `mount-tailscale-share.sh` first
# mkdir -p ~/.local/bin
# cp mount-tailscale-share.sh ~/.local/bin/.
# chmod +x ~/.local/bin/mount-tailscale-share.sh
# sudo cp com.user.mount-tailscale-share.plist /Library/LaunchAgents/.
# launchctl bootstrap gui/$(id -u) /Library/LaunchAgents/com.user.mount-tailscale-share.plist

# Configurable parameters
SMB_SERVER="100.x.y.z"            # Replace with Tailscale IP or MagicDNS hostname
SHARE_NAME="MyShare"               # Replace with SMB share folder name
MOUNT_POINT="/Volumes/${ SHARE_NAME }"
WAIT_TIMEOUT="5s"                  # Timeout duration string for tailscale wait
PING_TIMEOUT=3                     # Timeout in seconds for SMB host ping check

# Resolve tailscale executable location
TS_BIN="$(command -v tailscale)"
if [[ -z "$TS_BIN" && -x "/Applications/Tailscale.app/Contents/MacOS/Tailscale" ]]; then
    TS_BIN="/Applications/Tailscale.app/Contents/MacOS/Tailscale"
fi

# Check if share is already mounted
if mount | grep -q "on ${MOUNT_POINT} "; then
    echo "Share is already mounted at ${MOUNT_POINT}."
    exit 0
fi

# Step 1: Wait for Tailscale local daemon/interface
if [[ -n "$TS_BIN" ]]; then
    echo "Waiting for Tailscale interface to be ready..."
    if ! "$TS_BIN" wait --timeout="${WAIT_TIMEOUT}" >/dev/null 2>&1; then
        echo "Tailscale interface is not ready or timed out."
        exit 1
    fi
    echo "Tailscale interface is ready."
fi

# Step 2: Confirm physical host reachability over Tailscale before attempting mount
echo "Verifying SMB host reachability at ${SMB_SERVER}..."
if ! ping -c 1 -t "${PING_TIMEOUT}" "${SMB_SERVER}" >/dev/null 2>&1; then
    echo "Error: SMB server ${SMB_SERVER} is unreachable. Skipping mount."
    exit 1
fi
echo "SMB server ${SMB_SERVER} is reachable."

# Step 3: Delegate mounting to NetFS via osascript with timeout protection
echo "Mounting ${SHARE_NAME}..."
{
    osascript -e "mount volume \"smb://${SMB_SERVER}/${SHARE_NAME}\"" >/dev/null 2>&1
} &
MOUNT_PID=$!

# Enforce a 5-second watchdog timer on osascript
( sleep 5; kill -9 $MOUNT_PID 2>/dev/null ) &
WATCHDOG_PID=$!

wait $MOUNT_PID 2>/dev/null
MOUNT_STATUS=$?

# Kill watchdog if osascript finished naturally
kill -9 $WATCHDOG_PID 2>/dev/null

if [[ $MOUNT_STATUS -eq 0 ]] && mount | grep -q "on ${MOUNT_POINT} "; then
    echo "Successfully mounted ${SHARE_NAME} at ${MOUNT_POINT}."

    # OPTIONAL
    echo "Opening Parachute Backup..."
    open -a "Parachute Backup"
else
    echo "Failed or timed out attempting to mount ${SHARE_NAME}."
    exit 1
fi