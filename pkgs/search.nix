{
  lib,
  writeShellScriptBin,
  nyaasi,
  rofi,
  searchHistFile ? "~/.cache/search-hist",
}:
writeShellScriptBin "search" ''
  search=$(tac ${searchHistFile} | ${lib.getExe rofi} -dmenu -p "Search")
  if [ "$search" = "" ]; then
    exit
  fi

  # delete a line that ONLY contains the search and no other text
  sed -i "/^$search$/d" ${searchHistFile}

  echo "$search" >> ${searchHistFile}

  words=$(echo "$search" | cut -d " " -f 2-)
  first_word=$(echo "$search" | cut -d " " -f 1)

  case "$first_word" in
  # "h")
  #   "$BROWSER" "$words"
  #   ;;
  "n")
    ${lib.getExe nyaasi} "$words"
    ;;
  "") exit ;;
  # *)
  #   "$BROWSER" "https://duckduckgo.com/$first_word $words"
  #   ;;
  esac
''
