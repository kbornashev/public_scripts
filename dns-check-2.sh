#!/bin/bash
DOMAIN="$1"; shift
NAMESERVERS=("$@")
GREEN='\033[0;32m'; RED='\033[0;31m'; YEL='\033[0;33m'; NC='\033[0m'
echo -e "\n=== Проверка NS для домена: $DOMAIN ==="
echo -e "\n[+] Делегирование (1.1.1.1):"
dig +noall +answer NS "$DOMAIN" @1.1.1.1
serials=()
echo -e "\n[+] Проверки NS:"
for ns in "${NAMESERVERS[@]}"; do
  echo -e "\n=== @$ns ==="
  OUT=$(dig +norec @"$ns" "$DOMAIN" SOA +cmd +noall +answer)
  echo "$OUT"

  AA=$(dig +norec @"$ns" "$DOMAIN" SOA +cmd 2>/dev/null | grep "flags:" | sed -E 's/.*flags: ([^ ]+).*/\1/')
  if echo "$AA" | grep -qw aa; then echo -e "${GREEN}AA OK${NC}"; else echo -e "${RED}AA MISSING${NC}"; fi

  S=$(echo "$OUT" | awk '/ SOA /{print $7}')
  [[ -n "$S" ]] && serials+=("$ns:$S")

  if dig +tcp +norec @"$ns" "$DOMAIN" SOA +time=2 +tries=1 >/dev/null; then
    echo -e "${GREEN}TCP OK${NC}"
  else
    echo -e "${RED}TCP FAIL${NC}"
  fi

  if dig @"$ns" "$DOMAIN" AXFR +time=3 +tries=1 >/dev/null 2>&1; then
    echo -e "${RED}AXFR открыт${NC}"
  else
    echo -e "${GREEN}AXFR закрыт${NC}"
  fi

  RA=$(dig @"$ns" google.com A +noall +cmd 2>/dev/null | grep "ra:")
  if echo "$RA" | grep -q "ra: 0"; then
    echo -e "${GREEN}Рекурсия отключена${NC}"
  else
    echo -e "${RED}Рекурсия включена${NC}"
  fi
done
echo -e "\n[+] Сериал SOA на NS:"
printf '%s\n' "${serials[@]}" | sort -t: -k2,2 | sed "s/:/ -> /"
uniq_serials=$(printf '%s\n' "${serials[@]##*:}" | sort -u | wc -l)
if [ "$uniq_serials" -gt 1 ]; then
  echo -e "${RED}Несовпадающие serial на NS!${NC}"
else
  echo -e "${GREEN}Serial совпадает на всех NS${NC}"
fi
