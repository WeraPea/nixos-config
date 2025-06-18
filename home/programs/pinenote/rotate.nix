{ pkgs, ... }:
pkgs.writeShellScriptBin "rotate-screen" ''
  set -euo pipefail

  usage() {
    echo "Usage: $0 <transform: 0|1|2|3|cw|ccw|switch>" >&2
    exit 1
  }

  [[ $# -ne 1 ]] && usage

  case "$1" in
    cw)
      transform=$(hyprctl monitors -j | jq '.[] | select(.name == "DPI-1") | .transform')
      transform=$(( (transform + 1) % 4 ))
      ;;
    ccw)
      transform=$(hyprctl monitors -j | jq '.[] | select(.name == "DPI-1") | .transform')
      transform=$(( (transform + 3) % 4 ))
      ;;
    switch)
      transform=$(hyprctl monitors -j | jq '.[] | select(.name == "DPI-1") | .transform')
      transform=$(( (transform + 1) % 2 ))
      ;;
    0|1|2|3)
      transform=$1
      ;;
    *)
      usage
      ;;
  esac

  hyprctl keyword input:touchdevice:transform "$(( (transform + 2) % 4 ))"
  hyprctl keyword input:tablet:transform "$transform"
  hyprctl keyword monitor "DPI-1,highrr,0x0,1,transform,$transform"

  sleep 1 # koreader crashes without the wait

  hyprctl output create headless workaround
  hyprctl output remove workaround
  dbus-send --dest=org.pinenote.PineNoteCtl --type=method_call /org/pinenote/PineNoteCtl org.pinenote.Ebc1.GlobalRefresh
''
