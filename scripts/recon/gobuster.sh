#!/bin/bash
source "$(dirname "$0")/../common.sh"

REPORT="../../reports/gobuster.txt"
mkdir -p ../../reports

log "Gobuster iniciado em http://$TARGET_IP:$PORT_WEB"

{
    echo "====================================================="
    echo "DIRECTORY ENUMERATION REPORT"
    echo "====================================================="
    echo "[?] Directory with upload form: "
    echo "-----------------------------------------------------"

    gobuster dir -u "http://$TARGET_IP:$PORT_WEB" -w "$WORDLIST" -e -t 50
} > "$REPORT"

log "Diretórios salvos em $REPORT"