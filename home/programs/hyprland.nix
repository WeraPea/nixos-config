{
  inputs,
  pkgs,
  lib,
  config,
  osConfig,
  ...
}:
{
  options = {
    hyprland.enable = lib.mkEnableOption "enables hyprland";
    hyprland.touch.enable = lib.mkEnableOption "enables touchscreen options for hyprland";
  };
  config = lib.mkIf config.hyprland.enable {
    home.packages = with pkgs; [
      hyprpicker
      hyprshot
    ];
    services.hyprpaper = {
      enable = true;
    };
    services.hyprpolkitagent.enable = true;
    wayland.windowManager.hyprland = {
      enable = true;
      inherit (osConfig.programs.hyprland) package portalPackage;
      xwayland.enable = true;
      systemd.variables = [ "--all" ];
      plugins = lib.mkIf config.hyprland.touch.enable [
        inputs.hyprgrass.packages.${pkgs.stdenv.hostPlatform.system}.default
      ];
      settings =
        let
          pamixer = lib.getExe pkgs.pamixer;
        in
        {
          monitor = [ ",preferred,auto,1" ];
          windowrulev2 = [
            "float, title:^(Picture-in-Picture)$"
            "pin, title:^(Picture-in-Picture)$"
            "suppressevent maximize,class:^(mpv)" # fixes mpv switching maximization on/off when switching videos/pictures
          ];
          input = {
            kb_layout = "pl";
            repeat_rate = 100;
            repeat_delay = 300;

            follow_mouse = 1;
          };
          layerrule = lib.mkIf (config.hyprland.touch.enable && config.wvkbd.enable) [
            "abovelock true,wvkbd"
          ];
          plugin.touch_gestures = lib.mkIf config.hyprland.touch.enable {
            # The default sensitivity is probably too low on tablet screens,
            # I recommend turning it up to 4.0
            sensitivity = 2.0;

            # must be >= 3
            workspace_swipe_fingers = 3;

            # switching workspaces by swiping from an edge, this is separate from workspace_swipe_fingers
            # and can be used at the same time
            # possible values: l, r, u, or d
            # to disable it set it to anything else
            workspace_swipe_edge = "d";

            # in milliseconds
            long_press_delay = 400;

            # resize windows by long-pressing on window borders and gaps.
            # If general:resize_on_border is enabled, general:extend_border_grab_area is used for floating
            # windows
            resize_on_border_long_press = true;

            # in pixels, the distance from the edge that is considered an edge
            edge_margin = 40;

            # emulates touchpad swipes when swiping in a direction that does not trigger workspace swipe.
            # ONLY triggers when finger count is equal to workspace_swipe_fingers
            #
            # might be removed in the future in favor of event hooks
            emulate_touchpad_swipe = false;

            experimental = {
              # send proper cancel events to windows instead of hacky touch_up events,
              # NOT recommended as it crashed a few times, once it's stabilized I'll make it the default
              send_cancel = 0;
            };
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
          animations = {
            enabled = true;
            animation = [
              "fade,0"
              "workspaces,1,1,default,slide"
              "windows,1,4,default,popin 80%"
            ];
          };
          dwindle = {
            pseudotile = true;
            preserve_split = true;
          };
          misc = {
            enable_anr_dialog = false;
            disable_hyprland_logo = true;
            new_window_takes_over_fullscreen = true;
            disable_splash_rendering = true;
            vrr = 2;
            animate_mouse_windowdragging = true;
            disable_autoreload = true;
            enable_swallow = true;
            swallow_regex = "kitty";
          };
          env = [
            "NIXOS_OZONE_WL,1"
            "QT_AUTO_SCREEN_SCALE_FACTOR,1"
            "QT_WAYLAND_DISABLE_WINDOWDECORATION,1"
            "SDL_VIDEODRIVER,wayland"
            "XDG_CURRENT_DESKTOP,Hyprland"
            "XDG_SESSION_DESKTOP,Hyprland"
            "XDG_SESSION_TYPE,wayland"
          ];
          binds = {
            scroll_event_delay = 0;
          };
          binde = [
            ",XF86AudioLowerVolume, exec, ${pamixer} -d 1"
            ",XF86AudioRaiseVolume, exec, ${pamixer} -i 1"
            "shift,XF86AudioLowerVolume, exec, ${pamixer} -d 1 --allow-boost"
            "shift,XF86AudioRaiseVolume, exec, ${pamixer} -i 1 --allow-boost"
          ];
          bind = [
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

            ",XF86AudioPlay, exec, mpc toggle"
            ",XF86AudioPrev, exec, mpc prev"
            ",XF86AudioNext, exec, mpc next"

            "super, F10, exec, ddccontrol -r 0x10 -W +5 dev:/dev/i2c-7"
            "super, F9, exec, ddccontrol -r 0x10 -W -5 dev:/dev/i2c-7"

            "super, F11, exec, ddccontrol -r 0xe2 -w 5 dev:/dev/i2c-7"
            "super, F12, exec, ddccontrol -r 0xe2 -w 6 dev:/dev/i2c-7"

            "super_shift, F11, exec, ddccontrol -r 0xe5 -W -1 dev:/dev/i2c-7"
            "super_shift, F12, exec, ddccontrol -r 0xe5 -W +1 dev:/dev/i2c-7"

            "super, e, togglefloating,"
            "super, w, fullscreen, 1"
            "super, f, fullscreen, 0"
            "super, g, fullscreenstate, 0 3" # fake fullscreen
            "super, v, toggleswallow"

            "super, h, movefocus, l"
            "super, l, movefocus, r"
            "super, k, movefocus, u"
            "super, j, movefocus, d"

            "super, mouse_down, exec, hyprctl -q keyword cursor:zoom_factor $(hyprctl getoption cursor:zoom_factor -j | jq '.float * 1.333')"
            "super, mouse_up, exec, hyprctl -q keyword cursor:zoom_factor $(hyprctl getoption cursor:zoom_factor -j | jq '(.float * 0.75) | if . < 1 then 1 else . end')"
            "super, mouse:274, exec, hyprctl -q keyword cursor:zoom_factor 1"
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
          bind=super,r,submap,run
          submap=run
          bind = super, a, exec, anki
          bind = super, a, submap, reset

          bind = super, c, exec, chatterino
          bind = super, c, submap, reset

          bind = super, f, exec, firefox
          bind = super, f, submap, reset

          bind = super, r, exec, rofi -show drun -show-icons
          bind = super, r, submap, reset

          bind = super, s, exec, steam
          bind = super, s, submap, reset

          bind = super, t, exec, kitty
          bind = super, t, submap, reset

          bind = super, v, exec, vesktop
          bind = super, v, submap, reset

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
