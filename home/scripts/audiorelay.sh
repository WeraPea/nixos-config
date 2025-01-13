# shellcheck shell=bash
pgrep -f "$(basename "$0")" | grep -v "^$$\$" | while read -r pid; do
  kill "$pid"
done

sleep 1

cleanup() {
  kill "$(jobs -p)" -9 2>/dev/null
  @pactl@ unload-module "$sink"
  @pactl@ unload-module "$source"
  exit 0
}

trap cleanup EXIT

if ! @pactl@ list modules | grep Virtual-Mic-Sink; then
  sink=$(@pactl@ load-module module-null-sink \
    sink_name=audiorelay-virtual-mic-sink \
    sink_properties=device.description=Virtual-Mic-Sink)
fi

if ! @pactl@ list modules | grep Virtual-Mic-Source; then
  source=$(@pactl@ load-module module-remap-source \
    master=audiorelay-virtual-mic-sink.monitor \
    source_name=audiorelay-virtual-mic-source \
    source_properties=device.description=Virtual-Mic-Source)
fi

@xvfb@ :9 -screen 0 1000x1000x24 & # switch to Xephyr for debuging
DISPLAY=:9
audio-relay &

sleep 1

AUDIORELAY_WIN=$(@xdotool@ search --name "AudioRelay")
@xdotool@ windowmove "$AUDIORELAY_WIN" 0 0
@xdotool@ windowsize "$AUDIORELAY_WIN" 1000 1000

@xdotool@ mousemove 100 100 click 1 # player
while true; do
  @xdotool@ mousemove 400 800 click 1 # connect to device
  sleep 1
done &

wait
