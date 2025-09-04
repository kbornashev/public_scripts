#!/bin/bash
DOMAIN="$1"
if [ -z "$DOMAIN" ]; then
  echo "Usage: $0 domain.com"
  exit 1
fi
echo "🔍 Checking authoritative name servers for: $DOMAIN"
echo
NS_SERVERS=$(dig +short NS "$DOMAIN")
if [ -z "$NS_SERVERS" ]; then
  echo "❌ No NS records found for $DOMAIN"
  exit 2
fi
for ns in $NS_SERVERS; do
  ns=${ns%.}  # Remove trailing dot
  IPS=$(dig +short "$ns")
  for ip in $IPS; do
    echo "➡️  Querying $ip ($ns)..."
    OUT=$(dig @"$ip" "$DOMAIN" NS +norecurse)
    if echo "$OUT" | grep -q "flags:.* aa[ ;]"; then
      echo "✅ $ip is authoritative for $DOMAIN"
    else
      echo "⚠️  $ip is NOT authoritative for $DOMAIN"
    fi
    echo
  done
done
