#!/bin/bash
set -euo pipefail
if [ "$#" -ne 4 ]; then
  echo "Usage: $0 <disk> <vg_name> <lv_name> <remote_host>"
  echo "Example: $0 /dev/sdb om-vg om-lv user@192.168.1.10"
  exit 1
fi
DISK="$1"
VG_NAME="$2"
LV_NAME="$3"
REMOTE="$4"
PARTITION="${DISK}1"
SCRIPT_NAME="/tmp/expand-lvm-$$.sh"
cat << 'EOF' > "$SCRIPT_NAME"
#!/bin/bash
set -euo pipefail
DISK="$1"
PARTITION="${DISK}1"
VG_NAME="$2"
LV_NAME="$3"
PART_NUM="1"
echo "[+] Checking if $PARTITION exists..."
if [ ! -b "$PARTITION" ]; then
  echo "[+] Partition $PARTITION not found, creating on $DISK..."
  sudo parted -s "$DISK" -- mkpart primary ext4 0% 100%
  sudo partprobe "$DISK"
  echo "[+] Waiting for kernel to detect partition..."
  sleep 3
else
  CURRENT_SIZE=$(lsblk -bno SIZE "$PARTITION" | head -n1 | tr -d '[:space:]')
  DISK_SIZE=$(lsblk -bno SIZE "$DISK" | head -n1 | tr -d '[:space:]')
  if [ "$CURRENT_SIZE" -lt "$DISK_SIZE" ]; then
    echo "[+] $PARTITION exists but is smaller than $DISK, resizing partition..."
    sudo parted -s "$DISK" resizepart "$PART_NUM" 100%
    sudo partprobe "$DISK"
    echo "[+] Waiting for kernel to reread partition table..."
    sleep 3
  else
    echo "[+] $PARTITION already uses full disk space."
  fi
fi
echo "[+] Resizing physical volume on $PARTITION..."
sudo pvresize "$PARTITION"
echo "[+] Extending logical volume $VG_NAME/$LV_NAME to use all free space..."
sudo lvextend -r -l +100%FREE "/dev/$VG_NAME/$LV_NAME"
echo "[✓] Done. LVM volume extended and filesystem resized."
EOF
scp "$SCRIPT_NAME" "$REMOTE:$SCRIPT_NAME"
ssh "$REMOTE" "sudo bash $SCRIPT_NAME '$DISK' '$VG_NAME' '$LV_NAME'; sudo rm -f $SCRIPT_NAME"
rm -f "$SCRIPT_NAME"
