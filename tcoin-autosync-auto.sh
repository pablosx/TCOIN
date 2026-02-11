#!/data/data/com.termux/files/usr/bin/bash

# ===== TCOIN Autonomous Sync + Stats Dashboard =====

sleep 5

# Start ssh-agent if needed
if [ -z "$SSH_AGENT_PID" ]; then
    eval $(ssh-agent -s)
fi

SSH_KEY="$HOME/.ssh/id_ed25519"
ssh-add -l | grep -q "$(ssh-keygen -lf $SSH_KEY | awk '{print $2}')" || ssh-add $SSH_KEY < /dev/null 2>/dev/null

# ---- Config ----
SYNC_INTERVAL=3600
MIN_HEARTBEAT=$((6*3600))
MAX_HEARTBEAT=$((12*3600))

TODAY=$(date +%Y-%m-%d)
START_OF_DAY=$(date +%s)

SUCCESS=0
FAIL=0
NETWORK_FAIL=0
HEARTBEAT_COUNT=0

LAST_SUCCESS=$(date +%s)
LAST_HEARTBEAT=$(date +%s)

while true; do
    NOW=$(date +%s)
    DATE_STR=$(date)

    # ---- Sync Attempt ----
    if ping -c 1 github.com &>/dev/null; then
        if ~/TCOIN/sync-tcoin-auto-full.sh >> ~/TCOIN/sync.log 2>&1; then
            ((SUCCESS++))
            LAST_SUCCESS=$NOW
            echo "$DATE_STR: Sync SUCCESS" >> ~/TCOIN/sync.log
        else
            ((FAIL++))
            echo "$DATE_STR: Sync FAILED" >> ~/TCOIN/sync.log
        fi
    else
        ((NETWORK_FAIL++))
        echo "$DATE_STR: Network unreachable" >> ~/TCOIN/sync.log
    fi

    # ---- Dynamic Heartbeat ----
    TIME_SINCE_SUCCESS=$((NOW - LAST_SUCCESS))
    TIME_SINCE_HEARTBEAT=$((NOW - LAST_HEARTBEAT))

    if (( TIME_SINCE_SUCCESS >= MIN_HEARTBEAT && TIME_SINCE_HEARTBEAT >= MIN_HEARTBEAT )); then
        ((HEARTBEAT_COUNT++))
        termux-notification --title "TCOIN Heartbeat 💓" \
        --content "Alive. Last success: $(date -d @$LAST_SUCCESS)" \
        --priority low
        LAST_HEARTBEAT=$NOW
    fi

    if (( TIME_SINCE_HEARTBEAT >= MAX_HEARTBEAT )); then
        ((HEARTBEAT_COUNT++))
        termux-notification --title "TCOIN Forced Heartbeat 💓" \
        --content "System alive. Last sync: $(date -d @$LAST_SUCCESS)" \
        --priority low
        LAST_HEARTBEAT=$NOW
    fi

    # ---- Daily Summary at Midnight ----
    CURRENT_DATE=$(date +%Y-%m-%d)

    if [[ "$CURRENT_DATE" != "$TODAY" ]]; then

        TOTAL_ATTEMPTS=$((SUCCESS + FAIL + NETWORK_FAIL))
        if (( TOTAL_ATTEMPTS > 0 )); then
            UPTIME=$(awk "BEGIN { printf \"%.2f\", ($SUCCESS/$TOTAL_ATTEMPTS)*100 }")
        else
            UPTIME="100.00"
        fi

        SUMMARY="Date: $TODAY
Success: $SUCCESS
Failures: $FAIL
Network Drops: $NETWORK_FAIL
Heartbeats: $HEARTBEAT_COUNT
Uptime: $UPTIME%"

        echo -e "$SUMMARY" >> ~/TCOIN/daily_summary.log

        termux-notification --title "TCOIN Daily Dashboard 📊" \
        --content "Success:$SUCCESS Fail:$FAIL Net:$NETWORK_FAIL Up:$UPTIME%" \
        --priority high

        # Reset counters
        TODAY="$CURRENT_DATE"
        SUCCESS=0
        FAIL=0
        NETWORK_FAIL=0
        HEARTBEAT_COUNT=0
        START_OF_DAY=$NOW
    fi

    sleep $SYNC_INTERVAL
done
