#!/bin/bash

set -e

OUTPUT_DIR="reports"
TIMESTAMP=$(date +"%Y%m%d-%H%M%S")
REPORT_FILE="$OUTPUT_DIR/trivy-report-$TIMESTAMP.txt"

mkdir -p $OUTPUT_DIR

echo "[*] Collecting running container images..."
kubectl get pods --all-namespaces \
  -o jsonpath='{range .items[*]}{.spec.containers[*].image}{"\n"}{end}' \
  | sort -u > images.txt

echo "[*] Scanning images with Trivy..."
echo "Report: $REPORT_FILE"
echo "---------------------------------" | tee $REPORT_FILE

FAIL=0

while read i; do
  echo "Scanning $i" | tee -a $REPORT_FILE
  trivy image --severity HIGH,CRITICAL --no-progress $i | tee -a $REPORT_FILE
  if [ ${PIPESTATUS[0]} -ne 0 ]; then
    FAIL=1
  fi
done < images.txt

if [ $FAIL -eq 1 ]; then
  echo "[!] Critical vulnerabilities found." | tee -a $REPORT_FILE
  exit 1
else
  echo "[+] No critical vulnerabilities detected." | tee -a $REPORT_FILE
fi

