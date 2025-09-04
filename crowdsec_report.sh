#!/bin/bash
echo "===== CrowdSec Status Report ====="
echo
echo ">> CrowdSec service status:"
systemctl is-active crowdsec >/dev/null && echo "Active (running)" || echo "Inactive (not running)"
echo
echo ">> CrowdSec version:"
crowdsec -version 2>/dev/null || echo "CrowdSec not found"
echo
if command -v cscli >/dev/null; then
  echo ">> Banned IPs (top 10):"
  cscli decisions list -o raw | head -n 10
else
  echo "cscli not found – cannot list decisions"
fi
echo
echo ">> Decision count:"
cscli decisions list -o raw | wc -l
echo
echo ">> Last 10 alerts:"
cscli alerts list -o raw | head -n 10
echo
echo "===== End of Report ====="
