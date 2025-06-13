{ config, lib, ... }:
{
  hardware = lib.mkIf config.graphics.enable {
    bluetooth.enable = true;
    keyboard.qmk.enable = true;
    opentabletdriver.enable = true;
    xpadneo.enable = lib.mkIf config.gaming.enable true;
    graphics.enable = true;
    graphics.enable32Bit = lib.mkDefault true;
    amdgpu.overdrive.enable = true;
    amdgpu.overdrive.ppfeaturemask = "0xffffffff";
  };
}
