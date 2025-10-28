# shellcheck shell=bash
case "$(printf 'selected area\nselected window\nfull screen\ncurrent monitor\nselected monitor\nselected area to text' | rofi -dmenu -l 6 -i -p "Screenshot which area?")" in
"selected area") slurp | grim -g - /tmp/grim_screenshot.png ;;
# "selected window") hyprshot -m window -o /tmp/ -f hyprshot_screenshot.png ;;
"full screen")
  sleep 0.2
  grim /tmp/grim_screenshot.png
  ;;
"current monitor")
  sleep 0.2
  output=$(mmsg -g -o | grep "selmon 1" | cut -d' ' -f1)
  grim -o "$output" /tmp/hyprshot_screenshot.png
  ;;
# "selected monitor")
#   sleep 0.2
#   grim /tmp/hyprshot_screenshot.png
#   ;;
"selected area to text") slurp | grim -g - /tmp/grim_screenshow_to_text.png ;;
*) exit ;;
esac

file /tmp/grim_screenshot.png && cat /tmp/grim_screenshot.png | wl-copy

sleep 0.1
if test -f /tmp/grim_screenshow_to_text.png; then
  mogrify -modulate 100,0 -resize 400% /tmp/grim_screenshow_to_text.png
  magick convert /tmp/grim_screenshow_to_text.png -colorspace Gray /tmp/grim_screenshot_to_text_grayscale.png
  tesseract -l "$(printf 'eng\njpn' | rofi -dmenu -l 2)" /tmp/grim_screenshot_to_text_grayscale.png /tmp/tesseract_screenshot &>/dev/null
  tr '\n' ' ' </tmp/tesseract_screenshot.txt | wl-copy
  rm /tmp/tesseract_screenshot.txt /tmp/grim_screenshot_to_text.png /tmp/grim_screenshot_to_text_grayscale.png
  exit
fi

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
