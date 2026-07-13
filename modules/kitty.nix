{
  flake,
  ...
}:
let
  moduleName = "kitty";
in
{
  flake.wrappers.kitty =
    {
      lib,
      pkgs,
      wlib,
      ...
    }:
    {
      imports = [
        wlib.wrapperModules.kitty
      ];
      keybindings = {
        "ctrl+shift+n" = "new_tab !neighbor";
        "ctrl+shift+m" = "new_tab_with_cwd !neighbor";

        "alt+h" = "previous_tab";
        "alt+l" = "next_tab";

        "shift+alt+h" = "move_tab_backward";
        "shift+alt+l" = "move_tab_forward";

        "ctrl+shift+h" = "previous_tab";
        "ctrl+shift+l" = "next_tab";

        "kitty_mod+k" = "change_font_size all +1.0";
        "kitty_mod+j" = "change_font_size all -1.0";
      };
      settings = {
        placement_strategy = "top-left";
        shell_integration = "no-sudo";

        confirm_os_window_close = 2;
        allow_remote_control = "yes";

        cursor = "none";

        tab_bar_edge = "top";
        tab_bar_min_tabs = 1;
        tab_bar_style = "powerline";
        tab_title_template = "{fmt.fg.red}{bell_symbol}{activity_symbol}{fmt.fg.tab}{index}:{title[:15]}";
        clipboard_control = "write-clipboard write-primary read-clipboard read-primary";
        scrollback_pager = "${lib.getExe pkgs.nvimpager} -p";
      };
    };
  flake.modules.${moduleName}.nixos =
    {
      config,
      lib,
      ...
    }:
    let
      cfg = config.werapi.${moduleName};
    in
    {
      imports = [
        flake.wrappers.kitty.install
      ];
      options.werapi.${moduleName} = {
        enable = lib.mkOption {
          default = config.werapi.graphics.enable;
          description = "Whether to enable ${moduleName}.";
          type = lib.types.bool;
        };
      };
      config =
        let
          theme = config.lib.stylix.colors {
            templateRepo = config.stylix.inputs.tinted-kitty;
            target = "base16";
          };
        in
        with config.lib.stylix.colors.withHashtag;
        lib.mkIf cfg.enable {
          wrappers.kitty = {
            font = {
              inherit (config.stylix.fonts.monospace) name;
              size = config.stylix.fonts.sizes.terminal;
            };
            settings.background_opacity = with config.stylix.opacity; "${toString terminal}";
            extraConfig = ''
              include ${theme}
              active_tab_background   ${blue}
              active_tab_foreground   ${base00}
              inactive_tab_background ${base00}
              inactive_tab_foreground ${base05}
              tab_bar_background      ${base00}
            '';
          };
          environment.systemPackages = [ config.wrappers.kitty.wrapper ];
        };
    };
}
