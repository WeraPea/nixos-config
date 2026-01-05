{
  lib,
  writeShellScriptBin,
  wlr-randr,
}:
writeShellScriptBin "rotate-screen" ''
  set -euo pipefail

  usage() {
    echo "Usage: $0 <transform: 0|1|2|3|cw|ccw|switch>" >&2
    exit 1
  }

  [[ $# -ne 1 ]] && usage

  order=(normal 90 180 270)

  current=$(${lib.getExe wlr-randr} --json | jq -r '.[] | select(.name=="DPI-1") | .transform')

  transform=-1
  for i in "''${!order[@]}"; do
    if [[ "''${order[$i]}" == "$current" ]]; then
      transform=$i
      break
    fi
  done

  if [[ $transform -lt 0 ]]; then
    echo "unsupported transform: $current" >&2
    exit 2
  fi

  case "$1" in
    cw)
      transform=$(( (transform + 1) % 4 ))
      ;;
    ccw)
      transform=$(( (transform + 3) % 4 ))
      ;;
    switch)
      if [[ "$current" == "normal" ]]; then
        transform=1
      else
        transform=0
      fi
      ;;
    0|1|2|3)
      transform=$1
      ;;
    *)
      usage
      ;;
  esac
  mmsg -d setoption,monitorrule,DPI-1,0.5,1,tile,$transform,1.5,0,0,1872,1404,84.996002,0,0,0,0
  mmsg -d setoption,tablet_rotation,$transform
''
