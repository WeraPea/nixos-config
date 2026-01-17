{
  lib,
  config,
  pkgs,
  ...
}:
{
  options = {
    mango.enable = lib.mkEnableOption "enables mango";
    mango.extraConfig = lib.mkOption {
      type = lib.types.lines;
      default = "";
    };
    mango.mainDisplay = lib.mkOption { };
  };
  config = lib.mkIf config.mango.enable {
    services.swww.enable = true;
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
          axis_bind_apply_timeout=100
          drag_tile_to_tile=1
          cursor_hide_timeout=5
          focus_on_activate=0
          focus_cross_monitor=1
          view_current_to_back=0

          scroller_structs=0
          scroller_default_proportion=1
          scroller_proportion_preset=0.5,1.0

          windowrule=title:Chatterino - Overlay,isoverlay:1

          bind=SUPER,1,focusmon,${config.mango.mainDisplay}
          bind=SUPER,1,view,1
          bind=SUPER,2,focusmon,${config.mango.mainDisplay}
          bind=SUPER,2,view,2
          bind=SUPER,3,focusmon,${config.mango.mainDisplay}
          bind=SUPER,3,view,3
          bind=SUPER,4,focusmon,${config.mango.mainDisplay}
          bind=SUPER,4,view,4
          bind=SUPER,5,focusmon,${config.mango.mainDisplay}
          bind=SUPER,5,view,5

          bind=SUPER+SHIFT,1,tagmon,${config.mango.mainDisplay}
          bind=SUPER+SHIFT,1,tag,1
          bind=SUPER+SHIFT,2,tagmon,${config.mango.mainDisplay}
          bind=SUPER+SHIFT,2,tag,2
          bind=SUPER+SHIFT,3,tagmon,${config.mango.mainDisplay}
          bind=SUPER+SHIFT,3,tag,3
          bind=SUPER+SHIFT,4,tagmon,${config.mango.mainDisplay}
          bind=SUPER+SHIFT,4,tag,4
          bind=SUPER+SHIFT,5,tagmon,${config.mango.mainDisplay}
          bind=SUPER+SHIFT,5,tag,5

          bind=SUPER,j,focusstack,next
          bind=SUPER,k,focusstack,prev
          bind=SUPER,h,focusdir,left
          bind=SUPER,l,focusdir,right

          bind=SUPER,i,incnmaster,+1
          bind=SUPER,u,incnmaster,-1
          # bind=SUPER,h,setmfact,-0.05
          # bind=SUPER,l,setmfact,+0.05
          bind=SUPER,Return,zoom
          # bind=SUPER,code:59,focusmon,left
          # bind=SUPER+SHIFT,code:59,tagmon,left,0
          # bind=SUPER,code:60,focusmon,right
          # bind=SUPER+SHIFT,code:60,tagmon,right,0

          # Unfortunately stack based exchange is still being worked on.
          # take these lesser directional based ones.
          bind=SUPER+CTRL,k,exchange_client,up
          bind=SUPER+CTRL,j,exchange_client,down
          bind=SUPER+CTRL,h,exchange_client,left
          bind=SUPER+CTRL,l,exchange_client,right

          # Layouts
          bind=SUPER,t,setlayout,tile
          bind=SUPER+CTRL,t,setlayout,right_tile
          bind=SUPER,g,setlayout,vertical_grid
          bind=SUPER+CTRL,g,setlayout,grid
          bind=SUPER,v,setlayout,vertical_tile
          bind=SUPER,w,spawn,${pkgs.writeShellScript "mango-toggle-monocle" ''
            selmon=$(mmsg -g -o | grep "selmon 1" | cut -d' ' -f1)
            tag=$(mmsg -g -t | awk -v mon="$selmon" '$1 == mon && $2 == "tag" && $4 == 1 { print $3 }')
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
          ''}
          bind=SUPER,N,setlayout,scroller
          bind=SUPER,M,switch_proportion_preset
          bind=SUPER,N,setlayout,scroller

          bind=SUPER,e,togglefloating
          bind=SUPER,f,togglefullscreen
          bind=SUPER+CTRL,f,togglefakefullscreen

          bind=NONE,XF86AudioLowerVolume,spawn,${lib.getExe pkgs.pamixer} -d 1
          bind=NONE,XF86AudioRaiseVolume,spawn,${lib.getExe pkgs.pamixer} -i 1
          bind=SHIFT,XF86AudioLowerVolume,spawn,${lib.getExe pkgs.pamixer} -d 1 --allow-boost
          bind=SHIFT,XF86AudioRaiseVolume,spawn,${lib.getExe pkgs.pamixer} -i 1 --allow-boost

          bind=SUPER,space,spawn,makoctl dismiss
          bind=SUPER+CTRL,space,spawn,makoctl restore
          bind=NONE,Print,spawn,screenshot
          # bind=SHIFT,Print,spawn,hyprshot -m window -c -o /tmp/ -f hyprshot_screenshot.png # TODO:

          bind=SUPER,s,spawn,search
          bind=SUPER,c,spawn,rofi -modi clipboard:cliphist-rofi-img -show clipboard -show-icons
          bind=SUPER,d,spawn,rofi -show window -show-icons
          bind=SUPER,b,spawn,${lib.getExe pkgs.rofi-bluetooth}

          bind=SUPER,F10,spawn,ddccontrol -r 0x10 -W +5 dev:/dev/i2c-7
          bind=SUPER,F9,spawn,ddccontrol -r 0x10 -W -5 dev:/dev/i2c-7

          bind=SUPER,F11,spawn,ddccontrol -r 0xe2 -w 5 dev:/dev/i2c-7
          bind=SUPER,F12,spawn,ddccontrol -r 0xe2 -w 6 dev:/dev/i2c-7

          bind=SUPER+SHIFT,F11,spawn,ddccontrol -r 0xe5 -W -1 dev:/dev/i2c-7
          bind=SUPER+SHIFT,F12,spawn,ddccontrol -r 0xe5 -W +1 dev:/dev/i2c-7

          bind=NONE,XF86AudioMute,spawn,${lib.getExe pkgs.pamixer} -t

          bind=NONE,XF86MonBrightnessUp,spawn,brightnessctl set 10%+
          bind=NONE,XF86MonBrightnessDown,spawn,brightnessctl set 10%-

          bind=NONE,XF86AudioPlay,spawn,mpc toggle
          bind=NONE,XF86AudioPause,spawn,mpc pause
          bind=NONE,XF86AudioPrev,spawn,mpc prev
          bind=NONE,XF86AudioNext,spawn,mpc next

          # bind=SUPER,mouse_down,spawn,hyprctl -q keyword cursor:zoom_factor $(hyprctl getoption cursor:zoom_factor -j | jq '.float * 1.333')
          # bind=SUPER,mouse_up,spawn,hyprctl -q keyword cursor:zoom_factor $(hyprctl getoption cursor:zoom_factor -j | jq '(.float * 0.75) | if . < 1 then 1 else . end')
          # bind=SUPER,mouse:274,spawn,hyprctl -q keyword cursor:zoom_factor 1

          keymode=common
          bind=SUPER+CTRL,r,reload_config
          keymode=default

          bind=SUPER,o,setkeymode,clipboard
          keymode=clipboard
          bind=SUPER,p,spawn_shell,wl-paste | wl-copy -p
          bind=SUPER,p,setkeymode,default

          bind=SUPER,o,spawn_shell,wl-paste | wl-copy -p
          bind=SUPER,o,setkeymode,default

          bind=SUPER,s,spawn_shell,firefox "duckduckgo.com/?q=$(wl-paste | python3 -c "import urllib.parse,sys; print(urllib.parse.quote(sys.stdin.read().strip()))")"
          bind=SUPER,s,setkeymode,default
          bind=SUPER+CTRL,s,spawn_shell,firefox --new-window "duckduckgo.com/?q=$(wl-paste | python3 -c "import urllib.parse,sys; print(urllib.parse.quote(sys.stdin.read().strip()))")"
          bind=SUPER+CTRL,s,setkeymode,default

          bind=SUPER,j,spawn_shell,firefox "jisho.org/search/$(wl-paste)"
          bind=SUPER,j,setkeymode,default
          bind=SUPER+CTRL,j,spawn_shell,firefox --new-window "jisho.org/search/$(wl-paste)"
          bind=SUPER+CTRL,j,setkeymode,default

          bind=SUPER,h,spawn_shell,firefox "$(wl-paste)"
          bind=SUPER,h,setkeymode,default
          bind=SUPER+CTRL,h,spawn_shell,firefox --new-window "$(wl-paste)"
          bind=SUPER+CTRL,h,setkeymode,default

          bind=NONE,Escape,setkeymode,default
          keymode=default

          bind=SUPER,p,setkeymode,primary
          keymode=primary
          bind=SUPER,o,spawn_shell,wl-paste -p | wl-copy
          bind=SUPER,o,setkeymode,default

          bind=SUPER,p,spawn_shell,wl-paste -p | wl-copy
          bind=SUPER,p,setkeymode,default

          bind=SUPER,s,spawn_shell,firefox "duckduckgo.com/?q=$(wl-paste -p | python3 -c "import urllib.parse,sys; print(urllib.parse.quote(sys.stdin.read().strip()))")"
          bind=SUPER,s,setkeymode,default
          bind=SUPER+CTRL,s,spawn_shell,firefox --new-window "duckduckgo.com/?q=$(wl-paste -p | python3 -c "import urllib.parse,sys; print(urllib.parse.quote(sys.stdin.read().strip()))")"
          bind=SUPER+CTRL,s,setkeymode,default

          bind=SUPER,j,spawn_shell,firefox "jisho.org/search/$(wl-paste -p)"
          bind=SUPER,j,setkeymode,default
          bind=SUPER+CTRL,j,spawn_shell,firefox --new-window "jisho.org/search/$(wl-paste -p)"
          bind=SUPER+CTRL,j,setkeymode,default

          bind=SUPER,h,spawn_shell,firefox "$(wl-paste -p)"
          bind=SUPER,h,setkeymode,default
          bind=SUPER+CTRL,h,spawn_shell,firefox --new-window "$(wl-paste -p)"
          bind=SUPER+CTRL,h,setkeymode,default

          bind=NONE,Escape,setkeymode,default
          keymode=default

          bind=SUPER,r,setkeymode,run
          keymode=run
          bind=SUPER,a,spawn,anki
          bind=SUPER,a,setkeymode,default

          bind=SUPER,c,spawn,chatterino
          bind=SUPER,c,setkeymode,default

          bind=SUPER,f,spawn,firefox
          bind=SUPER,f,setkeymode,default

          bind=SUPER,r,spawn,rofi -show drun -show-icons
          bind=SUPER,r,setkeymode,default

          bind=SUPER,s,spawn,steam
          bind=SUPER,s,setkeymode,default

          bind=SUPER,t,spawn,kitty
          bind=SUPER,t,setkeymode,default

          bind=SUPER,v,spawn,vesktop
          bind=SUPER,v,setkeymode,default

          bind=NONE,Escape,setkeymode,default
          keymode=default

          bind=SUPER,x,setkeymode,mpd
          keymode=mpd
          bind=SUPER,x,spawn,mpc toggle
          bind=SUPER,x,setkeymode,default

          bind=SUPER,space,spawn,mpc toggle
          bind=SUPER,space,setkeymode,default

          bind=SUPER,n,spawn,mpc next
          bind=SUPER,n,setkeymode,default

          bind=SUPER,p,spawn,mpc prev
          bind=SUPER,p,setkeymode,default

          bind=SUPER,j,spawn,mpc volume -5
          bind=SUPER,j,setkeymode,default

          bind=SUPER,k,spawn,mpc volume +5
          bind=SUPER,k,setkeymode,default

          bind=SUPER,f,spawn_shell,firefox --new-window "$(ffprobe /mnt/mnt3/music/"$(mpc current --format %file%)" -print_format json -show_streams -v quiet | jq -r '.streams.[].tags.PURL')"
          bind=SUPER,f,setkeymode,default
          bind=NONE,Escape,setkeymode,default
          keymode=default

          bind=SUPER,q,setkeymode,kill
          keymode=kill
          bind=SUPER,q,killclient,
          bind=SUPER,q,setkeymode,default
          bind=NONE,Escape,setkeymode,default
          keymode=default

          # Mouse Button Bindings
          # NONE mode key only work in ov mode
          mousebind=SUPER,btn_left,moveresize,curmove
          mousebind=SUPER,btn_right,moveresize,curresize
          mousebind=NONE,btn_left,toggleoverview,-1
          mousebind=NONE,btn_right,killclient,0

          env=QT_QPA_PLATFORM,wayland
          env=MOZ_ENABLE_WAYLAND,1
          env=NIXOS_OZONE_WL,1
          env=ELECTRON_OZONE_PLATFORM_HINT,wayland
          env=OZONE_PLATFORM,wayland
          env=GDK_BACKEND,wayland
          env=WINDOW_MANAGER,mango
          env=SDL_VIDEODRIVER,wayland

          exec-once=${pkgs.dbus}/bin/dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=wlroots XDG_SESSION_TYPE NIXOS_OZONE_WL XCURSOR_THEME XCURSOR_SIZE PATH
          exec-once=systemctl --user reset-failed
          exec-once=systemctl --user start mango-session.target
        ''
        + (
          if config.programs.quickshell.enable then # hyprlang
            ''
              exec-once=systemctl --user restart quickshell
            ''
          else
            ""
        )
        + (
          if config.programs.waybar.enable then # hyprlang
            ''
              exec-once=waybar
            ''
          else
            ""
        )
        + (
          if config.services.swww.enable then # hyprlang
            ''
              exec-once=swww img ${../../stylix/wallpaper.png}
            ''
          else
            ""
        )
        + config.mango.extraConfig;
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
