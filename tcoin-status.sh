#!/data/data/com.termux/files/usr/bin/bash
# tcoin-status.sh — Real-time status check for TCOIN scripts
# Checks if key scripts are running and sends Discord alerts

# --------------------------
# Configuration
# --------------------------

TCOIN_DIR="$HOME/TCOIN"
STATUS_LOG="$TCOIN_DIR/status.log"

# Discord webhook
DISCORD_WEBHOOK="https://discord.com/api/webhooks/1470988669442850922/kjKcV5aYblGHzHRSfl4_4CTMPvKMigm4P9MKXq9c6aHcnvAx-KFbZcdxuRpDJvz1iSWR"

# Scripts to check
SCRIPTS=(
    "tcoin-autosync-auto.sh"
    "tcoin-autosync-network.sh"
    "tcoin-watchdog.sh"
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
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $MSG" | tee -a "$STATUS_LOG"
}

# Check if script is running
check_script() {
    local SCRIPT_NAME="$1"
    local SCRIPT_PATH="$TCOIN_DIR/$SCRIPT_NAME"
    local STATUS="❌ Not running"

    if [ -x "$SCRIPT_PATH" ]; then
        if pgrep -f "$SCRIPT_PATH" >/dev/null; then
            STATUS="✅ Running"
        fi
    else
        STATUS="⚠️ Not executable"
    fi

    echo "$SCRIPT_NAME: $STATUS"
}

# --------------------------
# Main Status Check
# --------------------------

log_event "🔍 Checking TCOIN scripts status..."

STATUS_SUMMARY=""
for SCRIPT in "${SCRIPTS[@]}"; do
    CHECK=$(check_script "$SCRIPT")
    log_event "$CHECK"
    STATUS_SUMMARY+="$CHECK\n"
done

log_event "✅ Status check complete."

# Send status summary to Discord
send_discord_alert "📘 TCOIN Status Check:\n$STATUS_SUMMARY"
