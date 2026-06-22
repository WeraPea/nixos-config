{
  config,
  inputs,
  lib,
  outputs,
  pkgs,
  ...
}:
let
  moduleName = "mango";
  cfg = config.werapi.${moduleName};
  hmConfig = config.home-manager.users.${config.werapi.username};

  rsiLimit = 2;
  parseBindMode =
    {
      name,
      enter ? { },
      binds,
      returnByDefault ? false,
      return ? if (name != "default" && name != "common") then { bind = "NONE,Escape"; } else { },
      onEntry ? [ ],
      onReturn ? [ ],
      onReturnPre ? [ ],
      returnTo ? (if (lib.isString recSubmodeOf) then recSubmodeOf else "default"),
      outerKeymode ? "default",
      recSubmodeOf ? null, # allows for "recursive" submodes, limited by mango's 27 character keymode name limit though
      rsi ? 0,
      recEnterIsReturnReturnToPass ? "default",
      ...
    }@args:
    let
      recEnterIsReturn =
        if args ? recEnterIsReturn && lib.isBool args.recEnterIsReturn then
          args.recEnterIsReturn
        else
          false;
      name = if (lib.isString recSubmodeOf) then "${recSubmodeOf}-${args.name}" else args.name;
      baseMode = mode: lib.last (lib.splitString "-" mode);
      emitTransition =
        commands: targetMode: binds:
        builtins.concatLists (
          lib.mapAttrsToList (
            bindType: bindings:
            (builtins.concatMap (
              binding:
              (builtins.concatMap (com: [ "${bindType}=${binding},${com}" ]) (lib.toList commands))
              ++ [ "${bindType}=${binding},setkeymode,${targetMode}" ]
            ) (lib.toList bindings))
          ) binds
        );
      emitBinds =
        bindType: bindings:
        (builtins.concatLists (
          lib.mapAttrsToList (
            bind: value:
            let
              commands = lib.toList (value.command or value);
              shouldReturn = if value ? name then false else value.return or returnByDefault;
              extendSubmode = (
                args ? recSubmodeOf
                && lib.isString args.recSubmodeOf
                && value ? recSubmodeOf
                && baseMode args.recSubmodeOf != value.recSubmodeOf # shouldn't not happen
              );
              recSubmodeOf =
                if extendSubmode then
                  "${args.recSubmodeOf}-${value.recSubmodeOf}"
                else
                  value.recSubmodeOf or args.recSubmodeOf or null;
              rsi = if extendSubmode then (args.rsi or 0) + 1 else args.rsi or 0;
              recEnterIsReturn = value.recEnterIsReturn or args.recEnterIsReturn or null;
              recEnterIsReturnReturnToPass =
                if value ? recSubmodeOf then returnTo else args.recEnterIsReturnReturnToPass or "default";

              emitBind =
                com:
                if builtins.isAttrs com then
                  if com ? setkeymode && !(lib.isString recSubmodeOf && com.setkeymode == baseMode recSubmodeOf) then
                    [
                      "${bindType}=${bind},setkeymode,${
                        lib.concatStringsSep "-" (
                          (if lib.isString recSubmodeOf then [ recSubmodeOf ] else [ ]) ++ [ com.setkeymode ]
                        )
                      }"
                    ]
                  else
                    parseBindMode (
                      {
                        outerKeymode = name;
                        enter.${bindType} = bind;
                      }
                      // com
                      // {
                        inherit
                          recSubmodeOf
                          rsi
                          recEnterIsReturn
                          recEnterIsReturnReturnToPass
                          ;
                      }
                    )
                else
                  [ "${bindType}=${bind},${com}" ];
            in
            lib.optionals shouldReturn (
              builtins.concatMap (com: [ "${bindType}=${bind},${com}" ]) (lib.toList onReturnPre)
            )
            ++ (builtins.concatMap emitBind commands)
            ++ lib.optionals shouldReturn (emitTransition onReturn returnTo { ${bindType} = bind; })
          ) bindings
        ));
    in
    if (lib.isString recSubmodeOf && args.name == baseMode recSubmodeOf) then
      lib.optionals recEnterIsReturn (emitTransition onReturn recEnterIsReturnReturnToPass enter)
    else if rsi >= rsiLimit then
      [ ]
    else
      [ "" ]
      ++ (emitTransition onEntry name enter)
      ++ [ "keymode=${name}" ]
      ++ (builtins.concatLists (lib.mapAttrsToList emitBinds binds))
      ++ (emitTransition onReturn returnTo return)
      ++ [
        "keymode=${outerKeymode}"
        ""
      ];
  parseBindModes =
    bindModes:
    builtins.concatStringsSep "\n" (
      builtins.concatLists (
        lib.mapAttrsToList (name: value: parseBindMode ({ inherit name; } // value)) bindModes
      )
    );
  stripNestedModes =
    binds:
    builtins.mapAttrs (
      key: bind: if bind ? name then bind // { setkeymode = bind.name; } else bind
    ) binds;
  convertBindModes =
    modes: recSubmodeOf:
    let
      enterBindToNormalBind =
        name: mode: type: key:
        let
          key' = if builtins.isList key then lib.head key else key;
        in
        {
          ${type}."${key'}" = mode // {
            inherit name recSubmodeOf;
          };
        };
      enterBindsToNormalBinds =
        name: mode: lib.concatMapAttrs (enterBindToNormalBind name mode) (mode.enter or { });
    in
    lib.foldl' lib.recursiveUpdate { } (lib.mapAttrsToList enterBindsToNormalBinds modes);
  mkClipboardMode =
    {
      enter,
      pasteCmd,
      copyCmdOther, # for pasting into another selection
    }:
    {
      inherit enter;
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
    export PATH="${lib.makeBinPath [ pkgs.jq ]}:$PATH"
    selmon=$(mmsg get all-monitors | jq -r '.monitors[] | select(.active) | .name')
    tag=$(mmsg get all-monitors | jq -r '.monitors[] | select(.active) | .active_tags[.1]')
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
      [F]="fair"
      [VF]="vertical_fair"
      [DW]="dwindle"
    )

    cur_layout=$(mmsg get all-monitors | jq -r '.monitors[] | select(.active) | .layout_symbol')
    cur_layout="''${l_to_layout[$cur_layout]}"

    if [[ "$cur_layout" == "monocle" ]]; then
      last_layout=$(grep -e "$selmon $tag" "$lfile" | cut -d' ' -f3)
      if [[ "$last_layout" == "" ]]; then
        last_layout="tile";
      fi
      mmsg dispatch setlayout,"$last_layout"
    else
      [[ -f "$lfile" ]] || : > "$lfile"
      if grep -q "^$selmon $tag" "$lfile"; then
        sed -i "s/^$selmon $tag .*/$selmon $tag $cur_layout/" "$lfile"
      else
        echo "$selmon $tag $cur_layout" >> "$lfile"
      fi
      mmsg dispatch setlayout,monocle
    fi;
  '';
  wl-find-cursor' = pkgs.callPackage "${inputs.wl-find-cursor}/wl-find-cursor.nix" { };
  wl-find-cursor = lib.getExe' wl-find-cursor' "wl-find-cursor";
  qocr-trigger-popup-script = pkgs.writeShellScript "qocr-trigger-popup" ''
    output=$(mmsg get all-monitors | ${lib.getExe pkgs.jq} -r '.monitors[] | select(.active) | .name')
    xy=$(${wl-find-cursor} -p)
    qocr ipc call ocr trigger_popup $xy $output
  '';
  qocr-trigger-popup = "spawn,${qocr-trigger-popup-script}";
  force-kill = pkgs.writeShellScript "force-kill" ''
    export PATH="${lib.makeBinPath [ pkgs.jq ]}:$PATH"
    kill -9 $(mmsg get client $(mmsg get all-monitors | jq '.monitors[] | select(.active) | .active_client.id') | jq '.pid')
  '';
  bindModes = {
    default.binds = {
      bind =
        (builtins.listToAttrs (
          builtins.concatMap (w: [
            (lib.nameValuePair "SUPER,${w}" (
              lib.optional (cfg.mainDisplay != null) "focusmon,${cfg.mainDisplay}"
              ++ [
                "view,${w}"
              ]
            ))
            (lib.nameValuePair "SUPER+SHIFT,${w}" (
              lib.optional (cfg.mainDisplay != null) "tagmon,${cfg.mainDisplay}"
              ++ [
                "tag,${w}"
              ]
            ))
          ]) (map toString (lib.range 1 5))
        ))
        // {
          "SUPER,j" = "focusdir,down";
          "SUPER,k" = "focusdir,up";
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
          "SUPER,g" = "setlayout,fair";
          "SUPER+CTRL,g" = "setlayout,vertical_fair";
          "SUPER,v" = "setlayout,vertical_tile";
          "SUPER,w" = "spawn,${mango-toggle-monocle}";
          "SUPER,N" = "setlayout,scroller";
          "SUPER,d" = "setlayout,dwindle";
          "SUPER,M" = "switch_proportion_preset";

          "SUPER,e" = "togglefloating";
          "SUPER,f" = "togglefullscreen";
          "SUPER+CTRL,f" = "togglefakefullscreen";

          "NONE,XF86AudioLowerVolume" = "spawn,${lib.getExe pkgs.pamixer} -d 1";
          "NONE,XF86AudioRaiseVolume" = "spawn,${lib.getExe pkgs.pamixer} -i 1";
          "SHIFT,XF86AudioLowerVolume" = "spawn,${lib.getExe pkgs.pamixer} -d 1 --allow-boost";
          "SHIFT,XF86AudioRaiseVolume" = "spawn,${lib.getExe pkgs.pamixer} -i 1 --allow-boost";

          "SUPER,z" = "spawn,makoctl dismiss";
          "SUPER+CTRL,z" = "spawn,makoctl restore";
          "NONE,Print" = "spawn,screenshot";
          "SHIFT,Print" = "spawn_shell,screenshot 'current window'";
          "CTRL+SHIFT,Print" = "spawn_shell,screenshot 'current monitor'";

          "SUPER,s" = "spawn,search";
          "SUPER,c" = "spawn,rofi -modi clipboard:cliphist-rofi-img -show clipboard -show-icons";
          "SUPER,b" = "spawn,${lib.getExe pkgs.rofi-bluetooth}";

          "SUPER,Tab" = "focusstack,next";
          "SUPER+SHIFT,Tab" = "focusstack,prev";

          "SUPER,y" = {
            name = "togglejumphack";
            returnByDefault = true;
            binds.bindr."SUPER,SUPER_L" = "togglejump";
          };

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
      touchgesturebind = {
        # swipe,edge,distance,fingers
        "up,any,any,3" = "spawn,pkill -SIGRTMIN wvkbd";
        "up,bottom,short,1" = "spawn,pkill -SIGRTMIN wvkbd";

        "up,bottom,medium,1" = "toggleoverview";
        "down,top,any,1" =
          "spawn,qs -c ${hmConfig.programs.quickshell.activeConfig} ipc call app-menu toggle";

        "down_left,top,medium,1" = "killclient";
        "right,left,any,3" = "reload_config";

        "left,any,any,3" = "viewtoright";
        "right,any,any,3" = "viewtoleft";
        "left,any,any,4" = "tagtoright";
        "right,any,any,4" = "tagtoleft";

        "left,bottom,any,1" = "focusdir,right";
        "right,bottom,any,1" = "focusdir,left";
        "left,bottom,any,2" = "exchange_client,right";
        "right,bottom,any,2" = "exchange_client,left";

        "down,any,any,3" = "spawn,${
          lib.getExe (
            pkgs.werapi.mkRemoteWrapper {
              hostname = config.werapi.hostname;
              targetHostname = "pinenote";
              package = outputs.nixosConfigurations.pinenote.pkgs.systemd;
              name = "busctl";
            }
          )
        } --user call org.pinenote.PineNoteCtl /org/pinenote/PineNoteCtl org.pinenote.Ebc1 GlobalRefresh"; # TODO: remove on fajita (bind rules would be nice)
      };
    };
    common.binds.bind = {
      "SUPER+CTRL,r" = [
        "reload_config"
        "setkeymode,default"
      ];
    };
    leader = {
      enter.bind = "SUPER,space";
      returnByDefault = true;
      binds.bindr."SUPER,space" = {
        command = "spawn,true";
        return = false;
      }; # suppresses sending space up to apps
      binds.bind = {
        "SUPER,o" = "toggleoverlay";
        "SUPER,b" = "toggle_render_border";
        "SUPER,t" =
          "spawn_shell,glide --new-window https://renji-xd.github.io/texthooker-ui/; sleep 1; mmsg dispatch togglefloating; mmsg dispatch toggleoverlay; mmsg dispatch togglefakefullscreen; mmsg dispatch resizewin,540,820; mmsg dispatch movewin,3842,0";
        "SUPER,d" = "toggle_dither";
      };
    };
    clipboard = mkClipboardMode {
      enter.bind = "SUPER,o";
      pasteCmd = "wl-paste -n";
      copyCmdOther = "wl-copy -p";
    };
    primary = mkClipboardMode {
      enter.bind = "SUPER,p";
      pasteCmd = "wl-paste -np";
      copyCmdOther = "wl-copy";
    };
    run = {
      enter.bind = "SUPER,r";
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
      enter.bind = "SUPER,x";
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
    qocr =
      let
        mkQocrCmd = c: "spawn_shell,qocr ipc call ocr ${c}";
        binds = {
          "SUPER,s" = mkQocrCmd "scan";
          "SUPER,f" =
            mkQocrCmd "scan_output $(mmsg get all-monitors | ${lib.getExe pkgs.jq} -r '.monitors[] | select(.active) | .name')";
          "SUPER,g" = mkQocrCmd "scan_fullscreen";
          "SUPER,r" = mkQocrCmd "rescan";
          "SUPER,c" = {
            name = "qocrc";
            returnByDefault = true;
            binds.bind = {
              "SUPER,c" = mkQocrCmd "clear_overlay";
              "SUPER,r" = mkQocrCmd "clear_all";
            };
          };
          "SUPER,x" = {
            name = "qocra";
            returnByDefault = true;
            binds.bind = {
              "SUPER,x" = "spawn_shell,anki-helper 'current monitor'";
              "SUPER,s" = "spawn_shell,anki-helper 'current monitor'";
              "SUPER+CTRL,s" = "spawn,anki-helper";
              "SUPER,d" = "spawn_shell,${lib.getExe pkgs.libnotify} $(anki-helper print Expression) -t 1500";
              "SUPER,q" = "spawn,anki-helper show";
            };
          };
          "SUPER,w" = mkQocrCmd "show_region";
          "SUPER,v" = mkQocrCmd "toggle_config overlayOnHover";
          "SUPER,d" = mkQocrCmd "toggle_config showOverlay";
          "SUPER,q" = mkQocrCmd "toggle_config autoRescan";
          "SUPER,z" = mkQocrCmd "toggle_config yomitan.autoPlayFirstAudio";
          "SUPER,e" = qocr-trigger-popup;
          "SUPER,t" = {
            name = "qocrt";
            recEnterIsReturn = true;
            return = { };
            binds = lib.recursiveUpdate (convertBindModes cfg.bindModes "qocrt") {
              bind = cfg.bindModes.default.binds.bind;
              bindp."NONE,SHIFT_L" = "spawn,${pkgs.writeScript "qocr-trigger-hover" ''
                if [ "$(qocr ipc call ocr hover_on)" == "true" ]; then
                  ${qocr-trigger-popup-script}
                fi
              ''}";
              bindpr."SHIFT,SHIFT_L" = mkQocrCmd "hover_off";
              bindp."none,Escape" = mkQocrCmd "close_popup";
            };
          };
        };
      in
      {
        enter.bind = "SUPER,a";
        onEntry = mkQocrCmd "set_config japaneseOnly true";
        returnByDefault = true;
        binds.bind = {
          "SUPER,a" = {
            name = "qocre";
            onEntry = mkQocrCmd "set_config japaneseOnly false";
            onReturnPre = "spawn_shell,sleep 1; qocr ipc call ocr set_config japaneseOnly true";
            returnByDefault = true;
            binds.bind = stripNestedModes binds;
          };
        }
        // binds;
      };
    kill = {
      enter.bind = [
        "SUPER,q"
        "SUPER+CTRL,q"
        "SUPER+SHIFT,q"
      ];
      returnByDefault = true;
      binds.bind = {
        "SUPER,q" = "killclient";
        "SUPER+CTRL,q" = "spawn,${force-kill}";
        "SUPER+SHIFT,q" = "spawn,${force-kill}";
      };
    };
  };
in
{
  imports = [
    inputs.mango.nixosModules.mango
  ];
  options.werapi.${moduleName} = {
    enable = lib.mkOption {
      default = config.werapi.graphics.enable;
      description = "Whether to enable ${moduleName}.";
      type = lib.types.bool;
    };
    mainDisplay = lib.mkOption {
      default = null;
    };
    defaultLayout = lib.mkOption {
      default = "tile";
    };
    bindModes = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      apply = userModes: lib.recursiveUpdate bindModes userModes;
    };
  };
  config = lib.mkIf cfg.enable {
    home-manager.sharedModules = [
      inputs.mango.hmModules.mango
    ];
    programs.mango.enable = true;
    services.greetd = {
      enable = true;
      settings = rec {
        mango = {
          command = "mango 2>&1 | ${lib.getExe' pkgs.systemd "systemd-cat"} -t mango";
          # command = "mango -d 2>&1 | ${lib.getExe' pkgs.systemd "systemd-cat"} -t mango";
          # command = "~/mango -d 2>&1 | ${lib.getExe' pkgs.systemd "systemd-cat"} -t mango";
          user = config.werapi.username;
        };
        default_session = mango;
      };
    };
    hm = {
      wayland.systemd.target = "mango-session.target";
      services.polkit-gnome.enable = true;
      wayland.windowManager.mango = {
        enable = true;
        systemd.enable = false;
        package = config.programs.mango.package;
        settings = with config.lib.stylix.colors; {
          animations = 1;
          animation_fade_in = 0;
          animation_fade_out = 0;
          animation_type_close = "slide";
          animation_duration_move = 300;
          animation_duration_open = 200;
          animation_duration_tag = 250;
          animation_duration_close = 250;
          animation_duration_focus = 250;

          gappih = 0;
          gappiv = 0;
          gappoh = 0;
          gappov = 0;
          borderpx = 1;
          no_border_when_single = 0;
          tab_bar_height = 0;

          rootcolor = "0x${base00}ff";
          bordercolor = "0x${base02}ff";
          focuscolor = "0x${cyan}ff";
          urgentcolor = "0x${red}ff";
          dropcolor = "0x${base0F}50";
          overlaycolor = "0x${base0C}ff";

          jump_label_decorate_fg_color = "0x${base06}ff";
          jump_label_decorate_bg_color = "0x${base00}80";
          jump_label_decorate_focus_fg_color = "0x${base00}00";
          jump_label_decorate_focus_bg_color = "0x${base06}ff";
          jump_label_decorate_border_color = "0x${base0F}ff";

          jump_label_decorate_border_width = 1;
          jump_label_decorate_corner_radius = 0;

          repeat_rate = 100;
          repeat_delay = 300;
          xkb_rules_layout = "pl";
          middle_button_emulation = 1;
          drag_lock = 0;

          new_is_master = 0;
          default_mfact = 0.5;
          enable_hotarea = 0;
          warpcursor = 0;
          sloppyfocus = 1;
          axis_bind_apply_timeout = 10;
          drag_tile_to_tile = 1;
          cursor_hide_timeout = 5;
          focus_on_activate = 0;
          focus_cross_monitor = 1;
          view_current_to_back = 0;
          drag_corner = 4;

          scroller_structs = 0;
          scroller_default_proportion = 1;
          scroller_proportion_preset = "0.5,1.0";

          zoom_centered = 0;
          zoom_speed = 0.2;
          zoom_max = 20;

          windowrule = "title:Chatterino - Overlay,isoverlay:1";
          env = [
            "QT_QPA_PLATFORM,wayland"
            "MOZ_ENABLE_WAYLAND,1"
            "NIXOS_OZONE_WL,1"
            "ELECTRON_OZONE_PLATFORM_HINT,wayland"
            "OZONE_PLATFORM,wayland"
            "GDK_BACKEND,wayland"
            "WINDOW_MANAGER,mango"
            "SDL_VIDEODRIVER,wayland"
          ];

          exec-once = [
            # script needed due to 256 char limit
            (pkgs.writeShellScript "update-dbus-env-mango" ''
              ${pkgs.dbus}/bin/dbus-update-activation-environment --systemd NIXOS_OZONE_WL XCURSOR_THEME XCURSOR_SIZE PATH SDL_VIDEODRIVER WINDOW_MANAGER GDK_BACKEND OZONE_PLATFORM ELECTRON_OZONE_PLATFORM_HINT MOZ_ENABLE_WAYLAND QT_QPA_PLATFORM
            '')
            "systemctl --user reset-failed"
            "systemctl --user restart mango-session.target"

            (pkgs.writeShellScript "set-tagrules" (
              builtins.concatStringsSep "\n" (
                map (id: "mmsg dispatch setoption,tagrule,id:${toString id},layout_name:${cfg.defaultLayout}") (
                  lib.range 1 9
                )
              )
            ))
          ]
          ++ lib.optional config.werapi.wvkbd.enable "sleep 5; systemctl --user restart fcitx5-daemon";
        };
        extraConfig = parseBindModes cfg.bindModes;
      };

      systemd.user.targets.mango-session = {
        Unit = {
          Description = "mango compositor session";
          Documentation = [ "man:systemd.special(7)" ];
          BindsTo = [ "graphical-session.target" ];
          Wants = [ "graphical-session-pre.target" ];
          After = [ "graphical-session-pre.target" ];
        };
      };
    };
  };
}
