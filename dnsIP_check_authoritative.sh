#!/bin/bash
IP="$1"
DOMAIN="$2"
if [ -z "$IP" ] || [ -z "$DOMAIN" ]; then
  echo "Usage: $0 <dns-server-ip> <domain>"
  exit 1
fi
echo "🔍 Checking if $IP is authoritative for $DOMAIN"
echo
OUT=$(dig @"$IP" "$DOMAIN" NS +norecurse)
echo "$OUT" | grep -E "^;; flags:|^;; ->|^$|^$DOMAIN|^;; ANSWER SECTION:|^;; AUTHORITY SECTION:|^$"
if echo "$OUT" | grep -q "flags:.* aa[ ;]"; then
  echo
  echo "$IP is AUTHORITATIVE for $DOMAIN"
else
  echo
  echo "$IP is NOT authoritative for $DOMAIN"
fi
