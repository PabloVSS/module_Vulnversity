#!/bin/bash
source "$(dirname "$0")/../common.sh"

REPORT="../../reports/nmap.txt"
mkdir -p ../../reports

log "Nmap iniciando em $TARGET_IP"

{
    echo "====================================================="
    echo "RECONNAISSANCE REPORT - NMAP"
    echo "====================================================="
    echo "[?] How many ports are open? "
    echo "[?] Version of squid proxy: "
    echo "[?] Most likely OS: "
    echo "[?] Web server port: $PORT_WEB"
    echo "-----------------------------------------------------"
    
    nmap -sC -sV -Pn -p- -v "$TARGET_IP"
} > "$REPORT"

log "Relatório estruturado salvo em $REPORT"