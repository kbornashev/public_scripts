#!/bin/bash
DOMAIN="$1"
shift
NAMESERVERS=("$@")
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'
echo -e "\n=== Проверка NS для домена: $DOMAIN ==="
echo -e "\n${GREEN}[+] Делегирование в родительской зоне:${NC}"
dig +noall +answer NS "$DOMAIN" @1.1.1.1
echo -e "\n${GREEN}[+] Цепочка делегирования (+trace):${NC}"
dig +trace "$DOMAIN" NS | grep -E "($DOMAIN|NS|A\s)";
for ns in "${NAMESERVERS[@]}"; do
    echo -e "\n=== Проверка: $ns ==="

    SOA=$(dig +norec @"$ns" "$DOMAIN" SOA +noall +answer)
    if [[ -n "$SOA" ]]; then
        echo -e "${GREEN}SOA OK:${NC} $SOA"
    else
        echo -e "${RED}SOA FAIL${NC}"
    fi

    NSLIST=$(dig +norec @"$ns" "$DOMAIN" NS +noall +answer)
    echo -e "${GREEN}NS-записи с $ns:${NC}\n$NSLIST"

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

    REC=$(dig @"$ns" google.com A +noall +cmd 2>/dev/null | grep "ra:")
    if echo "$REC" | grep -q "ra: 0"; then
        echo -e "${GREEN}Рекурсия отключена${NC}"
    else
        echo -e "${RED}Рекурсия включена${NC}"
    fi
done
