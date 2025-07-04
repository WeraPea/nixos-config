# shellcheck shell=bash
if [[ $1 == "unlink" || $1 == "-u" || $1 == "-d" ]]; then
  pw-link -d "analog_output_channel_remap:monitor_FL" "alsa_output.pci-0000_03_00.1.hdmi-stereo-extra1:playback_FL" 2>/dev/null
  pw-link -d "analog_output_channel_remap:monitor_FR" "alsa_output.pci-0000_03_00.1.hdmi-stereo-extra1:playback_FR" 2>/dev/null
fi
pw-link "analog_output_channel_remap:monitor_FL" "alsa_output.pci-0000_03_00.1.hdmi-stereo-extra1:playback_FL" 2>/dev/null
pw-link "analog_output_channel_remap:monitor_FR" "alsa_output.pci-0000_03_00.1.hdmi-stereo-extra1:playback_FR" 2>/dev/null
