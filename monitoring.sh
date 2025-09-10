#!/bin/bash

# Log file
LOG_FILE="/home/ubuntu/pm2-process-query.log"
NOW=$(date '+%Y-%m-%d %H:%M:%S')

# Header
echo "=============================" | tee -a $LOG_FILE
echo "Query Time: $NOW" | tee -a $LOG_FILE
echo "=============================" | tee -a $LOG_FILE

# Check all processes
pm2 jlist | jq -r --arg now "$(date +%s)" '
  .[] |
  .name as $name |
  .pm_id as $id |
  .monit.cpu as $cpu |
  .monit.memory as $mem |
  ((($now | tonumber) - (.pm2_env.pm_uptime/1000 | floor))) as $uptime |
  [$id, $name, $cpu, $mem, $uptime,
   ((($uptime/3600|floor|tostring) + ":" + (($uptime%3600/60|floor|tostring)) + ":" + (($uptime%60)|tostring)))]
  | @tsv
' | while IFS=$'\t' read -r ID NAME CPU MEM UPTIME SECONDS; do
    
    # Print process details
    echo "📌 Process: $NAME (id=$ID)" | tee -a $LOG_FILE
    echo "   CPU: $CPU% | Memory: $MEM | Uptime: $UPTIME ($SECONDS sec)" | tee -a $LOG_FILE

    # If CPU > 75, log queries
    if (( $(echo "$CPU > 75" | bc -l) )); then
        echo "   ⚠️ High CPU detected (>75%)" | tee -a $LOG_FILE
        echo "   👉 Recent Queries:" | tee -a $LOG_FILE
        pm2 logs $ID --lines 50 --nostream 2>/dev/null | grep -i "query" | tail -n 10 | tee -a $LOG_FILE
    fi

    echo "" | tee -a $LOG_FILE
done