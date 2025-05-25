{ pkgs, ... }:
pkgs.writeShellScriptBin "usb-tablet" ''
  #!/usr/bin/env bash
  set -euo pipefail
  if [[ $EUID -ne 0 ]]; then
    echo "error: this script must be run as root" >&2
    exit 1
  fi
  if [[ $(</sys/class/power_supply/rk817-charger/online) -eq 0 ]]; then
    echo "quiting: device not connected"
    exit
  fi

  script_dir="$(cd -- "$(dirname -- "''${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
  CONFIGFS_ROOT=/sys/kernel/config
  GADGET_DIR="$CONFIGFS_ROOT/usb_gadget/g1"
  UDC_DEV=fcc00000.usb

  orig_vt=1
  warm=$(cat /sys/class/backlight/backlight_warm/brightness)
  cool=$(cat /sys/class/backlight/backlight_cool/brightness)

  cleanup_usb() { # || true for when last cleanup was incomplete but was triggered
    echo "" >"$GADGET_DIR/UDC" || true
    rm -f "$GADGET_DIR/configs/c.1/hid.usb0"
    rmdir "$GADGET_DIR/configs/c.1/strings/0x409" || true
    rmdir "$GADGET_DIR/configs/c.1" || true
    rmdir "$GADGET_DIR/functions/hid.usb0" || true
    rmdir "$GADGET_DIR/strings/0x409" || true
    rmdir "$GADGET_DIR" || true
  }

  cleanup() {
    echo cleaning...
    echo "$warm" >/sys/class/backlight/backlight_warm/brightness
    echo "$cool" >/sys/class/backlight/backlight_cool/brightness
    chvt "$orig_vt"
    kill "$usb_pid" 2>/dev/null || true
    kill "$udev_pid" 2>/dev/null || true
    cleanup_usb
    echo clean
    trap - EXIT
    exit
  }
  trap cleanup INT TERM EXIT

  openvt -f -c 3 -- bash -c 'echo 0 > /sys/class/graphics/fbcon/cursor_blink'
  chvt 3

  echo 0 >/sys/class/backlight/backlight_warm/brightness
  echo 0 >/sys/class/backlight/backlight_cool/brightness

  modprobe libcomposite

  cd "$CONFIGFS_ROOT/usb_gadget"

  if [ -d "$GADGET_DIR" ]; then
    cleanup_usb
  fi

  mkdir g1
  cd g1

  echo 0x1d6b >idVendor  # Linux Foundation
  echo 0x0104 >idProduct # Multifunction Composite Gadget
  echo 0x0100 >bcdDevice # v1.0.0
  echo 0x0200 >bcdUSB    # USB2

  mkdir strings/0x409
  echo "fedcba9876543210" >strings/0x409/serialnumber
  echo "Pine64" >strings/0x409/manufacturer
  echo "PineNote" >strings/0x409/product

  mkdir configs/c.1
  mkdir configs/c.1/strings/0x409
  echo "Conf 1" >configs/c.1/strings/0x409/configuration
  echo 250 >configs/c.1/MaxPower

  mkdir functions/hid.usb0
  echo 2 >functions/hid.usb0/protocol
  echo 1 >functions/hid.usb0/subclass
  echo 15 >functions/hid.usb0/report_length
  cat /sys/bus/hid/devices/0018\:2D1F\:0095.0001/report_descriptor >functions/hid.usb0/report_desc

  ln -s functions/hid.usb0 configs/c.1/
  echo "$UDC_DEV" >UDC

  cat /dev/hidraw0 >/dev/hidg0 &
  usb_pid="$!"
  echo activated

  exec 3< <(udevadm monitor --udev --subsystem-match=power_supply)
  udev_pid="$!"

  while read -r line <&3; do
    [[ "$line" == *rk817-charger* ]] || continue
    status=$(</sys/class/power_supply/rk817-charger/online)
    if [ "$status" = "0" ]; then
      kill -INT "$usb_pid"
      kill "$udev_pid"
      exit
    fi
  done
''
