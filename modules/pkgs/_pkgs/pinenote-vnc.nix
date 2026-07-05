{
  lib,
  writeShellScriptBin,
  jq,
  wayvnc,
  wlr-randr,
}:
writeShellScriptBin "pinenote-vnc" ''
  export PATH="${
    lib.makeBinPath [
      jq
      wayvnc
      wlr-randr
    ]
  }:$PATH"

  display=$(wlr-randr | grep HEADLESS- | cut -d' ' -f1 | grep HEADLESS-)
  if [[ "$display" == "" ]]; then
    mmsg dispatch create_virtual_output
    display=$(wlr-randr | grep HEADLESS- | cut -d' ' -f1 | grep HEADLESS-)
    wlr-randr --output $display --below DP-2 --custom-mode 1872x1404 --scale 1.5
  fi
  transform=$(wlr-randr --json | jq -r --arg name "$display" '.[] | select(.name == $name) | .transform')
  mmsg dispatch setoption,tablet_map_to_mon,$display
  mmsg dispatch setoption,touchscreen_map_to_mon,$display
  wayvnc 0.0.0.0 5900 --output $display --render-cursor & wpid=$!;
  ssh -t pinenote "sh -c '
    trap \"\" INT
    export WAYLAND_DISPLAY=wayland-0
    transform=\$(wlr-randr --json | jq -r \'.[] | select(.name == \"DPI-1\") | .transform\')
    wlr-randr --output DPI-1 --scale 1 --transform $transform
    vncviewer nixos.lan:5900 -display=:0 -LowColorLevel 1 -FullScreen -AutoSelect off -ViewOnly & sudo pinenote-usb-tablet --use-touchscreen --product 0096
    wlr-randr --output DPI-1 --scale 1.5 --transform \$transform
    '"
  kill $wpid
''
