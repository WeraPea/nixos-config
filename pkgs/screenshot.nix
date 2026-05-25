{
  lib,
  writeShellScriptBin,
  grim,
  jq,
  rofi,
  slurp,
  wl-clipboard,
}:
writeShellScriptBin "screenshot" ''
  export PATH="${
    lib.makeBinPath [
      grim
      jq
      rofi
      slurp
      wl-clipboard
    ]
  }:$PATH"

  if [[ -n "$1" ]]; then
    choice="$1"
    rofi_used=0
  else
    choice="$(printf 'selected area\nfull screen\ncurrent monitor\nselected monitor\ncurrent window' | rofi -dmenu -l 6 -i -p "Screenshot which area?")"
    rofi_used=1
  fi

  case $choice in
  "selected area") slurp | grim -g - /tmp/grim_screenshot.png ;;
  "selected window")
    jq -r -n \
      --argjson monitors "$(mmsg get all-monitors)" \
      --argjson clients "$(mmsg get all-clients)" \
      '$clients.clients[] | select(
        . as $client |
        $monitors.monitors[] | select(.name == $client.monitor) | .active_tags as $active_tags |
        $client.tags | any(IN($active_tags[]))
      ) | "\\(.x),\\(.y) \\(.width)x\\(.height)"
      ' | slurp -r | grim -g - /tmp/grim_screenshot.png
    ;;
  "full screen")
    [[ $rofi_used == 1 ]] && sleep 0.2
    grim /tmp/grim_screenshot.png
    ;;
  "current monitor")
    [[ $rofi_used == 1 ]] && sleep 0.2
    output=$(mmsg get all-monitors | jq -r ".monitors[] | select(.active) | .name")
    grim -o "$output" /tmp/grim_screenshot.png
    ;;
  "selected monitor") slurp -o | grim -g - /tmp/grim_screenshot.png ;;
  "current window")
    [[ $rofi_used == 1 ]] && sleep 0.2
    geometry=$(mmsg get all-monitors | jq -r '.monitors[] | select(.active) | "\(.x),\(.y) \(.width)x\(.height)"')
    grim -g "$geometry" /tmp/grim_screenshot.png
    ;;
  *) exit ;;
  esac

  file -f /tmp/grim_screenshot.png >/dev/null 2>&1 && cat /tmp/grim_screenshot.png | wl-copy


  if [[ -n "$2" ]]; then
    out_path="$2"
  else
    while true; do
      name=$(rofi -dmenu -p "Filename" -lines 0 -width 30)

      if [ "$name" == "" ]; then
        cancel=$(echo -en "No\nYes" | rofi -dmenu -p "Cancel?" -lines 2 -width 30)
        if [ "$cancel" != "No" ]; then
          rm /tmp/grim_screenshot.png
          exit
        fi
      fi

      if ! test -f ~/Pictures/"$name".png; then
        break
      fi

      overwrite=$(echo -en "No\nYes" | rofi -dmenu -p "Do you want to overwrite $name.png?" -lines 2 -width 30)

      if [ "$overwrite" == "Yes" ]; then
        break
      fi
    done
    out_path = ~/Pictures/"$name".png
  fi

  mv /tmp/grim_screenshot.png $out_path
''
