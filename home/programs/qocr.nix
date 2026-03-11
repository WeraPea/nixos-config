{
  lib,
  pkgs,
  config,
  inputs,
  ...
}:

let
  cfg = config.qocr;
  jsonFormat = pkgs.formats.json { };
  qocr = inputs.qocr.packages.${pkgs.stdenv.hostPlatform.system}.qocr;
in
{
  options.qocr = {
    enable = lib.mkEnableOption "qocr";

    settings = lib.mkOption {
      type = jsonFormat.type;
      default = { };
      description = "Configuration written to $XDG_CONFIG_HOME/qocr/config.json.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ qocr ];

    xdg.configFile."qocr/config.json".source = jsonFormat.generate "qocr-config.json" cfg.settings;

    systemd.user.services.qocr = {
      Unit = {
        Description = "qocr";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = lib.getExe qocr;
        Restart = "on-failure";
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
  };
}
