#!/bin/sh

if $(pamixer --default-source --get-mute); then
  pamixer --default-source --unmute
else
  pamixer --default-source --mute
fi
