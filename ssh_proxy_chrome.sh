#!/bin/bash
REMOTE_HOST="ws.om.local"
PROXY_PORT="1080"
SSH_CONTROL_SOCKET="/tmp/ssh_socks_control"
CHROME_PATH="/usr/bin/google-chrome"  # путь к chrome или chromium
if ! ss -ltn | grep -q ":$PROXY_PORT"; then
  echo "SSH-туннель через $REMOTE_HOST на порт $PROXY_PORT..."
  ssh -f -N -D "$PROXY_PORT" -M -S "$SSH_CONTROL_SOCKET" "$REMOTE_HOST"
else
  echo " Туннель уже активен на порту $PROXY_PORT"
fi
echo "Chrome через SOCKS5-прокси..."
"$CHROME_PATH" \
  --proxy-server="socks5://localhost:$PROXY_PORT" \
  --host-resolver-rules="MAP * 0.0.0.0 , EXCLUDE localhost" \
  --user-data-dir="/tmp/proxied-chrome-profile" \
  "$@"  # ← позволяет передать URL в аргументах
echo "Стоп SSH-туннель..."
ssh -S "$SSH_CONTROL_SOCKET" -O exit "$REMOTE_HOST"
