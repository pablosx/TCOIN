#!/data/data/com.termux/files/usr/bin/bash
# tcoin-watchdog.sh — Termux-safe persistent watchdog for TCOIN
# Monitors autosync, network sync, and integrity guard
# Ensures scripts are executable and running
# Sends Discord alerts on any fixes

TCOIN_DIR="$HOME/TCOIN"
LOG="$TCOIN_DIR/watchdog.log"

DISCORD_WEBHOOK="https://discord.com/api/webhooks/1470988669442850922/kjKcV5aYblGHzHRSfl4_4CTMPvKMigm4P9MKXq9c6aHcnvAx-KFbZcdxuRpDJvz1iSWR"

SCRIPTS=(
    "tcoin-autosync-auto.sh"
    "tcoin-autosync-network.sh"
    "tcoin-integrity-guard.sh"
)

# Termux-safe PATH
export PATH="$HOME/bin:$PATH"

# --------------------------
# Functions
# --------------------------

send_discord_alert() {
    local MSG="$1"
    curl -s -H "Content-Type: application/json" \
         -X POST -d "{\"content\":\"$MSG\"}" \
         "$DISCORD_WEBHOOK"
}

log_event() {
    local MSG="$1"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $MSG" | tee -a "$LOG"
}

check_termux_api() {
    # Simple test for Termux API availability
    command -v termux-battery-status >/dev/null 2>&1
}

restart_script() {
    local SCRIPT="$1"
    local SCRIPT_PATH="$TCOIN_DIR/$SCRIPT"
    local SCRIPT_LOG="$TCOIN_DIR/$SCRIPT.log"

    # Restore execute permission if needed
    if [ ! -x "$SCRIPT_PATH" ]; then
        chmod +x "$SCRIPT_PATH"
        log_event "🛠️ Restored execute permission on $SCRIPT"
        send_discord_alert "🛠️ Watchdog restored execute permission on $SCRIPT"
    fi

    # Attempt restart with retries
    for i in {1..5}; do
        if [ "$SCRIPT" == "tcoin-autosync-auto.sh" ]; then
            if ! check_termux_api; then
                log_event "⚠️ Termux API not ready. Waiting 15s..."
                sleep 15
                continue
            fi

            # Launch autosync via Termux Job Scheduler for persistence
            termux-job-scheduler --period 60000 --persisted true --service "$SCRIPT_PATH"
        else
            # Normal restart for other scripts
            setsid bash -c "$SCRIPT_PATH >> $SCRIPT_LOG 2>&1 &"
        fi

        sleep 15

        if pgrep -f "$SCRIPT_PATH" >/dev/null; then
            log_event "✅ $SCRIPT restarted successfully (attempt $i)"
            send_discord_alert "✅ Watchdog restarted $SCRIPT at $(date)"
            break
        else
            log_event "⚠️ $SCRIPT still not running after attempt $i"
        fi
    done
}

check_and_heal() {
    local SCRIPT="$1"
    local SCRIPT_PATH="$TCOIN_DIR/$SCRIPT"

    # Restore execute permission and check
    if [ ! -x "$SCRIPT_PATH" ]; then
        chmod +x "$SCRIPT_PATH"
        log_event "🛠️ Restored execute permission on $SCRIPT"
        send_discord_alert "🛠️ Watchdog restored execute permission on $SCRIPT"
    fi

    # Restart if not running
    if ! pgrep -f "$SCRIPT_PATH" >/dev/null; then
        log_event "⚠️ $SCRIPT not running. Restarting..."
        send_discord_alert "⚠️ Watchdog restarting $SCRIPT at $(date)"
        restart_script "$SCRIPT"
    fi
}

# --------------------------
# Main Loop
# --------------------------

log_event "🚨 Watchdog started. Monitoring TCOIN scripts..."

while true; do
    for SCRIPT in "${SCRIPTS[@]}"; do
        check_and_heal "$SCRIPT"
    done
    sleep 60  # Check every 60 seconds
done
