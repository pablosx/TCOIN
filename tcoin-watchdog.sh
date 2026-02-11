#!/data/data/com.termux/files/usr/bin/bash
# tcoin-watchdog.sh — Monitors and self-heals TCOIN scripts

TCOIN_DIR="$HOME/TCOIN"
LOG="$TCOIN_DIR/watchdog.log"

# Discord webhook for alerts
DISCORD_WEBHOOK="https://discord.com/api/webhooks/1470988669442850922/kjKcV5aYblGHzHRSfl4_4CTMPvKMigm4P9MKXq9c6aHcnvAx-KFbZcdxuRpDJvz1iSWR"

# Scripts to monitor
SCRIPTS=(
    "tcoin-autosync-auto.sh"
    "tcoin-autosync-network.sh"
    "tcoin-integrity-guard.sh"
)

# --------------------------
# Functions
# --------------------------

# Send alert to Discord
send_discord_alert() {
    local MSG="$1"
    curl -s -H "Content-Type: application/json" \
         -X POST -d "{\"content\":\"$MSG\"}" \
         "$DISCORD_WEBHOOK"
}

# Log locally
log_event() {
    local MSG="$1"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $MSG" | tee -a "$LOG"
}

# Ensure script is executable and running
check_and_heal() {
    local SCRIPT="$1"
    local SCRIPT_PATH="$TCOIN_DIR/$SCRIPT"

    # Restore execute permission if needed
    if [ ! -x "$SCRIPT_PATH" ]; then
        chmod +x "$SCRIPT_PATH"
        log_event "🛠️ Restored execute permission on $SCRIPT"
        send_discord_alert "🛠️ Watchdog restored execute permission on $SCRIPT"
    fi

    # Restart if not running
    if ! pgrep -f "$SCRIPT_PATH" >/dev/null; then
        log_event "⚠️ $SCRIPT not running. Restarting..."
        send_discord_alert "⚠️ Watchdog restarted $SCRIPT at $(date)"
        nohup "$SCRIPT_PATH" >/dev/null 2>&1 &
    fi
}

# --------------------------
# Main Watchdog Loop
# --------------------------

log_event "🚨 Watchdog started. Monitoring TCOIN scripts..."

while true; do
    for SCRIPT in "${SCRIPTS[@]}"; do
        check_and_heal "$SCRIPT"
    done
    sleep 60  # check every 60 seconds
done
