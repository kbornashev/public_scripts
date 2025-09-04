#!/bin/bash
OUTPUT_FILE="vm_info.txt"
vms=$(pvesh get /cluster/resources --type vm -output-format json | jq -c '.[]')
echo "виртуальные машины:" > "$OUTPUT_FILE"
for vm in $vms;
do
    vmid=$(echo "$vm" | jq -r '.vmid')
    name=$(echo "$vm" | jq -r '.name')
    if pvesh get /nodes/$(hostname)/qemu/$vmid/config &>/dev/null;
    then
        network_data=$(pvesh get /nodes/$(hostname)/qemu/$vmid/status/current --output-format json | jq -c '.data.network // empty')
        if [[ -n "$network_data" ]];
        then
            ip=$(echo "$network_data" | jq -r 'to_entries[] | select(.value["ip-address"] != null) | .value["ip-address"]' | head -n 1)
            echo "VMID: $vmid | Hostname: $name | IP: $ip" >> "$OUTPUT_FILE"
        fi
    fi
done
echo "записано в $OUTPUT_FILE"
