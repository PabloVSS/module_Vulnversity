#!/bin/bash
source "$(dirname "$0")/../common.sh"

REPORT="../../reports/post_enum.txt"
mkdir -p ../../reports

log "Enumeração de Sistema Iniciada"

{
    echo "====================================================="
    echo "POST-EXPLOITATION ENUMERATION"
    echo "====================================================="

    echo "[?] User managing the webserver: $(whoami)"
    
    echo "[?] User Flag:"
    cat /home/*/user.txt 2>/dev/null

    echo "-----------------------------------------------------"

    echo "=== SYSTEM ID ==="
    id

    echo "=== USERS WITH HOME DIRECTORY ==="
    grep "/home" /etc/passwd

} > "$REPORT"

log "Dados salvos em $REPORT"