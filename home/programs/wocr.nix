{
  lib,
  pkgs,
  config,
  ...
}:

let
  cfg = config.wocr;
  tomlFormat = pkgs.formats.toml { };
in
{
  options.wocr = {
    enable = lib.mkEnableOption "wocr";

    settings = lib.mkOption {
      type = tomlFormat.type;
      default = { };
      description = "Configuration written to $XDG_CONFIG_HOME/wocr/config.toml.";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.user.services.wocr = {
      Unit = {
        Description = "wocr";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = lib.getExe pkgs.wocr;
        Restart = "on-failure";
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };

    xdg.configFile."wocr/config.toml".source = tomlFormat.generate "wocr-config.toml" cfg.settings;

    wocr.settings.overlay.render_text = false;
  };
}
