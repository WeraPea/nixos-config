{pkgs, ...}: {
  wayland.windowManager.hyprland.enable = true;
  # wayland.windowManager.hyprland.package = pkgs.unstable.hyprland;
  wayland.windowManager.hyprland.settings = {
    monitor = [
      "DP-1,highrr,0x0,auto"
      "DVI-D-1,highrr,2560x0,auto"
    ];
    windowrulev2 = [
      "stayfocused, title:^()$,class:^(steam)$"
      "minsize 1 1, title:^()$,class:^(steam)$"
    ];
    workspace = [
      "1,persistent:true,monitor:DP-1"
      "2,persistent:true,monitor:DP-1"
      "3,persistent:true,monitor:DP-1"
      "4,persistent:true,monitor:DP-1"
      "5,persistent:true,monitor:DP-1"

      "6,persistent:true,monitor:DVI-D-1"
      "7,persistent:true,monitor:DVI-D-1"
      "8,persistent:true,monitor:DVI-D-1"
    ];
    input = {
      kb_layout = "pl";
      repeat_rate = 100;
      repeat_delay = 300;

      follow_mouse = 1;
      touchpad.natural_scroll = true;
    };
    general = {
      no_cursor_warps = true;
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
      drop_shadow = false;
    };

    animations = {
      # TODO
      enabled = true;

      bezier = [
        "myBezier, 0.05, 0.9, 0.1, 1.05"
        "overshot,0.13,0.99,0.29,1.1"
      ];

      animation = [
        "windows,1,4,overshot,slide"
        "border,1,10,default"
        "fade,1,10,default"
        "workspaces,1,8,default,slidevert"
        "windows, 1, 7, default, popin 80%"
        "windowsOut, 1, 7, default, popin 80%"
      ];
      #windows, 1, 7, myBezier
      # animation = border, 1, 10, default
      # animation = borderangle, 1, 8, default
      # animation = fade, 1, 7, default
      # animation = workspaces, 1, 6, default
    };

    dwindle = {
      pseudotile = true;
      preserve_split = true;
    };

    misc = {
      disable_hyprland_logo = true;
      new_window_takes_over_fullscreen = true;
      disable_splash_rendering = true;
      vrr = 1;
      animate_mouse_windowdragging = true;
      # background_color = "0x121212";
    };
    env = [
      "SDL_VIDEODRIVER,wayland"
      "CLUTTER_BACKEND,wayland"
      "QT_QPA_PLATFORM,wayland"
      "GDK_BACKEND,wayland,x11"
      "XDG_CURRENT_DESKTOP,Hyprland"
      "XDG_SESSION_TYPE,wayland"
      "XDG_SESSION_DESKTOP,Hyprland"
      "QT_AUTO_SCREEN_SCALE_FACTOR,1"
      "QT_WAYLAND_DISABLE_WINDOWDECORATION,1"
      "QT_QPA_PLATFORMTHEME,qt5ct"
    ];
    bind =
      [
        # ",XF86Tools, pass,^(VencordDiscord)$"

        ",Print, exec, ~/.scripts/screenshot"
        "super, s, exec, search"
        "super, c, exec, rofi -modi clipboard:$HOME/.scripts/rofi/cliphist-rofi-img -show clipboard -show-icons"
        "super, o, exec, wl-paste -p | wl-copy"
        "super, p, exec, wl-paste | wl-copy -p"
        "super, m, exec, rofi-mount"
        "super, u, exec, rofi-umount"

        ",XF86AudioLowerVolume, exec, pamixer -d 5 --allow-boost"
        ",XF86AudioRaiseVolume, exec, pamixer -i 5 --allow-boost"
        ",XF86AudioMute, exec, pamixer -t"

        ",XF86MonBrightnessUp, exec, brightnessctl set 10%+"
        ",XF86MonBrightnessDown, exec, brightnessctl set 10%-"

        "super, F10, exec, ddccontrol -r 0x10 -W +5 dev:/dev/i2c-5"
        "super, F9, exec, ddccontrol -r 0x10 -W -5 dev:/dev/i2c-5"

        "super_shift, F10, exec, ddccontrol -r 0x10 -W +10 dev:/dev/i2c-4"
        "super_shift, F9, exec, ddccontrol -r 0x10 -W -10 dev:/dev/i2c-4"

        "super, F11, exec, ddccontrol -r 0xe2 -w 5 dev:/dev/i2c-5"
        "super, F12, exec, ddccontrol -r 0xe2 -w 6 dev:/dev/i2c-5"

        "super_shift, F11, exec, ddccontrol -r 0xe5 -W -1 dev:/dev/i2c-5"
        "super_shift, F12, exec, ddccontrol -r 0xe5 -W +1 dev:/dev/i2c-5"

        "super, e, togglefloating,"
        "super, w, fullscreen, 1"
        "super, f, fullscreen, 0"
        "super, g, fakefullscreen,"
        #bind = super, u, togglesplit, # dwindle

        # Move focus with mainMod + arrow keys
        "super, h, movefocus, l"
        "super, l, movefocus, r"
        "super, k, movefocus, u"
        "super, j, movefocus, d"
      ]
      ++ (
        # workspaces
        # binds $mod + [shift +] [f]{1..5} to [move to] workspace {1..10}
        builtins.concatLists (builtins.genList (
            x: let
              ws = builtins.toString (x + 1);
            in [
              "super, ${ws}, workspace, ${ws}"
              "super shift, ${ws}, movetoworkspace, ${ws}"
              "super, f${ws}, workspace, ${toString (x + 6)}"
              "super shift, f${ws}, movetoworkspace, ${toString (x + 6)}"
            ]
          )
          5)
      );
    bindm = [
      # Move/resize windows with mainMod + LMB/RMB and dragging
      "super, mouse:272, movewindow"
      "super, mouse:273, resizewindow"
    ];
  };

  wayland.windowManager.hyprland.extraConfig = ''
    bind=super,r,submap,run
    submap=run
    bind = super, r, exec, rofi -show drun -show-icons
    bind = super, r, submap, reset

    bind = super, t, exec, kitty
    bind = super, t, submap, reset

    bind = super, q, exec, qutebrowser
    bind = super, q, submap, reset

    bind = super, f, exec, firefox
    bind = super, f, submap, reset

    bind = super, s, exec, spotify
    bind = super, s, submap, reset

    bind = ,escape, submap, reset
    submap=reset

    bind = super, x, submap, spotify
    submap = spotify
    bind = super, x, exec, playerctl -p spotify play-pause
    bind = super, x, submap, reset
    bind = super, space, exec, playerctl -p spotify play-pause
    bind = super, space, submap, reset
    bind = super, n, exec, playerctl -p spotify next
    bind = super, n, submap, reset
    bind = super, p, exec, playerctl -p spotify previous
    bind = super, p, submap, reset
    bind = super, j, exec, playerctl -p spotify volume 0.1-
    bind = super, j, submap, reset
    bind = super, k, exec, playerctl -p spotify volume 0.1+
    bind = super, k, submap, reset
    bind = ,escape, submap, reset
    submap = reset

    bind = super, q, submap, kill
    submap = kill
    bind = super, q, killactive,
    bind = super, q, submap, reset
    bind = ,escape, submap, reset
    submap = reset
  '';
}