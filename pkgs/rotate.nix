{
  lib,
  writeShellScriptBin,
  wlr-randr,
}:
writeShellScriptBin "rotate-screen" ''
  set -euo pipefail

  usage() {
    echo "Usage: $0 <transform: 0|1|2|3|cw|ccw|switch> <output>" >&2
    exit 1
  }

  [[ $# -ne 2 ]] && usage

  order=(normal 90 180 270)

  current=$(${lib.getExe wlr-randr} --json | jq -r --arg name "$2" '.[] | select(.name==$name) | .transform')

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

  # can't use wlr-randr for rotation as mango will reset it only any option change
  mmsg -d setoption,monitorrule,$(${lib.getExe wlr-randr} --json | jq -r --arg name "$2" '
    .[]
    | select(.name==$name)
    | . as $o
    | ($o.modes[] | select(.current==true)) as $m
    | "name:\($o.name),scale:\($o.scale),x:\($o.position.x),y:\($o.position.y),width:\($m.width),height:\($m.height),refresh:\($m.refresh)"
  '),rr:$transform
  mmsg -d setoption,tablet_rotation,$transform
''
