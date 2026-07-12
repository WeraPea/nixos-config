{
  lib,
  writeShellScriptBin,
  jq,
  netevent,
  wayvnc,
  wlr-randr,
}:
writeShellScriptBin "pinenote-vnc" ''
  export PATH="${
    lib.makeBinPath [
      jq
      netevent
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
  if [ "$1" == "usb" ]; then
    input="sudo pinenote-usb-tablet --use-touchscreen --product 0096"
  else
    # input="sudo netevent daemon -s <(echo -e \"device add touch /dev/input/by-path/platform-fe5e0000.i2c-event\n device add tablet /dev/input/\$(exa -d1 /sys/class/input/event*/device/name | xargs grep -l \"w9013 2D1F:0095 Stylus\" | cut -d/ -f5)\n output add nixos exec:ssh wera@nixos $(which netevent) create\n use nixos\n grab-devices on\n write-events on\n\") /tmp/netevent-vnc.sock"
    input='tmpcfg=$(mktemp); stylus_event=$(grep -l "w9013 2D1F:0095 Stylus" /sys/class/input/event*/device/name | cut -d/ -f5); cat > "$tmpcfg" <<EOF
  device add touch /dev/input/by-path/platform-fe5e0000.i2c-event
  device add tablet /dev/input/$stylus_event
  output add nixos exec:ssh wera@nixos '"$(which netevent)"' create
  use nixos
  grab-devices on
  write-events on
  EOF
  sudo netevent daemon -s "$tmpcfg" /tmp/netevent-vnc.sock; rm -f "$tmpcfg"'
    # trap="" # socat READLINE UNIX-CONNECT:netevent-command.sock
  fi
  ssh -t pinenote "sh -c '
    trap \"\" INT
    export WAYLAND_DISPLAY=wayland-0
    transform=\$(wlr-randr --json | jq -r \'.[] | select(.name == \"DPI-1\") | .transform\')
    wlr-randr --output DPI-1 --scale 1 --transform $transform
    vncviewer nixos.lan:5900 -display=:0 -LowColorLevel 1 -FullScreen -AutoSelect off -ViewOnly & $input
    wlr-randr --output DPI-1 --scale 1.5 --transform \$transform
    '"
  kill $wpid
''
