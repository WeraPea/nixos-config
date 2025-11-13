{
  pkgs,
  config,
  lib,
  ...
}:
lib.mkIf config.graphics.enable {
  hardware = {
    bluetooth.enable = true;
    keyboard.qmk.enable = true;
    opentabletdriver.enable = true;
    xpadneo.enable = lib.mkIf config.gaming.enable true;
    graphics.enable = true;
    graphics.enable32Bit = lib.mkDefault true;
  };
  systemd.services.bluetooth-resume-cleanup = {
    description = "Restart bluetooth after resume to remove stale devices from UPower";
    wantedBy = [ "post-resume.target" ];
    after = [ "post-resume.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.systemd}/bin/systemctl restart bluetooth.service";
    };
  };
}
