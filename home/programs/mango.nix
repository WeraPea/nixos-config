{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.mango;
  parseBindMode =
    {
      name,
      enterKeybind ? "",
      binds,
      returnByDefault ? false,
      returnKeybind ? if (name != "default" && name != "common") then "bind=NONE,Escape" else "",
    }:
    builtins.concatStringsSep "\n" (
      lib.optional (enterKeybind != "") "bind=${enterKeybind},setkeymode,${name}"
      ++ [ "keymode=${name}" ]
      ++ (builtins.concatLists (
        lib.mapAttrsToList (
          bindType: bindings:
          (builtins.concatLists (
            lib.mapAttrsToList (
              bind: value:
              let
                command = lib.toList (if builtins.isAttrs value then value.command else value);
                return = if builtins.isAttrs value then value.return or returnByDefault else returnByDefault;
              in
              (builtins.concatMap (com: [ "${bindType}=${bind},${com}" ]) command)
              ++ lib.optional return "${bindType}=${bind},setkeymode,default"
            ) bindings
          ))
        ) binds
      ))
      ++ lib.optional (returnKeybind != "") "${returnKeybind},setkeymode,default"
      ++ [ "keymode=default" ]
    )
    + "\n";
  parseBindModes =
    bindModes:
    builtins.concatStringsSep "\n" (
      lib.mapAttrsToList (name: value: parseBindMode ({ inherit name; } // value)) bindModes
    )
    + "\n";
  mkClipboardMode =
    {
      enterKeybind,
      pasteCmd,
      copyCmdOther, # for pasting into another selection
    }:
    {
      inherit enterKeybind;
      returnByDefault = true;
      binds.bind = {
        "SUPER,p" = "spawn_shell,${pasteCmd} | ${copyCmdOther}";
        "SUPER,o" = "spawn_shell,${pasteCmd} | ${copyCmdOther}";
        "SUPER,s" =
          ''spawn_shell,glide "duckduckgo.com/?q=$(${pasteCmd} | python3 -c "import urllib.parse,sys; print(urllib.parse.quote(sys.stdin.read().strip()))")"'';
        "SUPER+CTRL,s" =
          ''spawn_shell,glide --new-window "duckduckgo.com/?q=$(${pasteCmd} | python3 -c "import urllib.parse,sys; print(urllib.parse.quote(sys.stdin.read().strip()))")"'';
        "SUPER,j" = ''spawn_shell,glide "jisho.org/search/$(${pasteCmd})"'';
        "SUPER+CTRL,j" = ''spawn_shell,glide --new-window "jisho.org/search/$(${pasteCmd})"'';
        "SUPER,h" = ''spawn_shell,glide "$(${pasteCmd})"'';
        "SUPER+CTRL,h" = ''spawn_shell,glide --new-window "$(${pasteCmd})"'';
      };
    };
  mango-toggle-monocle = pkgs.writeShellScript "mango-toggle-monocle" ''
    selmon=$(mmsg -g -o | grep "selmon 1" | cut -d' ' -f1)
    tag=$(mmsg -g -t | awk -v mon="$selmon" '$1 == mon && $2 == "tag" && ($4 == 1 || $4 == 3) { print $3 }')
    lfile="/tmp/mango-last-layout-pre-monocle-per-monitor"
    declare -A l_to_layout=(
      [S]="scroller"
      [T]="tile"
      [G]="grid"
      [M]="monocle"
      [K]="deck"
      [CT]="center_tile"
      [RT]="right_tile"
      [VS]="vertical_scroller"
      [VT]="vertical_tile"
      [VG]="vertical_grid"
      [VK]="vertical_deck"
      [TG]="tgmix"
    )

    cur_layout=$(mmsg -g -l | grep "$selmon" | cut -d' ' -f3)
    cur_layout="''${l_to_layout[$cur_layout]}"

    if [[ "$cur_layout" == "monocle" ]]; then
      last_layout=$(grep -e "$selmon $tag" "$lfile" | cut -d' ' -f3)
      if [[ "$last_layout" == "" ]]; then
        last_layout="tile";
      fi
      mmsg -d setlayout,"$last_layout"
    else
      [[ -f "$lfile" ]] || : > "$lfile"
      if grep -q "^$selmon $tag" "$lfile"; then
        sed -i "s/^$selmon $tag .*/$selmon $tag $cur_layout/" "$lfile"
      else
        echo "$selmon $tag $cur_layout" >> "$lfile"
      fi
      mmsg -d setlayout,monocle
    fi;
  '';
  bindModes = {
    default.binds = {
      bind =
        (builtins.listToAttrs (
          builtins.concatMap (w: [
            (lib.nameValuePair "SUPER,${w}" [
              "focusmon,${cfg.mainDisplay}"
              "view,${w}"
            ])
            (lib.nameValuePair "SUPER+SHIFT,${w}" [
              "tagmon,${cfg.mainDisplay}"
              "tag,${w}"
            ])
          ]) (map toString (lib.range 1 5))
        ))
        // {
          "SUPER,j" = "focusstack,next";
          "SUPER,k" = "focusstack,prev";
          "SUPER,h" = "focusdir,left";
          "SUPER,l" = "focusdir,right";

          "SUPER,i" = "incnmaster,+1";
          "SUPER,u" = "incnmaster,-1";
          # "SUPER,h" = "setmfact,-0.05";
          # "SUPER,l" = "setmfact,+0.05";
          "SUPER,Return" = "zoom";
          # "SUPER,code:59" = "focusmon,left";
          # "SUPER+SHIFT,code:59" = "tagmon,left,0";
          # "SUPER,code:60" = "focusmon,right";
          # "SUPER+SHIFT,code:60" = "tagmon,right,0";

          "SUPER+CTRL,k" = "exchange_client,up";
          "SUPER+CTRL,j" = "exchange_client,down";
          "SUPER+CTRL,h" = "exchange_client,left";
          "SUPER+CTRL,l" = "exchange_client,right";

          # Layouts
          "SUPER,t" = "setlayout,tile";
          "SUPER+CTRL,t" = "setlayout,right_tile";
          "SUPER,g" = "setlayout,tgmix";
          "SUPER+CTRL,g" = "setlayout,vertical_grid";
          "SUPER,v" = "setlayout,vertical_tile";
          "SUPER,w" = "spawn,${mango-toggle-monocle}";
          "SUPER,N" = "setlayout,scroller";
          "SUPER,M" = "switch_proportion_preset";

          "SUPER,e" = "togglefloating";
          "SUPER,f" = "togglefullscreen";
          "SUPER+CTRL,f" = "togglefakefullscreen";

          "NONE,XF86AudioLowerVolume" = "spawn,${lib.getExe pkgs.pamixer} -d 1";
          "NONE,XF86AudioRaiseVolume" = "spawn,${lib.getExe pkgs.pamixer} -i 1";
          "SHIFT,XF86AudioLowerVolume" = "spawn,${lib.getExe pkgs.pamixer} -d 1 --allow-boost";
          "SHIFT,XF86AudioRaiseVolume" = "spawn,${lib.getExe pkgs.pamixer} -i 1 --allow-boost";

          "SUPER,space" = "spawn,makoctl dismiss";
          "SUPER+CTRL,space" = "spawn,makoctl restore";
          "NONE,Print" = "spawn,screenshot";
          # bind=SHIFT,Print,spawn,hyprshot -m window -c -o /tmp/ -f hyprshot_screenshot.png # TODO:

          "SUPER,s" = "spawn,search";
          "SUPER,c" = "spawn,rofi -modi clipboard:cliphist-rofi-img -show clipboard -show-icons";
          "SUPER,d" = "spawn,rofi -show window -show-icons";
          "SUPER,b" = "spawn,${lib.getExe pkgs.rofi-bluetooth}";

          "SUPER,F10" = "spawn,ddccontrol -r 0x10 -W +5 dev:/dev/i2c-7";
          "SUPER,F9" = "spawn,ddccontrol -r 0x10 -W -5 dev:/dev/i2c-7";

          "SUPER,F11" = "spawn,ddccontrol -r 0xe2 -w 5 dev:/dev/i2c-7";
          "SUPER,F12" = "spawn,ddccontrol -r 0xe2 -w 6 dev:/dev/i2c-7";

          "SUPER+SHIFT,F11" = "spawn,ddccontrol -r 0xe5 -W -1 dev:/dev/i2c-7";
          "SUPER+SHIFT,F12" = "spawn,ddccontrol -r 0xe5 -W +1 dev:/dev/i2c-7";

          "NONE,XF86AudioMute" = "spawn,${lib.getExe pkgs.pamixer} -t";

          "NONE,XF86MonBrightnessUp" = "spawn,brightnessctl set 10%+";
          "NONE,XF86MonBrightnessDown" = "spawn,brightnessctl set 10%-";

          "NONE,XF86AudioPlay" = "spawn,mpc toggle";
          "NONE,XF86AudioPause" = "spawn,mpc pause";
          "NONE,XF86AudioPrev" = "spawn,mpc prev";
          "NONE,XF86AudioNext" = "spawn,mpc next";
        };
      axisbind = {
        "SUPER,UP" = "screen_zoom_in";
        "SUPER,DOWN" = "screen_zoom_out";

        "SUPER+CTRL,UP" = "screen_zoom_in";
        "SUPER+CTRL,DOWN" = "screen_zoom_out";
      };
      mousebind = {
        "SUPER,btn_middle" = "screen_zoom_move";
        "SUPER+CTRL,btn_left" = "screen_zoom_move";
        "SUPER,btn_left" = "moveresize,curmove";
        "SUPER,btn_right" = "moveresize,curresize";
      };
    };
    common.binds.bind = {
      "SUPER+CTRL,r" = "reload_config";
    };
    leader = {
      enterKeybind = "SUPER,space";
      returnByDefault = true;
      binds.bind = {
        "SUPER,o" = "toggleoverlay";
        "SUPER,b" = "toggle_render_border";
      };
    };
    clipboard = mkClipboardMode {
      enterKeybind = "SUPER,o";
      pasteCmd = "wl-paste";
      copyCmdOther = "wl-copy -p";
    };
    primary = mkClipboardMode {
      enterKeybind = "SUPER,p";
      pasteCmd = "wl-paste -p";
      copyCmdOther = "wl-copy";
    };
    run = {
      enterKeybind = "SUPER,r";
      returnByDefault = true;
      binds.bind = {
        "SUPER,a" = "spawn,anki";
        "SUPER,c" = "spawn,chatterino";
        "SUPER,f" = "spawn,glide";
        "SUPER,r" = "spawn,rofi -show drun -show-icons";
        "SUPER,s" = "spawn,steam";
        "SUPER,t" = "spawn,kitty";
        "SUPER,d" = "spawn,legcord";
      };
    };
    mpd = {
      enterKeybind = "SUPER,x";
      returnByDefault = true;
      binds.bind = {
        "SUPER,x" = "spawn,mpc toggle";
        "SUPER,space" = "spawn,mpc toggle";
        "SUPER,n" = "spawn,mpc next";
        "SUPER,p" = "spawn,mpc prev";
        "SUPER,j" = "spawn,mpc volume -5";
        "SUPER,k" = "spawn,mpc volume +5";
        "SUPER,f" =
          ''spawn_shell,glide --new-window "$(ffprobe /mnt/mnt3/music/"$(mpc current --format %file%)" -print_format json -show_streams -v quiet | jq -r '.streams.[].tags.PURL')"'';
      };
    };
    kill = {
      enterKeybind = "SUPER,q";
      returnByDefault = true;
      binds.bind = {
        "SUPER,q" = "killclient,";
      };
    };
  };
in
{
  options = {
    mango.enable = lib.mkEnableOption "enables mango";
    mango.extraConfig = lib.mkOption {
      type = lib.types.lines;
      default = "";
    };
    mango.mainDisplay = lib.mkOption { };
    mango.bindModes = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      apply = userModes: lib.recursiveUpdate bindModes userModes;
    };
  };
  config = lib.mkIf cfg.enable {
    wayland.systemd.target = "mango-session.target";
    wayland.windowManager.mango = {
      enable = true;
      systemd.enable = false;
      settings =
        with config.lib.stylix.colors;
        "" # hyprlang
        + ''
          animations=1
          animation_fade_in=0
          animation_fade_out=0
          animation_type_close=slide
          animation_duration_move=300
          animation_duration_open=200
          animation_duration_tag=250
          animation_duration_close=250
          animation_duration_focus=250

          gappih=0
          gappiv=0
          gappoh=0
          gappov=0
          borderpx=1
          no_border_when_single=0

          rootcolor=0x${base00}ff
          bordercolor=0x${base02}ff
          focuscolor=0x${cyan}ff
          urgentcolor=0x${red}ff

          repeat_rate=100
          repeat_delay=300
          xkb_rules_layout=pl

          new_is_master=0
          default_mfact=0.5
          enable_hotarea=0
          warpcursor=0
          sloppyfocus=1
          axis_bind_apply_timeout=10
          drag_tile_to_tile=1
          cursor_hide_timeout=5
          focus_on_activate=0
          focus_cross_monitor=1
          view_current_to_back=0
          drag_corner=4

          scroller_structs=0
          scroller_default_proportion=1
          scroller_proportion_preset=0.5,1.0

          zoom_centered=0
          zoom_speed=0.2
          zoom_max=20

          windowrule=title:Chatterino - Overlay,isoverlay:1

          tagrule=id:1,layout_name:tile
          tagrule=id:2,layout_name:tile
          tagrule=id:3,layout_name:tile
          tagrule=id:4,layout_name:tile
          tagrule=id:5,layout_name:tile
          tagrule=id:6,layout_name:tile
          tagrule=id:7,layout_name:tile
          tagrule=id:8,layout_name:tile
          tagrule=id:9,layout_name:tile

          env=QT_QPA_PLATFORM,wayland
          env=MOZ_ENABLE_WAYLAND,1
          env=NIXOS_OZONE_WL,1
          env=ELECTRON_OZONE_PLATFORM_HINT,wayland
          env=OZONE_PLATFORM,wayland
          env=GDK_BACKEND,wayland
          env=WINDOW_MANAGER,mango
          env=SDL_VIDEODRIVER,wayland

          # script needed due to 256 char limit
          exec-once=${pkgs.writeScript "update-dbus-env-mango" ''
            ${pkgs.dbus}/bin/dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=wlroots XDG_SESSION_TYPE NIXOS_OZONE_WL XCURSOR_THEME XCURSOR_SIZE PATH SDL_VIDEODRIVER WINDOW_MANAGER GDK_BACKEND OZONE_PLATFORM ELECTRON_OZONE_PLATFORM_HINT MOZ_ENABLE_WAYLAND QT_QPA_PLATFORM
          ''}
          exec-once=systemctl --user reset-failed
          exec-once=systemctl --user restart mango-session.target
        ''
        + (builtins.concatStringsSep "\n" (
          lib.optional config.wvkbd.enable "exec-once=sleep 5; systemctl --user restart fcitx5-daemon"
        ))
        + "\n"
        + parseBindModes cfg.bindModes
        + "\n"
        + cfg.extraConfig;
    };

    systemd.user.targets.mango-session = {
      Unit = {
        Description = "mango compositor session";
        Documentation = [ "man:systemd.special(7)" ];
        BindsTo = [ "graphical-session.target" ];
        Wants = [
          "graphical-session-pre.target"
        ];
        After = [ "graphical-session-pre.target" ];
      };
    };
  };
}
