#!/usr/bin/env bash
set -euo pipefail
if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <USER@HOST> [SOCKS_PORT] [MODE=minimal|bypass|strictDNS]" >&2
  exit 1
fi
HOST="$1"
SOCKS_PORT="${2:-1080}"
MODE="${3:-minimal}"
BROWSER="${BROWSER:-chromium}"
PROFILE_DIR="$(mktemp -d -t chromium-proxy-XXXXXX)"
LOG_SSH="$(mktemp -t ssh-socks-log-XXXXXX)"
cleanup() {
  [[ -n "${SSH_PID:-}" ]] && kill "$SSH_PID" 2>/dev/null || true
  rm -rf "$PROFILE_DIR" "$LOG_SSH"
}
trap cleanup EXIT INT TERM
TRY_PORT="$SOCKS_PORT"
for _ in {1..10}; do
  ss -lnt "( sport = :$TRY_PORT )" | grep -q . || break
  TRY_PORT=$((TRY_PORT+1))
done
SOCKS_PORT="$TRY_PORT"
ssh -4 -D "127.0.0.1:${SOCKS_PORT}" -C -N \
    -o ExitOnForwardFailure=yes \
    -o ServerAliveInterval=15 \
    -o ServerAliveCountMax=3 \
    "$HOST" 1>/dev/null 2>"$LOG_SSH" &
SSH_PID=$!
sleep 1
if ! kill -0 "$SSH_PID" 2>/dev/null; then
  echo "SSH failed to start. Details:" >&2
  cat "$LOG_SSH" >&2 || true
  exit 1
fi
curl --max-time 7 --silent --show-error \
     --socks5-hostname 127.0.0.1:"$SOCKS_PORT" https://ifconfig.io/ip >/dev/null
"$BROWSER" --headless=new --disable-gpu \
  --proxy-server="socks5://127.0.0.1:${SOCKS_PORT}" \
  --disable-quic --dump-dom https://ifconfig.io/ip >/dev/null
case "$MODE" in
  minimal)
    exec "$BROWSER" \
      --user-data-dir="$PROFILE_DIR" --no-first-run \
      --proxy-server="socks5://127.0.0.1:${SOCKS_PORT}" \
      --disable-quic
    ;;
  bypass)
    exec "$BROWSER" \
      --user-data-dir="$PROFILE_DIR" --no-first-run \
      --proxy-server="socks5://127.0.0.1:${SOCKS_PORT}" \
      --proxy-bypass-list="<-loopback>;*.local" \
      --disable-quic
    ;;
  strictDNS)
    exec "$BROWSER" \
      --user-data-dir="$PROFILE_DIR" --no-first-run \
      --proxy-server="socks5://127.0.0.1:${SOCKS_PORT}" \
      --host-resolver-rules="MAP * ~NOTFOUND, EXCLUDE localhost" \
      --proxy-bypass-list="<-loopback>" \
      --disable-quic
    ;;
  *)
    echo "Unknown MODE: $MODE" >&2; exit 1;;
esac
