{
  config,
  lib,
  pkgs,
  ...
}:
let
  moduleName = "quickshell";
  cfg = config.werapi.${moduleName};

  make-config =
    base:
    pkgs.runCommand "quickshell-config" { } ''
      cp -r ${base}/. $out/
      substituteInPlace $out/common/BrightnessWidget.qml \
        --replace-fail brightnessctl ${lib.getExe pkgs.brightnessctl};
      substituteInPlace $out/common/PrusaStatus.qml \
        --replace-fail prusa-status ${lib.getExe pkgs.werapi.prusa-status};
      substituteInPlace $out/PinenoteBar.qml \
        --replace-fail usb-tablet ${lib.getExe pkgs.werapi.usb-tablet}
      substituteInPlace $out/PinenoteBar.qml $out/FajitaBar.qml \
        --replace-fail rotate-screen ${lib.getExe pkgs.werapi.rotate}
    '';
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
    hm.programs.quickshell = {
      enable = true;
      activeConfig = "default";
      configs.default = make-config ./shell;
      systemd.enable = true;
    };
  };
}
