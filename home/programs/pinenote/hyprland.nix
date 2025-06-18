{config, pkgs, lib, ...}:
{
  options = {
    pinenote-hyprland.enable = lib.mkEnableOption "enables pinenote hyprland config";
  };
  config = lib.mkIf config.pinenote-hyprland.enable {
    stylix.targets.hyprpaper.enable = lib.mkForce false;
    services.hyprpaper.enable = lib.mkForce false;
    services.hyprpolkitagent.enable = true;
    wayland.windowManager.hyprland = {
      enable = true;
      xwayland.enable = true;
      settings =
        let
          pamixer = lib.getExe pkgs.pamixer;
        in
        {
          monitor = [
            "DPI-1,highrr,0x0,1"
          ];
          windowrule = [
            "float, title:^(Picture-in-Picture)$"
            "pin, title:^(Picture-in-Picture)$"
            "suppressevent maximize,class:^(mpv)" # fixes mpv switching maximization on/off when switching videos/pictures
            "tag +ebchint:Y4|r:, class:KOReader" # trailing : as hyprland appends "*" to dynamic tags TODO: change this perhaps?
          ];
          workspace = [
            "1,persistent:true,monitor:DPI-1"
            "2,persistent:true,monitor:DPI-1"
            "3,persistent:true,monitor:DPI-1"
          ];
          input = {
            kb_layout = "pl";
            repeat_rate = 100;
            repeat_delay = 300;

            follow_mouse = 1;
          };
          gestures = { # TODO:
            workspace_swipe = true;
            workspace_swipe_forever = true;
          };
          general = {
            gaps_in = 0;
            gaps_out = 0;
            border_size = 0;
            layout = "dwindle";
          };
          decoration = {
            rounding = 0;
            blur = {
              enabled = false;
            };
            # drop_shadow = false;
          };
          cursor = {
            no_warps = true;
          };

          animations.enabled = false;

          dwindle = {
            pseudotile = true;
            preserve_split = true;
          };

          misc = {
            enable_anr_dialog = false;
            disable_hyprland_logo = true;
            new_window_takes_over_fullscreen = true;
            disable_splash_rendering = true;
          };
          env = [
            "NIXOS_OZONE_WL,1"
            "QT_AUTO_SCREEN_SCALE_FACTOR,1"
            "QT_WAYLAND_DISABLE_WINDOWDECORATION,1"
            "SDL_VIDEODRIVER,wayland"
            "XDG_CURRENT_DESKTOP,Hyprland"
            "XDG_SESSION_DESKTOP,Hyprland"
            "XDG_SESSION_TYPE,wayland"
          ]; # TODO: do i still have to do this manually?
          binde = [
            ",XF86AudioLowerVolume, exec, ${pamixer} -d 1"
            ",XF86AudioRaiseVolume, exec, ${pamixer} -i 1"
            "shift,XF86AudioLowerVolume, exec, ${pamixer} -d 1 --allow-boost"
            "shift,XF86AudioRaiseVolume, exec, ${pamixer} -i 1 --allow-boost"
          ];
          bind =
            [
              "super, space, exec, makoctl dismiss"
              "super_shift, space, exec, makoctl restore"
              ",Print, exec, screenshot"
              "shift,Print, exec, hyprshot -m window -c -o /tmp/ -f hyprshot_screenshot.png"
              "super, s, exec, search"
              "super, c, exec, rofi -modi clipboard:cliphist-rofi-img -show clipboard -show-icons"
              "super, o, exec, wl-paste -p | wl-copy"
              "super, p, exec, wl-paste | wl-copy -p"
              "super, d, exec, rofi -show window -show-icons"

              ",XF86AudioMute, exec, ${pamixer} -t"

              ",XF86MonBrightnessUp, exec, brightnessctl set 10%+"
              ",XF86MonBrightnessDown, exec, brightnessctl set 10%-"

              "super, e, togglefloating,"
              "super, w, fullscreen, 1"
              "super, f, fullscreen, 0"
              "super, g, fullscreenstate, 0 3" # fake fullscreen
              "super, v, toggleswallow"

              "super, h, movefocus, l"
              "super, l, movefocus, r"
              "super, k, movefocus, u"
              "super, j, movefocus, d"
            ]
            ++ (builtins.concatLists (
              builtins.genList (
                x:
                let
                  ws = builtins.toString (x + 1);
                in
                [
                  "super, ${ws}, workspace, ${ws}"
                  "super shift, ${ws}, movetoworkspace, ${ws}"
                  "super, f${ws}, workspace, ${toString (x + 6)}"
                  "super shift, f${ws}, movetoworkspace, ${toString (x + 6)}"
                ]
              ) 5
            ));
          bindm = [
            "super, mouse:272, movewindow"
            "super, mouse:273, resizewindow"
          ];
        };
      extraConfig = # hyprlang
        ''
          exec-once = waybar
          bind=super,r,submap,run
          submap=run
          bind = super, r, exec, rofi -show drun -show-icons
          bind = super, r, submap, reset

          bind = super, t, exec, kitty
          bind = super, t, submap, reset

          bind = super, f, exec, firefox
          bind = super, f, submap, reset

          bind = super, s, exec, spotify
          bind = super, s, submap, reset

          bind = ,catchall, submap, reset
          submap=reset

          bind = super, x, submap, mpd
          submap = mpd
          bind = super, x, exec, mpc toggle
          bind = super, x, submap, reset
          bind = super, space, exec, mpc toggle
          bind = super, space, submap, reset
          bind = super, n, exec, mpc next
          bind = super, n, submap, reset
          bind = super, p, exec, mpc prev
          bind = super, p, submap, reset
          bind = super, j, exec, mpc volume -5
          bind = super, j, submap, reset
          bind = super, k, exec, mpc volume +5
          bind = super, k, submap, reset
          bind = ,catchall, submap, reset
          submap = reset

          bind = super, q, submap, kill
          submap = kill
          bind = super, q, killactive,
          bind = super, q, submap, reset
          bind = ,catchall, submap, reset
          submap = reset
        '';
    };
  };
}
