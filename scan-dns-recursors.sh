#!/usr/bin/env bash
set -euo pipefail
CIDR="${1:-}"
TEST_DOMAIN="${2:-example.com}"
PARALLEL="${3:-30}"
PORTS="${4:-53}"   # по умолчанию только 53
if [[ -z "$CIDR" ]]; then
  echo "Usage: $0 <CIDR> [domain] [parallel] [ports]" >&2
  exit 1
fi
for bin in nmap dig awk xargs; do
  command -v "$bin" >/dev/null 2>&1 || { echo "ERROR: '$bin' not found in PATH"; exit 2; }
done
TMPDIR="$(mktemp -d)"
IPS_ALL="$TMPDIR/ips.txt"
cleanup() { rm -rf "$TMPDIR"; }
trap cleanup EXIT
SUDO=""
sudo -n true >/dev/null 2>&1 && SUDO="sudo"
echo ">>> Сканирование $CIDR на порты $PORTS (UDP и TCP)..."
$SUDO nmap -sU -sT -p "$PORTS" --open -Pn -n "$CIDR" -oG "$TMPDIR/nmap.txt" >/dev/null
awk '/Ports:/ {
  ip=$2
  split($0,arr,"Ports:")
  split(arr[2],ports,",")
  for (i in ports) {
    sub(/^[ \t]+/,"",ports[i])
    if (ports[i] ~ /open/) {
      split(ports[i],f,"/")
      print ip, f[1], f[2]
    }
  }
}' "$TMPDIR/nmap.txt" > "$IPS_ALL"
if [[ ! -s "$IPS_ALL" ]]; then
  echo "Не найдено хостов с открытым портом(ами) $PORTS в $CIDR."
  exit 0
fi
echo ">>> Найдено $(wc -l < "$IPS_ALL") открытых сервисов DNS. Проверка рекурсии..."
echo "ip,proto,port,recursion_available,recursion_allowed,rcode,answer_count,flags,version_bind"
check_host() {
  local ip="$1"
  local port="$2"
  local proto="$3"
  local dig_args=( "+time=2" "+tries=1" "-p" "$port" )
  [[ "$proto" == "tcp" ]] && dig_args+=( "+tcp" )
  local out
  out="$(dig @"$ip" "$TEST_DOMAIN" A "${dig_args[@]}" 2>/dev/null || true)"
  local flags
  flags="$(grep -m1 'flags:' <<<"$out" | sed -E 's/.*flags: ([^;]+);.*/\1/' | tr -d ' ')"
  local rcode
  rcode="$(grep -m1 'status:' <<<"$out" | sed -E 's/.*status: ([^,]+),.*/\1/')"
  local ans_count
  ans_count="$(grep -m1 'ANSWER:' <<<"$out" | sed -E 's/.*ANSWER: *([0-9]+).*/\1/')"
  local recursion_available="no"
  [[ "$flags" == *"ra"* ]] && recursion_available="yes"
  local recursion_allowed="no"
  if [[ "$recursion_available" == "yes" ]]; then
    case "$rcode" in
      NOERROR|NXDOMAIN|SERVFAIL) recursion_allowed="yes" ;;
      REFUSED|NOTAUTH) recursion_allowed="no" ;;
      *) recursion_allowed="maybe" ;;
    esac
  fi
  local ver
  ver="$(dig @"$ip" version.bind txt chaos +short "${dig_args[@]}" 2>/dev/null | tr -d '"' || true)"
  [[ -z "$ver" ]] && ver="-"
  ver="${ver//,/;}" # экранирование запятой
  echo "$ip,$proto,$port,$recursion_available,$recursion_allowed,${rcode:--},${ans_count:-0},${flags:--},$ver"
}
export -f check_host
export TEST_DOMAIN
xargs -P "$PARALLEL" -n3 bash -c 'check_host "$@"' _ < "$IPS_ALL"
