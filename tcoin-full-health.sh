#!/data/data/com.termux/files/usr/bin/bash
# ================================
# TCOIN Full Health + Self-Healing Script
# ================================

REPO="$HOME/TCOIN"
LOG="$REPO/full-health.log"

AUTOSYNC="$REPO/tcoin-autosync-auto.sh"
NETWORK="$REPO/tcoin-autosync-network.sh"
WATCHDOG="$REPO/tcoin-watchdog.sh"
INTEGRITY="$REPO/tcoin-integrity-guard.sh"

echo "=== TCOIN Full Health Check & Self-Healing at $(date) ===" > $LOG

# 1️⃣ Ensure all scripts are executable
for f in "$AUTOSYNC" "$NETWORK" "$WATCHDOG" "$INTEGRITY"; do
    if [ ! -x "$f" ]; then
        chmod +x "$f" && echo "$(date): Fixed execute permission on $(basename $f) ✅" >> $LOG
    else
        echo "$(date): $(basename $f) already executable ✅" >> $LOG
    fi
done

# 2️⃣ Ensure all main processes are running
declare -A processes
processes=( ["tcoin-autosync-auto.sh"]="$AUTOSYNC" ["tcoin-autosync-network.sh"]="$NETWORK" ["tcoin-watchdog.sh"]="$WATCHDOG" )

for pname in "${!processes[@]}"; do
    if ! pgrep -f "$pname" >/dev/null; then
        nohup "${processes[$pname]}" &>> $LOG &
        echo "$(date): $pname was NOT running. Started it ✅" >> $LOG
    else
        pid=$(pgrep -f "$pname" | head -n1)
        echo "$(date): $pname is running (PID $pid) ✅" >> $LOG
    fi
done

# 3️⃣ Optional: kill autosync to test watchdog (only for manual testing)
# pkill -f tcoin-autosync-auto.sh
# echo "$(date): Autosync killed to test watchdog" >> $LOG
# sleep 15
# if pgrep -f tcoin-autosync-auto.sh >/dev/null; then
#     echo "$(date): Watchdog restarted autosync ✅" >> $LOG
# else
#     echo "$(date): Watchdog failed to restart autosync ❌" >> $LOG
# fi

echo "=== Full Health Check Complete ===" >> $LOG
cat $LOG
