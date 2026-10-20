{
  flake,
  outputs,
  ...
}:
let
  moduleName = "quickshell";
in
{
  flake.wrappers.quickshell =
    {
      config,
      lib,
      pkgs,
      wlib,
      ...
    }:
    {
      imports = [
        wlib.wrapperModules.quickshell
      ];
      options = {
        path = lib.mkOption {
          type = lib.types.listOf lib.types.package;
          default = [ ];
        };
      };
      config = {
        configDir = ./shell;
        env.PINENOTE_COLORS_CONFIG =
          outputs.nixosConfigurations.pinenote.config.stylix.generated.fileTree."stylix/palette.json".source;
        env.QS_ICON_THEME = "breeze-dark";
        path = with pkgs; [
          brightnessctl
          werapi.prusa-status
          werapi.usb-tablet
          werapi.rotate
        ];
        suffixVar = [
          [
            "PATH"
            ":"
            "${lib.makeBinPath (config.path)}"
          ]
        ];
      };
    };
  flake.devshells.quickshell =
    {
      lib,
      pkgs,
      mkShell,
      quickshell,
    }:
    let
      qs = flake.wrappers.quickshell.eval { inherit pkgs; };
    in
    mkShell {
      packages = qs.config.path ++ [ quickshell ];
      shellHook = ''
        export PINENOTE_COLORS_CONFIG=${lib.escapeShellArg qs.config.env.PINENOTE_COLORS_CONFIG.data}
        export QS_ICON_THEME="breeze-dark"
      '';
    };

  flake.modules.${moduleName}.nixos =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.werapi.${moduleName};

      brightnessctl-pinenote = pkgs.werapi.mkRemoteWrapper {
        hostname = config.werapi.hostname;
        targetHostname = "pinenote";
        suffix = "-pinenote";
        package = outputs.nixosConfigurations.pinenote.pkgs.brightnessctl;
      };
      busctl-pinenote = pkgs.werapi.mkRemoteWrapper {
        hostname = config.werapi.hostname;
        targetHostname = "pinenote";
        suffix = "";
        package = outputs.nixosConfigurations.pinenote.pkgs.systemd;
        name = "busctl";
      };
      pinenote-screenshot = pkgs.werapi.mkRemoteWrapper {
        hostname = config.werapi.hostname;
        targetHostname = "pinenote";
        suffix = "";
        package = outputs.nixosConfigurations.pinenote.pkgs.werapi.pinenote-screenshot;
      };
    in
    {
      imports = [
        flake.wrappers.quickshell.install
      ];
      options.werapi.${moduleName} = {
        enable = lib.mkOption {
          default = config.werapi.graphics.enable;
          description = "Whether to enable ${moduleName}.";
          type = lib.types.bool;
        };
      };
      config = lib.mkIf cfg.enable {
        wrappers.quickshell.path = [
          brightnessctl-pinenote
          busctl-pinenote
          pinenote-screenshot
        ];
        environment.systemPackages = [
          pkgs.quickshell
          (pkgs.runCommand "qs-wrapped" { } ''
            mkdir -p $out/bin
            ln -s ${config.wrappers.quickshell.wrapper}/bin/quickshell $out/bin/qs-wrapped
          '')
        ];
        systemd.user.services.quickshell = {
          wantedBy = [ "graphical-session.target" ];
          after = [ "graphical-session.target" ];
          path = lib.mkForce [ ]; # use default systemd user env path
          serviceConfig = {
            ExecStart = lib.getExe' config.wrappers.quickshell.wrapper "quickshell";
            Restart = "on-failure";
          };
        };
      };
    };
}
