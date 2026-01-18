#!/bin/sh

echo "🚀 LIGHT LOAD TEST - 3 minutes (180 seconds)"
echo "Target: http://deepface-frontend-service"
echo "Load: 1 request/second"
echo ""

COUNT=0
TOTAL=180

while [ $COUNT -lt $TOTAL ]; do
  curl -s http://deepface-frontend-service/ > /dev/null 2>&1 &
  COUNT=$((COUNT + 1))
  
  if [ $((COUNT % 30)) -eq 0 ]; then
    PERCENT=$((COUNT * 100 / TOTAL))
    echo "[$(date +'%H:%M:%S')] Progress: $COUNT/$TOTAL requests ($PERCENT%)"
  fi
  
  sleep 1
done

echo ""
echo "✅ Light load test COMPLETED!"
echo "Total requests sent: $COUNT"
