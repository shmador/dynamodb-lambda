#!/usr/bin/env bash

source .env

# detect interface & measure bytes/sec
IF="${1:-$(ip route get 8.8.8.8 | awk '/dev/ {print $5; exit}')}"
INTERVAL="${2:-1}"
rx1=$(< /sys/class/net/"$IF"/statistics/rx_bytes)
tx1=$(< /sys/class/net/"$IF"/statistics/tx_bytes)
sleep "$INTERVAL"
rx2=$(< /sys/class/net/"$IF"/statistics/rx_bytes)
tx2=$(< /sys/class/net/"$IF"/statistics/tx_bytes)
rx_bps=$(( (rx2 - rx1) / INTERVAL ))
tx_bps=$(( (tx2 - tx1) / INTERVAL ))
id_name="dor-auto${VERSION}"
((VERSION++))
sed -i "s/^VERSION=.*/VERSION=$VERSION/" .env
# Build JSON
JSON=$(printf \
  '{"TableName":"imtech","Item":{"id":{"S":"%s"},"interface":{"S":"%s"},"rx_bps":{"N":"%d"},"tx_bps":{"N":"%d"}}}' \
  "$id_name" "$IF" "$rx_bps" "$tx_bps"
)

# Send it
URL="https://mj92zct6nc.execute-api.il-central-1.amazonaws.com/default/imtech-dor-py" 
curl -X POST $URL -H "Content-Type: application/json" -d "$JSON"

