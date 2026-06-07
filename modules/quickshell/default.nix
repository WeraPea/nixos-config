{
  config,
  lib,
  outputs,
  pkgs,
  ...
}:
let
  moduleName = "quickshell";
  cfg = config.werapi.${moduleName};

  make-config =
    base: name:
    pkgs.runCommand name { } ''
      mkdir -p $out/common
      cp -r ${base}/. $out
      cp -r ${./common}/. $out/common
      substituteInPlace $out/common/BrightnessWidget.qml \
        --replace-fail brightnessctl ${lib.getExe pkgs.brightnessctl};
      substituteInPlace $out/common/PrusaStatus.qml \
        --replace-fail prusa-status ${
          lib.getExe outputs.packages.${pkgs.stdenv.hostPlatform.system}.prusa-status
        };
    '';

  pinenote-patched = pkgs.runCommand "pinenote-patched" { } ''
    mkdir -p $out
    cp -r ${./pinenote}/* $out
    substituteInPlace $out/Bar.qml \
      --replace-fail rotate-screen ${
        lib.getExe outputs.packages.${pkgs.stdenv.hostPlatform.system}.rotate
      } \
      --replace-fail usb-tablet ${
        lib.getExe outputs.packages.${pkgs.stdenv.hostPlatform.system}.usb-tablet
      }
  '';

  fajita-patched = pkgs.runCommand "fajita-patched" { } ''
    mkdir -p $out
    cp -r ${./fajita}/* $out
    substituteInPlace $out/Bar.qml \
      --replace-fail rotate-screen ${
        lib.getExe outputs.packages.${pkgs.stdenv.hostPlatform.system}.rotate
      }
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
      activeConfig = lib.mkDefault "desktop";
      configs.desktop = make-config ./desktop "desktop";
      configs.pinenote = make-config pinenote-patched "pinenote";
      configs.fajita = make-config fajita-patched "fajita";
      systemd.enable = true;
    };
  };
}
