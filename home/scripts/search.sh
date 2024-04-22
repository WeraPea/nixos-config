search=$(cat ~/.cache/search-hist | tac | rofi -dmenu -p "Search")
if [ -z "$search" ]; then
    exit
fi

# delete a line that ONLY contains the search and no other text
sed -i "/^$search$/d" ~/.cache/search-hist

echo $search >> ~/.cache/search-hist

words=$(echo $search | cut -d " " -f 2-)
first_word=$(echo $search | cut -d " " -f 1)

case "$first_word" in
	"t")
		1337x "$words"
		;;
	"rl")
		$BROWSER "https://rutracker.org/forum/tracker.php?nm=$words&f=1992,2059"
		;;
	"r")
		$BROWSER "https://rutracker.org/forum/tracker.php?nm=$words"
		;;
	"a")
		$BROWSER "https://wiki.archlinux.org/index.php?search=$words"
 		;;
	"h")
		$BROWSER "$words"
		;;
	"o")
		$BROWSER "https://osu.ppy.sh/beatmapsets?m=0&q=$words"
		;;
	"y")
		$BROWSER "https://www.youtube.com/results?search_query=$words"
		;;
	"w")
		$BROWSER "https://www.wolframalpha.com/input/?i=$words"
		;;
	"n")
		nyaasi "$words"
		;;
	"") exit ;;
	*)
		$BROWSER "https://duckduckgo.com/$first_word $words"
		;;
esac
