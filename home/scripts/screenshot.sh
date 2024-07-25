case "$(printf "selected area\\nselected window\\nfull screen\\nselected area to text" | rofi -dmenu -l 6 -i -p "Screenshot which area?")" in
	"selected area") hyprshot -m region -o /tmp/ -f hyprshot_screenshot.png ;;
	"selected window") hyprshot -m window -o /tmp/ -f hyprshot_screenshot.png ;;
	"full screen") sleep 0.2; hyprshot -m output -o /tmp/ -f hyprshot_screenshot.png ;;
	"selected area to text") hyprshot -m region -o /tmp/ -f hyprshot_screenshot_to_text.png ;;
    *) exit ;;
esac

sleep 0.1
if test -f /tmp/hyprshot_screenshot_to_text.png; then
	mogrify -modulate 100,0 -resize 400% /tmp/hyprshot_screenshot_to_text.png
	tesseract -l $(printf "eng\\njpn" | rofi -dmenu -l 2) /tmp/hyprshot_screenshot_to_text.png /tmp/tesseract_screenshot &> /dev/null
    tr '\n' ' ' </tmp/tesseract_screenshot.txt | wl-copy
	rm /tmp/tesseract_screenshot.txt /tmp/hyprshot_screenshot_to_text.png
	exit
fi

while true; do
	name=$(rofi -dmenu -p "Filename" -lines 0 -width 30)

    if [ "$name" == "" ]; then
        cancel=$(echo -en "No\nYes" | rofi -dmenu -p "Cancel?" -lines 2 -width 30)
        if [ "$cancel" != "No" ]; then
            rm /tmp/hyprshot_screenshot.png
            exit
        fi
    fi

	if ! test -f ~/Pictures/$name.png; then
		break
	fi

	overwrite=$(echo -en "No\nYes" | rofi -dmenu -p "Do you want to overwrite $name.png?" -lines 2 -width 30)

	if [ "$overwrite" == "Yes" ]; then
		break
	fi
done

mv /tmp/hyprshot_screenshot.png ~/Pictures/$name.png
