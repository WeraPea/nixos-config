# shellcheck shell=bash
search=$(tac ~/.cache/search-hist | rofi -dmenu -p "Search")
if [ "$search" = "" ]; then
  exit
fi

# delete a line that ONLY contains the search and no other text
sed -i "/^$search$/d" ~/.cache/search-hist

echo "$search" >>~/.cache/search-hist

words=$(echo "$search" | cut -d " " -f 2-)
first_word=$(echo "$search" | cut -d " " -f 1)

case "$first_word" in
"h")
  "$BROWSER" "$words"
  ;;
"n")
  nyaasi "$words"
  ;;
"") exit ;;
*)
  "$BROWSER" "https://duckduckgo.com/$first_word $words"
  ;;
esac
