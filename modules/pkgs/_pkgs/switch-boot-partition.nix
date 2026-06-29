{
  lib,
  writeShellScriptBin,
  parted,
}:
let
  parted' = lib.getExe' parted "parted";
in
writeShellScriptBin "switch-boot-partition" ''
  partitions=$(${parted'} /dev/mmcblk0 print)
  if echo "$partitions" | grep -q "^ 8.*legacy_boot"; then
    active=8
    inactive=9
  elif echo "$partitions" | grep -q "^ 9.*legacy_boot"; then
    active=9
    inactive=8
  else
    echo "Error: No active partition with legacy_boot flag found."
    exit 1
  fi

  echo "Partition $active is active, toggling to partition $inactive"
  ${parted'} /dev/mmcblk0 set $inactive legacy_boot on
  ${parted'} /dev/mmcblk0 set $active legacy_boot off
''
