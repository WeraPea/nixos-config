{
  pkgs,
  config,
  lib,
  ...
}:
lib.mkIf config.hyprland.enable {
  systemd.user.services.hyprland-autoname-workspaces = {
    Unit = {
      Description = "hyprland-autoname-workspaces";
      After = [ "graphical-session-pre.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${lib.getExe pkgs.hyprland-autoname-workspaces} --config ~/.config/hypr/hyprworkspaces.toml";
      Restart = "always";
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
