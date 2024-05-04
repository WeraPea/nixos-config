{ pkgs, ... }:
{
  hardware.firmware = [
    (pkgs.writeTextDir "/lib/firmware/hda-jack-retask.fw" (builtins.readFile ./hda-jack-retask.fw))
  ];
  boot.extraModprobeConfig = ''
    options snd-hda-intel patch=hda-jack-retask.fw
  '';
}
