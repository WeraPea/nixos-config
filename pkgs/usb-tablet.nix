{ lib, pkgs, ... }:
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

  orig_vt=1
  warm=$(cat /sys/class/backlight/backlight_warm/brightness)
  cool=$(cat /sys/class/backlight/backlight_cool/brightness)

  cleanup() {
    echo cleaning...
    echo "$warm" >/sys/class/backlight/backlight_warm/brightness
    echo "$cool" >/sys/class/backlight/backlight_cool/brightness
    chvt "$orig_vt"
    kill -s INT "$usb_pid" 2>/dev/null || true
    kill "$udev_pid" 2>/dev/null || true
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

  ${lib.getExe' pkgs.pinenote-usb-tablet "pinenote-usb-tablet"} &
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
