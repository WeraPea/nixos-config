let
  moduleName = "hardware";
in
{
  flake.modules.${moduleName}.nixos =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.werapi.${moduleName};
    in
    {
      options.werapi.${moduleName} = {
        enable = lib.mkOption {
          default = config.werapi.graphics.enable;
          description = "Whether to enable ${moduleName}.";
          type = lib.types.bool;
        };
      };
      config = lib.mkIf cfg.enable {
        hardware = {
          bluetooth.enable = true;
          keyboard.qmk.enable = true;
          opentabletdriver.enable = true;
          xpadneo.enable = lib.mkIf config.werapi.gaming.enable true;
          graphics.enable = true;
          graphics.enable32Bit = lib.mkIf (pkgs.stdenv.hostPlatform.system == "x86_64-linux") (
            lib.mkDefault true
          );
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
        systemd.services.rebind-rgbs = {
          wantedBy = [ "post-resume.target" ];
          after = [ "post-resume.target" ];
          serviceConfig = {
            Type = "oneshot";
            ExecStart = pkgs.writeShellScript "rebind-rgbs" ''
              for d in /sys/bus/usb/devices/*/serial; do
                if (grep 9563533303135111E131 "$d"); then
                  BUS_ID="$(basename "$(dirname "$d")")"
                fi
              done
              if [ -n "$BUS_ID" ]; then
                echo "$BUS_ID" > /sys/bus/usb/drivers/usb/unbind
                sleep 1
                echo "$BUS_ID" > /sys/bus/usb/drivers/usb/bind
              fi
            '';
          };
        };
      };
    };
}
