#!/bin/bash

REPORTS_DIR="../../reports"

show_report() {
    clear
    echo "======================================"
    echo "EXIBINDO: $1"
    echo "======================================"
    cat "$REPORTS_DIR/$1"
    echo ""
    read -p "Pressione [Enter] para voltar ao menu..."
}

while true; do
    clear
    echo "========== CENTRAL DE RELATÓRIOS =========="
    echo "1) Ver Reconhecimento (Nmap)"
    echo "2) Ver Diretórios (Gobuster)"
    echo "3) Ver Logs de Upload/Bypass"
    echo "4) Ver Pós-Exploração (Flags/Usuário)"
    echo "5) Ver Escalação de Privilégios (SUID)"
    echo "6) Sair"
    echo "==========================================="
    read -p "Escolha uma opção [1-6]: " opt

    case $opt in
        1) show_report "nmap.txt" ;;
        2) show_report "gobuster.txt" ;;
        3) show_report "upload_log.txt" ;;
        4) show_report "post_enum.txt" ;;
        5) show_report "privsec.txt" ;;
        6) exit 0 ;;
        *) echo "Opção inválida!" ; sleep 1 ;;
    esac
done