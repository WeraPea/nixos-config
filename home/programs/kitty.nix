{
  pkgs,
  lib,
  config,
  ...
}:
{
  options = {
    kitty.enable = lib.mkEnableOption "enables kitty";
  };
  config =
    let
      theme = config.lib.stylix.colors {
        templateRepo = config.lib.stylix.templates.base16-kitty;
        target = "default";
      };
    in
    with config.lib.stylix.colors.withHashtag;
    lib.mkIf config.kitty.enable {
      stylix.targets.kitty.enable = false;
      programs.kitty = {
        enable = true;
        shellIntegration.mode = "no-sudo";
        keybindings = {
          "ctrl+shift+n" = "new_tab !neighbor";
          "ctrl+shift+m" = "new_tab_with_cwd !neighbor";

          "alt+h" = "previous_tab";
          "alt+l" = "next_tab";

          "shift+alt+h" = "move_tab_backward";
          "shift+alt+l" = "move_tab_forward";

          "ctrl+shift+h" = "previous_tab";
          "ctrl+shift+l" = "next_tab";

          "kitty_mod+k" = "change_font_size all +2.0";
          "kitty_mod+j" = "change_font_size all -2.0";
        };
        settings = {
          placement_strategy = "top-left";
          shell = "fish";

          confirm_os_window_close = 2;
          allow_remote_control = "yes";

          cursor = "none";

          tab_bar_edge = "top";
          tab_bar_min_tabs = 1;
          tab_bar_style = "powerline";
          tab_title_template = "{fmt.fg.red}{bell_symbol}{activity_symbol}{fmt.fg.tab}{index}:{title[:15]}";
        };
        font = {
          inherit (config.stylix.fonts.monospace) package name;
          size = config.stylix.fonts.sizes.terminal;
        };
        settings.background_opacity = with config.stylix.opacity; "${builtins.toString terminal}";
        extraConfig = ''
          include ${theme}
          active_tab_background   ${blue}
          active_tab_foreground   ${base00}
          inactive_tab_background ${base00}
          inactive_tab_foreground ${base05}
          tab_bar_background      ${base00}
        '';
      };
    };
}
