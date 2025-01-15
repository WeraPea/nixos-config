# shellcheck shell=bash
if [[ -z $1 ]]; then
  ANDROID_IP=$(cat "$HOME"/.config/android_ip)
else
  ANDROID_IP="$1"
fi
adb connect "$ANDROID_IP":"$(nmap -sT "$ANDROID_IP" -p30000-49999 | awk -F/ '/tcp open/{print $1}')"
