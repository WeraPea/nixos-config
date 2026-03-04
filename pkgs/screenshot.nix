{
  lib,
  writeShellScriptBin,
  grim,
  rofi,
  slurp,
  wl-clipboard,
}:
writeShellScriptBin "screenshot" ''
  export PATH="${
    lib.makeBinPath ([
      grim
      rofi
      slurp
      wl-clipboard
    ])
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
  # "selected window") hyprshot -m window -o /tmp/ -f hyprshot_screenshot.png ;;
  "full screen")
    [[ $rofi_used == 1 ]] && sleep 0.2
    grim /tmp/grim_screenshot.png
    ;;
  "current monitor")
    [[ $rofi_used == 1 ]] && sleep 0.2
    output=$(mmsg -g -o | grep "selmon 1" | cut -d' ' -f1)
    grim -o "$output" /tmp/grim_screenshot.png
    ;;
  "selected monitor") slurp -o | grim -g - /tmp/grim_screenshot.png ;;
  "current window")
    [[ $rofi_used == 1 ]] && sleep 0.2
    output=$(mmsg -g -o | grep "selmon 1" | cut -d' ' -f1)
    geometry=$(mmsg -x -o "$output" | awk '/^x /{x=$2} /^y /{y=$2} /^width /{w=$2} /^height /{h=$2} END{print x","y" "w"x"h}')
    grim -g "$geometry" /tmp/grim_screenshot.png
    ;;
  *) exit ;;
  esac

  file -f /tmp/grim_screenshot.png >/dev/null 2>&1 && cat /tmp/grim_screenshot.png | wl-copy

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

  mv /tmp/grim_screenshot.png ~/Pictures/"$name".png
''
