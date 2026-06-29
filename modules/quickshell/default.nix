{
  outputs,
  ...
}:
let
  moduleName = "quickshell";
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

      brightnessctl-pinenote = lib.getExe (
        pkgs.werapi.mkRemoteWrapper {
          hostname = config.werapi.hostname;
          targetHostname = "pinenote";
          package = outputs.nixosConfigurations.pinenote.pkgs.brightnessctl;
        }
      );
      busctl-pinenote = lib.getExe (
        pkgs.werapi.mkRemoteWrapper {
          hostname = config.werapi.hostname;
          targetHostname = "pinenote";
          package = outputs.nixosConfigurations.pinenote.pkgs.systemd;
          name = "busctl";
        }
      );
      pinenote-screenshot = lib.getExe (
        pkgs.werapi.mkRemoteWrapper {
          hostname = config.werapi.hostname;
          targetHostname = "pinenote";
          package = outputs.nixosConfigurations.pinenote.pkgs.werapi.pinenote-screenshot;
        }
      );

      make-config =
        base:
        pkgs.runCommand "quickshell-config" { } ''
          cp -r ${base}/. $out/
          substituteInPlace $out/common/BrightnessWidget.qml \
            --replace-fail '"brightnessctl"' '"${lib.getExe pkgs.brightnessctl}"'
          substituteInPlace $out/common/PrusaStatus.qml \
            --replace-fail prusa-status ${lib.getExe pkgs.werapi.prusa-status}
          substituteInPlace $out/PinenoteBar.qml \
            --replace-fail usb-tablet ${lib.getExe pkgs.werapi.usb-tablet} \
            --replace-fail brightnessctl-pinenote ${brightnessctl-pinenote} \
            --replace-fail busctl ${busctl-pinenote}
          substituteInPlace $out/common/EinkWidget.qml \
            --replace-fail busctl ${busctl-pinenote} \
            --replace-fail pinenote-screenshot ${pinenote-screenshot}
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
    };
}
