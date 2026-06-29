{
  lib,
  writeShellScriptBin,
  bc,
  jq,
  wlr-randr,
}:
writeShellScriptBin "rotate-screen" ''
  set -euo pipefail

  export PATH="${
    lib.makeBinPath [
      bc
      jq
      wlr-randr
    ]
  }:$PATH"

  usage() {
    echo "Usage: $0 <transform: 0|1|2|3|cw|ccw|switch|auto> <output> [sensor path]" >&2
    exit 1
  }

  [[ $# -lt 2 || $# -gt 3 ]] && usage

  [[ $# -ne 3 ]] && BASE=/sys/bus/iio/devices/iio:device1 || BASE="$3"

  order=(normal 90 180 270)

  current=$(wlr-randr --json | jq -r --arg name "$2" '.[] | select(.name==$name) | .transform')

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
    auto) # for now assumes pinenote
      x_raw=$(cat $BASE/in_accel_x_raw)
      y_raw=$(cat $BASE/in_accel_y_raw)
      z_raw=$(cat $BASE/in_accel_z_raw)
      x_scale=$(cat $BASE/in_accel_x_scale)
      y_scale=$(cat $BASE/in_accel_y_scale)
      z_scale=$(cat $BASE/in_accel_z_scale)

      # matrix: -1,0,0; 0,1,0; 0,0,1 (x inverted)
      x=$(echo "-1 * $x_raw * $x_scale" | bc -l)
      y=$(echo "$y_raw * $y_scale" | bc -l)
      z=$(echo "$z_raw * $z_scale" | bc -l)

      # normalize
      norm=$(echo "sqrt($x*$x + $y*$y + $z*$z)" | bc -l)
      x=$(echo "$x / $norm" | bc -l)
      y=$(echo "$y / $norm" | bc -l)

      if (( $(echo "$y < -0.5" | bc -l) )); then
        transform=0
      elif (( $(echo "$y > 0.5" | bc -l) )); then
        transform=2
      elif (( $(echo "$x < -0.5" | bc -l) )); then
        transform=3
      else
        transform=1
      fi
      ;;
    *)
      usage
      ;;
  esac

  # can't use wlr-randr for rotation as mango will reset it on any option change
  mmsg dispatch setoption,monitorrule,$(wlr-randr --json | jq -r --arg name "$2" '
    .[]
    | select(.name==$name)
    | . as $o
    | ($o.modes[] | select(.current==true)) as $m
    | "name:\($o.name),scale:\($o.scale),x:\($o.position.x),y:\($o.position.y),width:\($m.width),height:\($m.height),refresh:\($m.refresh)"
  '),rr:$transform
''
