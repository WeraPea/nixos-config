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
    services.hyprpaper = {
      enable = true;
    };
    xdg.portal = {
      extraPortals = [
        pkgs.xdg-desktop-portal-wlr
      ];
      configPackages = [
        config.wayland.windowManager.mango.package
      ];
    };
    wayland.windowManager.mango = {
      enable = true;
      settings =
        "" # hyprlang
        + ''
          animations=0
          gappih=0
          gappiv=0
          gappoh=0
          gappov=0
          borderpx=1
          no_border_when_single=1

          focuscolor=0x${config.lib.stylix.colors.blue}ff
          rootcolor=0x${config.lib.stylix.colors.base00}ff

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
          enable_floating_snap=0
          snap_distance=30
          cursor_hide_timeout=5

          tagrule=id:1,layout_name:tile
          tagrule=id:2,layout_name:tile
          tagrule=id:3,layout_name:tile
          tagrule=id:4,layout_name:tile
          tagrule=id:5,layout_name:tile
          tagrule=id:6,layout_name:tile
          tagrule=id:7,layout_name:tile
          tagrule=id:8,layout_name:tile
          tagrule=id:9,layout_name:tile

          bind=SUPER,1,focusmon,${config.mango.mainDisplay}
          bind=SUPER,1,comboview,1
          bind=SUPER,2,focusmon,${config.mango.mainDisplay}
          bind=SUPER,2,comboview,2
          bind=SUPER,3,focusmon,${config.mango.mainDisplay}
          bind=SUPER,3,comboview,3
          bind=SUPER,4,focusmon,${config.mango.mainDisplay}
          bind=SUPER,4,comboview,4
          bind=SUPER,5,focusmon,${config.mango.mainDisplay}
          bind=SUPER,5,comboview,5

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
          bind=SUPER,w,setlayout,monocle

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
          bind=SUPER,o,spawn_shell,wl-paste -p | wl-copy
          bind=SUPER,p,spawn_shell,wl-paste | wl-copy -p

          bind=SUPER,s,spawn,search
          bind=SUPER,c,spawn,rofi -modi clipboard:cliphist-rofi-img -show clipboard -show-icons
          bind=SUPER,d,spawn,rofi -show window -show-icons

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
          bind=NONE,XF86AudioPrev,spawn,mpc prev
          bind=NONE,XF86AudioNext,spawn,mpc next

          # bind=SUPER,mouse_down,spawn,hyprctl -q keyword cursor:zoom_factor $(hyprctl getoption cursor:zoom_factor -j | jq '.float * 1.333')
          # bind=SUPER,mouse_up,spawn,hyprctl -q keyword cursor:zoom_factor $(hyprctl getoption cursor:zoom_factor -j | jq '(.float * 0.75) | if . < 1 then 1 else . end')
          # bind=SUPER,mouse:274,spawn,hyprctl -q keyword cursor:zoom_factor 1

          keymode=common
          bind=SUPER+CTRL,r,reload_config
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
        ''
        + config.mango.extraConfig;
      autostart_sh = # sh
        ''
          systemctl --user set-environment XDG_CURRENT_DESKTOP=wlroots
          systemctl --user stop pipewire wireplumber xdg-desktop-portal xdg-desktop-portal-wlr
          systemctl --user start wireplumber xdg-desktop-portal
          waybar &
        '';
    };
  };
}
