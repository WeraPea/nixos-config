# shellcheck shell=bash
if [[ $1 == "unlink" || $1 == "-u" || $1 == "-d" ]]; then m="-d"; fi

pw-link "$m" "alsa_output.pci-0000_18_00.6.analog-stereo:monitor_FL" "alsa_output.pci-0000_03_00.1.hdmi-stereo-extra1:playback_FL" 2>/dev/null
pw-link "$m" "alsa_output.pci-0000_18_00.6.analog-stereo:monitor_FR" "alsa_output.pci-0000_03_00.1.hdmi-stereo-extra1:playback_FR" 2>/dev/null
