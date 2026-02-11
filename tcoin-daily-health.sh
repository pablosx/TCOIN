#!/data/data/com.termux/files/usr/bin/bash
# tcoin-daily-health.sh — Daily health check for TCOIN scripts
# Checks status of all critical scripts, ensures executables, and sends Discord summary

# --------------------------
# Configuration
# --------------------------

TCOIN_DIR="$HOME/TCOIN"
HEALTH_LOG="$TCOIN_DIR/health.log"

# Discord webhook
DISCORD_WEBHOOK="https://discord.com/api/webhooks/1470988669442850922/kjKcV5aYblGHzHRSfl4_4CTMPvKMigm4P9MKXq9c6aHcnvAx-KFbZcdxuRpDJvz1iSWR"

# Scripts to monitor
SCRIPTS=(
    "tcoin-autosync-auto.sh"
    "tcoin-autosync-network.sh"
    "tcoin-watchdog.sh"
    "tcoin-integrity-guard.sh"
)

# --------------------------
# Functions
# --------------------------

# Send Discord alert
send_discord_alert() {
    local MSG="$1"
    curl -s -H "Content-Type: application/json" \
         -X POST -d "{\"content\":\"$MSG\"}" \
         "$DISCORD_WEBHOOK"
}

# Log locally
log_event() {
    local MSG="$1"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $MSG" | tee -a "$HEALTH_LOG"
}

# Check if script is executable and running
check_script() {
    local SCRIPT_NAME="$1"
    local SCRIPT_PATH="$TCOIN_DIR/$SCRIPT_NAME"
    local STATUS="❌ Not running"

    # Ensure executable
    if [ ! -x "$SCRIPT_PATH" ]; then
        chmod +x "$SCRIPT_PATH"
        log_event "🛠️ Restored execute permission on $SCRIPT_NAME"
    fi

    # Check if running
    if pgrep -f "$SCRIPT_PATH" >/dev/null; then
        STATUS="✅ Running"
    fi

    echo "$SCRIPT_NAME: $STATUS"
}

# --------------------------
# Main Health Check
# --------------------------

log_event "📊 Starting daily TCOIN health check..."

SUMMARY=""
for SCRIPT in "${SCRIPTS[@]}"; do
    CHECK=$(check_script "$SCRIPT")
    log_event "$CHECK"
    SUMMARY+="$CHECK\n"
done

log_event "✅ Daily TCOIN health check complete."

# Send summary to Discord
send_discord_alert "📆 Daily TCOIN Health Summary:\n$SUMMARY"
