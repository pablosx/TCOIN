while true; do
    DATE=$(date)
    echo "=== TCOIN auto-sync check: $DATE ===" >> ~/TCOIN/sync.log

    if ping -c 1 github.com &>/dev/null; then
        echo "Network OK, syncing TCOIN..." >> ~/TCOIN/sync.log
        if ~/TCOIN/sync-tcoin-auto-full.sh >> ~/TCOIN/sync.log 2>&1; then
            termux-notification --title "TCOIN Sync ✅" --content "Sync completed at $DATE" --priority high
            echo "Sync finished at $DATE" >> ~/TCOIN/sync.log
        else
            termux-notification --title "TCOIN Sync ⚠️" --content "Sync failed at $DATE" --priority high
            echo "Sync failed at $DATE" >> ~/TCOIN/sync.log
        fi
    else
        termux-notification --title "TCOIN Sync ⚠️" --content "Network unreachable at $DATE" --priority high
        echo "Network unreachable, skipping this cycle." >> ~/TCOIN/sync.log
    fi

    sleep 3600
done
