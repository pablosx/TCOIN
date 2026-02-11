#!/data/data/com.termux/files/usr/bin/bash
# ================================
# TCOIN Self-Healing Test Script
# Fully interactive and auto-permission fix
# ================================

REPO="$HOME/TCOIN"
AUTOSYNC="$REPO/tcoin-autosync-auto.sh"
WATCHDOG="$REPO/tcoin-watchdog.sh"
INTEGRITY="$REPO/tcoin-integrity-guard.sh"
LOG="$REPO/test-self-heal.log"

echo "=== Starting Self-Healing Test at $(date) ===" > $LOG

# 1️⃣ Ensure scripts have execute permission before testing
for f in "$AUTOSYNC" "$WATCHDOG" "$INTEGRITY"; do
    chmod +x "$f" 2>/dev/null
    echo "$(date): Ensured execute permission on $f" >> $LOG
done

# 2️⃣ Kill any running TCOIN processes
pkill -f tcoin-autosync-auto.sh 2>/dev/null
pkill -f tcoin-watchdog.sh 2>/dev/null
sleep 2

# 3️⃣ Run autosync in background
echo "$(date): Starting autosync..." >> $LOG
nohup "$AUTOSYNC" &>> $LOG &
sleep 2

# 4️⃣ Check permissions
for f in "$AUTOSYNC" "$WATCHDOG" "$INTEGRITY"; do
    if [ -x "$f" ]; then
        echo "$(date): $f is executable ✅" >> $LOG
    else
        echo "$(date): $f is NOT executable ❌" >> $LOG
    fi
done

# 5️⃣ Start watchdog in background
echo "$(date): Starting watchdog..." >> $LOG
nohup "$WATCHDOG" &>> $LOG &
sleep 2

# 6️⃣ Kill autosync deliberately to test watchdog restart
pkill -f tcoin-autosync-auto.sh
echo "$(date): Autosync killed to test watchdog..." >> $LOG

# 7️⃣ Wait 15 seconds for watchdog to restart it
sleep 15

# 8️⃣ Verify autosync restarted
if pgrep -f tcoin-autosync-auto.sh >/dev/null; then
    echo "$(date): Watchdog restarted autosync ✅" >> $LOG
else
    echo "$(date): Watchdog failed to restart autosync ❌" >> $LOG
fi

echo "=== Self-Healing Test Complete ===" >> $LOG
cat $LOG
