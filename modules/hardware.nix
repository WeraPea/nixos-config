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
        services = {
          udev.packages = with pkgs; [
            platformio-core.udev
            (writeTextDir "lib/udev/rules.d/70-stm32-dfu.rules"
              # udev
              ''
                # DFU (Internal bootloader for STM32 and AT32 MCUs)
                SUBSYSTEM=="usb", ATTRS{idVendor}=="2e3c", ATTRS{idProduct}=="df11", TAG+="uaccess"
                SUBSYSTEM=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="df11", TAG+="uaccess"
              ''
            )
            (writeTextDir "lib/udev/rules.d/99-pinenote-gadget-touch.rules" # udev
              ''
                # for use with OpenTabletDriver
                SUBSYSTEM=="input", ACTION!="remove", KERNEL=="event[0-9]*", ATTRS{id/vendor}=="2d1f", ATTRS{id/product}=="0095", ATTRS{phys}=="usb-*/input1", ENV{LIBINPUT_IGNORE_DEVICE}="0", ENV{LIBINPUT_CALIBRATION_MATRIX}="-1 0 1 0 -1 1", ENV{LIBINPUT_DEVICE_GROUP}="OpenTabletDriver"

                # for use without OpenTabletDriver (different product id)
                SUBSYSTEM=="input", ACTION!="remove", KERNEL=="event[0-9]*", ATTRS{id/vendor}=="2d1f", ATTRS{id/product}=="0096", ATTRS{phys}=="usb-*/input1", ENV{LIBINPUT_CALIBRATION_MATRIX}="-1 0 1 0 -1 1"
                SUBSYSTEM=="input", ACTION!="remove", KERNEL=="event[0-9]*", ATTRS{id/vendor}=="2d1f", ATTRS{id/product}=="0096", ENV{LIBINPUT_DEVICE_GROUP}="pinenote-gadget-touch"
              ''
            )
            (writeTextDir "lib/udev/rules.d/99-arduino-rgbs.rules" # udev
              ''
                SUBSYSTEM=="tty", ATTRS{idVendor}=="2341", ATTRS{idProduct}=="0043", ATTRS{serial}=="9563533303135111E131", SYMLINK+="ttyRGBs", RUN+="${pkgs.coreutils}/bin/stty -F /dev/%k -hupcl"
              ''
            )
          ];
          upower.enable = true;
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
