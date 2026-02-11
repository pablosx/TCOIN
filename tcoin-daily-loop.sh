#!/data/data/com.termux/files/usr/bin/bash
# ================================
# TCOIN Daily Health Loop with Notifications
# ================================

REPO="$HOME/TCOIN"
SCRIPT="$REPO/tcoin-full-health.sh"
LOG_DIR="$REPO/logs"

mkdir -p "$LOG_DIR"

while true; do
    TODAY=$(date +"%Y-%m-%d")
    LOG="$LOG_DIR/full-health-$TODAY.log"

    # Run full health check and capture output
    OUTPUT=$(bash "$SCRIPT" 2>&1)

    # Save output to log
    echo "$OUTPUT" &>> "$LOG"

    # Send notification if anything failed
    if echo "$OUTPUT" | grep -q "❌"; then
        termux-notification \
            --title "TCOIN Alert" \
            --content "One or more scripts failed or were restarted. Check log: $LOG" \
            --priority high
    fi

    # Optional: notify successful daily check
    termux-notification \
        --title "TCOIN Health" \
        --content "Daily health check completed ✅" \
        --priority low

    # Remove logs older than 30 days
    find "$LOG_DIR" -type f -name "full-health-*.log" -mtime +30 -delete

    # Sleep 24 hours (86400 seconds)
    sleep 86400
done
