#!/bin/bash

WATCH_DIR=${PCAPS_DIR:-/pcaps}
OUTPUT_DIR=${FLOWS_DIR:-/flows}
DELAY=${DELAY:-5}

echo "[INFO] CICFlowMeter watcher started..."
while true; do
  for file in "$WATCH_DIR"/*.pcap; do
    [ -e "$file" ] || continue
    filename=$(basename -- "$file")
    base="${filename%.*}"
    output="$OUTPUT_DIR/$base.csv"

    echo "[INFO] Processing $filename..."

    java -Djava.library.path=/app/jnetpcap/linux/jnetpcap-1.4.r1425 \
         -cp build/libs/CICFlowMeter-4.0-all.jar \
         cicflowmeter.CICFlowMeter \
         -f "$WATCH_DIR/$filename" -c "$output"

    if [ $? -eq 0 ]; then
      echo "[INFO] Processed $filename, publishing to RabbitMQ..."
      python3 /app/send_to_rabbitmq.py "$output"
      echo "[INFO] Published. Cleaning up..."
      rm -f "$file"
    else
      echo "[WARN] Failed to process $filename, retrying later."
    fi
  done

  sleep "$DELAY"
done
