{
  flake.wrappers.mango =
    {
      config,
      lib,
      pkgs,
      wlib,
      ...
    }:
    let
      inherit (config) mango-lib;
    in
    {
      imports = [
        wlib.wrapperModules.mangowc
      ];
      options = {
        mango-lib = lib.mkOption {
          type = lib.types.lazyAttrsOf lib.types.anything;
        };
        mainDisplay = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
        };
        defaultLayout = lib.mkOption {
          type = lib.types.str;
          default = "tile";
        };
        bindModes = lib.mkOption {
          type = lib.types.lazyAttrsOf lib.types.anything;
        };
        nixos-config = lib.mkOption {
          type = lib.types.raw;
        };
      };
      config = {
        # modified from niri module (mango does not provide a unit file so you need to start this service yourself)
        buildCommand.mangoReloadConfig = {
          after = [ "symlinkScript" ];
          data = ''
            mkdir -p ${placeholder config.outputName}/lib/systemd/user/;
            cat > ${placeholder config.outputName}/lib/systemd/user/mango-reload.service<<EOF
            [Unit]
            X-Reload-Triggers=${config.constructFiles.generatedConfig.path}

            [Service]
            Type=oneshot
            RemainAfterExit=yes
            ExecStart=${lib.getExe' pkgs.coreutils "true"}
            ExecReload=${lib.getExe' config.package "mmsg"} dispatch load_config_file,${config.constructFiles.generatedConfig.path}
            X-ReloadIfChanged=true
            EOF
          '';
        };
        extraConfig = mango-lib.parseBindModes config.bindModes;
        mango-lib = {
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
              rsiLimit ? 2,
              recEnterIsReturnReturnToPass ? "default",
              cloneKeymodes ? [ ],
              ...
            }@args:
            let
              recEnterIsReturn =
                if args ? recEnterIsReturn && lib.isBool args.recEnterIsReturn then
                  args.recEnterIsReturn
                else
                  false;
              name = if (lib.isString recSubmodeOf) then "${recSubmodeOf}-${args.name}" else args.name;
              argsWithDefaults = args // {
                inherit
                  name
                  returnByDefault
                  onEntry
                  onReturnPre
                  returnTo
                  outerKeymode
                  recSubmodeOf
                  rsi
                  rsiLimit
                  recEnterIsReturn
                  ;
              };
              baseMode = mode: lib.last (lib.splitString "-" mode);
              mkBind =
                bindType: binding: command:
                let
                  command' =
                    builtins.replaceStrings # _
                      (lib.mapAttrsToList (name: value: "%${name}%") argsWithDefaults)
                      (lib.mapAttrsToList (name: value: toString value) argsWithDefaults)
                      command;
                  command'' =
                    if (lib.hasPrefix "spawn" command' && builtins.stringLength "${binding},${command'}" > 255) then
                      let
                        split-com = lib.splitString "," command';
                      in
                      "${builtins.head split-com},${pkgs.writeShellScript "mango-bind-too-long" (builtins.concatStringsSep "," (builtins.tail split-com))}"
                    else
                      command';
                in
                assert lib.assertMsg (
                  builtins.stringLength "${binding},${command''}" <= 255
                ) "mango '${bindType}=${binding},${command''}' binding too long (>255 after '=')";
                "${bindType}=${binding},${command''}";
              emitTransition =
                commands: targetMode: binds:
                builtins.concatLists (
                  lib.mapAttrsToList (
                    bindType: bindings:
                    (builtins.concatMap (
                      binding:
                      (builtins.concatMap (com: [ (mkBind bindType binding com) ]) (lib.toList commands))
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
                            mango-lib.parseBindMode (
                              {
                                outerKeymode = name;
                                enter.${bindType} = bind;
                              }
                              // com
                              // {
                                inherit
                                  recSubmodeOf
                                  rsi
                                  rsiLimit
                                  recEnterIsReturn
                                  recEnterIsReturnReturnToPass
                                  ;
                              }
                            )
                        else
                          [ (mkBind bindType bind com) ];
                    in
                    lib.optionals shouldReturn (
                      builtins.concatMap (com: [ (mkBind bindType bind com) ]) (lib.toList onReturnPre)
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
              ]
              ++ (builtins.concatLists (
                map (keymode: mango-lib.parseBindMode (args // { cloneKeymodes = [ ]; } // keymode)) cloneKeymodes
              ));
          parseBindModes =
            bindModes:
            builtins.concatStringsSep "\n" (
              builtins.concatLists (
                lib.mapAttrsToList (name: value: mango-lib.parseBindMode ({ inherit name; } // value)) bindModes
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
          qocr-trigger-popup-script = pkgs.writeShellScript "qocr-trigger-popup" ''
            ${lib.getExe pkgs.jq} -rn \
              --argjson monitors "$(mmsg get all-monitors)" \
              --argjson cursor "$(mmsg get cursorpos)" \
              '$monitors.monitors[] | select(.name == $cursor.monitor) as $monitor |
              ($cursor.x|round - $monitor.x),
              ($cursor.y|round - $monitor.y),
              ($cursor.monitor)' \
              | xargs qocr ipc call ocr trigger_popup
          '';
          qocr-trigger-popup = "spawn,${mango-lib.qocr-trigger-popup-script}";
          force-kill = pkgs.writeShellScript "force-kill" ''
            export PATH="${lib.makeBinPath [ pkgs.jq ]}:$PATH"
            kill -9 $(mmsg get client $(mmsg get all-monitors | jq '.monitors[] | select(.active) | .active_client.id') | jq '.pid')
          '';
          long-press-helper = pkgs.writeShellScript "mango-long-press-keybind-helper" ''
            export PATH="${lib.makeBinPath [ pkgs.jq ]}:$PATH"
            time=$1
            keymode_name=$2
            outer_keymode_name=$3
            returnTo=$4
            command=$5
            tmp1=$(mktemp -u)
            mkfifo "$tmp1"

            timeout $time mmsg watch keymode > "$tmp1" &
            mmsg_pid1=$!

            jq -r --unbuffered '.keymode' < "$tmp1" | while read -r keymode; do
              if [ "$keymode" != "$keymode_name" ]; then
                kill "$mmsg_pid1"
                rm "$tmp1"
                kill $$
                break
              fi
            done &
            sleep $time
            mmsg dispatch "$command"

            tmp2=$(mktemp -u)
            mkfifo "$tmp2"

            mmsg watch keymode > "$tmp2" &
            mmsg_pid2=$!

            jq -r --unbuffered '.keymode' < "$tmp2" | while read -r keymode; do
              if [ "$keymode" = "$outer_keymode_name" ]; then
                (sleep 1 && mmsg dispatch setkeymode,$returnTo) &
                timer_pid=$!
              else
                if [ -n "$timer_pid" ]; then
                  kill "$timer_pid" 2>/dev/null
                  kill "$mmsg_pid2"
                  rm "$tmp2"
                  break
                fi
              fi
            done &

            mmsg dispatch setkeymode,$outer_keymode_name

            wait
          '';
          mkLongPressBind =
            {
              name,
              longCommand,
              shortCommand,
              time ? 1,
              bind,
            }:
            {
              inherit name;
              returnByDefault = true;
              onEntry = "spawn_shell,${mango-lib.long-press-helper} ${toString time} %name% %name%1 %returnTo% ${lib.escapeShellArg longCommand}";
              binds.bindr.${bind} = shortCommand;
              cloneKeymodes = [
                {
                  name = name + "1";
                  enter = { };
                  return = { };
                  returnByDefault = false;
                  binds.bind.${bind} = {
                    name = name + "2";
                    returnByDefault = false;
                    onEntry = "spawn_shell,${mango-lib.long-press-helper} ${toString time} %name% %outerKeymode% %returnTo% ${lib.escapeShellArg longCommand}";
                    binds.bindr.${bind} = "setkeymode,%returnTo%";
                  };
                }
              ];
            };
        };
      };
    };
}
