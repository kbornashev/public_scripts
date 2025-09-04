#!/usr/bin/env bash
set -euo pipefail
BASELINE="${BASELINE:-/var/log/chkrootkit/log.expected}"
TODAY_LOG="/var/log/chkrootkit/log.today"
TMPDIR="$(mktemp -d /tmp/sanity.XXXXXX)"
TRAP() { rm -rf "$TMPDIR"; }
trap TRAP EXIT
RED=$'\e[31m'; YEL=$'\e[33m'; GRN=$'\e[32m'; CLR=$'\e[0m'
say() { printf "%s\n" "$*"; }
ok()  { printf "%s[OK]%s %s\n"   "$GRN" "$CLR" "$*"; }
warn(){ printf "%s[WARN]%s %s\n" "$YEL" "$CLR" "$*"; }
fail(){ printf "%s[FAIL]%s %s\n" "$RED" "$CLR" "$*"; }
usage() {
  cat <<'EOF'
Usage:
  host-sanity-check.sh            # запустить все проверки
  host-sanity-check.sh --set-baseline
    - выполнить chkrootkit и записать /var/log/chkrootkit/log.expected
Env:
  BASELINE=/путь/к/эталону        # по умолчанию /var/log/chkrootkit/log.expected
EOF
}
need() {
  command -v "$1" >/dev/null 2>&1 || { fail "Не найдено: $1"; exit 1; }
}
run_chkrootkit() {
  need chkrootkit

  if [[ $EUID -ne 0 ]]; then
    fail "chkrootkit нужно запускать от root"; exit 1
  fi
  /usr/sbin/chkrootkit >"$TODAY_LOG" || true
  ok "chkrootkit выполнен: $TODAY_LOG"
}
set_baseline() {
  run_chkrootkit
  cp -a "$TODAY_LOG" "$BASELINE"
  ok "База chkrootkit зафиксирована: $BASELINE"
}
parse_chkr_warnings() {
  local file="$1"

  local count
  count=$(grep -c '^WARNING' "$file" || true)
  echo "$count"
}
diff_chkrootkit() {
  if [[ ! -f "$BASELINE" ]]; then
    warn "Эталон chkrootkit ($BASELINE) отсутствует — различия сравнить нельзя"
    return 2
  fi
  if diff -u "$BASELINE" "$TODAY_LOG" >"$TMPDIR/chkrootkit.diff"; then
    ok "chkrootkit: различий с эталоном нет"
  else
    warn "chkrootkit: найдены отличия (см. $TMPDIR/chkrootkit.diff)"
  fi

  local w_base w_today
  w_base=$(parse_chkr_warnings "$BASELINE")
  w_today=$(parse_chkr_warnings "$TODAY_LOG")
  if [[ "$w_today" != "$w_base" ]]; then
    warn "WARNING count изменился: было $w_base → стало $w_today"
  else
    ok "WARNING count не изменился: $w_today"
  fi

  if grep -q 'PROMISC' "$TODAY_LOG"; then
    warn "chkrootkit сообщил о PROMISC/packet sniffer (проверь вывод ifpromisc в $TODAY_LOG)"
  else
    ok "chkrootkit: признаков PROMISC в отчёте нет"
  fi
}
check_promisc_interfaces() {
  need ip
  if ip -o link | grep -q PROMISC; then
    warn "Есть интерфейсы в PROMISC:\n$(ip -o link | grep PROMISC | sed 's/^/  /')"
  else
    ok "Интерфейсы не в PROMISC (по данным 'ip link')"
  fi
}
check_dpkg_verify() {
  need dpkg
  if dpkg -V net-tools >/dev/null 2>&1; then
    ok "dpkg -V net-tools: без расхождений"
  else
    fail "dpkg -V net-tools: найдены расхождения"; dpkg -V net-tools || true
  fi
}
check_netstat_hash() {
  need sha256sum
  need dpkg-deb
  need apt
  local bin_cur
  bin_cur="$(command -v netstat || true)"
  [[ -z "$bin_cur" ]] && { fail "netstat не найден в PATH"; return 1; }

  local h_cur
  h_cur=$(sha256sum "$bin_cur" | awk '{print $1}')

  pushd "$TMPDIR" >/dev/null
  apt download -y net-tools >/dev/null 2>&1 || apt download net-tools >/dev/null 2>&1 || true
  local deb
  deb="$(ls -1 net-tools_*.deb 2>/dev/null | head -n1 || true)"
  if [[ -z "$deb" ]]; then
    warn "Не удалось скачать net-tools для сверки хэша — пропускаю сравнение"
    popd >/dev/null; return 2
  fi
  dpkg-deb -x "$deb" ./extract
  local h_ref
  if [[ -f ./extract/bin/netstat ]]; then
    h_ref=$(sha256sum ./extract/bin/netstat | awk '{print $1}')
  else
    fail "В пакете не найден эталонный ./extract/bin/netstat"; popd >/dev/null; return 1
  fi
  popd >/dev/null
  if [[ "$h_cur" == "$h_ref" ]]; then
    ok "netstat hash совпадает с эталоном пакета (sha256=$h_cur)"
  else
    fail "netstat hash отличается: текущий=$h_cur, эталон=$h_ref"
  fi
}
run_rkhunter() {
  if command -v rkhunter >/dev/null 2>&1; then
    if rkhunter --versioncheck >/dev/null 2>&1; then :; fi
    if rkhunter --update >/dev/null 2>&1; then :; fi

    if rkhunter --check --sk >/dev/null 2>&1; then
      ok "rkhunter: критичных проблем не обнаружено"
    else
      warn "rkhunter: см. /var/log/rkhunter.log для деталей"
    fi
  else
    warn "rkhunter не установлен — пропускаю эту проверку (apt install rkhunter)"
  fi
}
if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then usage; exit 0; fi
if [[ "${1:-}" == "--set-baseline" ]]; then set_baseline; exit 0; fi
say "== Host Sanity Check =="
run_chkrootkit
diff_chkrootkit
check_promisc_interfaces
check_dpkg_verify
check_netstat_hash
run_rkhunter
say "== Готово =="
