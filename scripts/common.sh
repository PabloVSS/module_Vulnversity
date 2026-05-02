#!/bash/bin

ENV_FILE="$(dirname "$0")/../../.env"


if [ -f "$ENV_FILE" ]; then
  export $(grep -v '^#' "$ENV_FILE" | xargs)
else
  echo "[!] .env não encontrado"
  exit 1
fi


PORT_WEB=${PORT_WEB:-3333}
LISTENER_PORT=${LISTENER_PORT:-1234}

log(){
    echo -e "[*] $1"

}

err(){
    echo -e "[!] $1"
}