{
  writeShellScriptBin,
}:
writeShellScriptBin "pinenote-dither-sync" ''
  # initial sync
  output=$(busctl --user get-property org.pinenote.PineNoteCtl /org/pinenote/PineNoteCtl org.pinenote.Ebc1 DefaultHintHr DitherMode | awk 'NR==1{print $2} NR==2{print $2}')
  hint=$(echo "$output" | sed -n '1p' | tr -d '"')
  mode=$(echo "$output" | sed -n '2p')
  echo "$hint" | grep -q '|D' && dither=1 || dither=0
  mmsg -d setoption,dither,"$dither"
  mmsg -d setoption,dither_mode,"$mode"

  busctl --user monitor org.pinenote.PineNoteCtl --json short | while read -r line; do
      hint=$(echo "$line" | jq -r 'select(.type == "signal" and .member == "PropertiesChanged") | .payload.data[1].DefaultHintHr.data // empty')
      mode=$(echo "$line" | jq -r 'select(.type == "signal" and .member == "PropertiesChanged") | .payload.data[1].DitherMode.data // empty')
      if [ -n "$hint" ]; then
          echo "$hint" | grep -q '|D' && dither=1 || dither=0
          mmsg -d setoption,dither,"$dither"
      fi
      if [ -n "$mode" ]; then
          mmsg -d setoption,dither_mode,"$mode"
      fi
  done
''
