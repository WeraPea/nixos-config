{
  inputs,
  ...
}:
let
  moduleName = "vr";
in
{
  flake.modules.${moduleName}.nixos =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.werapi.${moduleName};
      hmConfig = config.home-manager.users.${config.werapi.username};
    in
    {
      imports = [
        inputs.nixpkgs-xr.nixosModules.nixpkgs-xr
      ];
      options.werapi.${moduleName} = {
        enable = lib.mkOption {
          default = config.werapi.gaming.enable;
          description = "Whether to enable ${moduleName}.";
          type = lib.types.bool;
        };
      };
      config = lib.mkIf cfg.enable {
        nixpkgs.xr.enable = true;
        systemd.user.services.monado.environment = {
          STEAMVR_LH_ENABLE = "1";
          XRT_COMPOSITOR_COMPUTE = "1";
        };
        services.monado = {
          enable = true;
          defaultRuntime = true;
          highPriority = true;
        };
        environment.systemPackages = [
          inputs.bs-scrobbler.packages.${pkgs.stdenv.hostPlatform.system}.bs-scrobbler
          pkgs.lighthouse-steamvr
          pkgs.wayvr
          pkgs.werapi.vrlink
          (pkgs.writeShellScriptBin "monado-steamvr-switch" ''
            if [[ ! -L $HOME/.config/openvr/openvrpaths.vrpath ]]; then
              echo "$HOME/.config/openvr/openvrpaths.vrpath is not a symbolic link"
              exit 1
            fi
            rm $HOME/.config/openvr/openvrpaths.vrpath
            if [[ "$1" == "monado" ]]; then
              ln -s $HOME/.config/openvr/openvrpaths.vrpath-monado $HOME/.config/openvr/openvrpaths.vrpath
            elif [[ "$1" == "steamvr" ]]; then
              ln -s $HOME/.config/openvr/openvrpaths.vrpath-steamvr $HOME/.config/openvr/openvrpaths.vrpath
            fi
          '')
          (pkgs.writeShellScriptBin "steamvr-open" ''
            monado-steamvr-switch steamvr
            steam steam://rungameid/250820 # steamvr
            sleep 5
            steam-run wlx-overlay-s --openvr --show --replace & # text doesn't show up (looks for font files in /usr/ (fhs env?)), without steam-run doesn't start at all?
            sleep 5
            vrlink
          '')
          (pkgs.writeShellScriptBin "steamvr-quick-calibrate" ''
            LD_LIBRARY_PATH=$HOME/.steam/steam/steamapps/common/SteamVR/bin/linux64:${pkgs.sdl2-compat}/lib \
              steam-run $HOME/.steam/steam/steamapps/common/SteamVR/bin/linux64/vrcmd --pollposes &
            poll_pid=$!
            sleep 5

            LD_LIBRARY_PATH=$HOME/.steam/steam/steamapps/common/SteamVR/bin/linux64 \
              steam-run $HOME/.steam/steam/steamapps/common/SteamVR/bin/linux64/vrcmd --resetroomsetup

            kill $poll_pid
            wait $poll_pid 2>/dev/null || true
          '')
        ];
        hm.xdg.configFile."openxr/1/active_runtime.json".source =
          "${pkgs.monado}/share/openxr/1/openxr_monado.json";
        hm.xdg.configFile."openvr/openvrpaths.vrpath-monado".text = ''
          {
            "config" :
            [
              "${hmConfig.xdg.dataHome}/Steam/config"
            ],
            "external_drivers" : null,
            "jsonid" : "vrpathreg",
            "log" :
            [
              "${hmConfig.xdg.dataHome}/Steam/logs"
            ],
            "runtime" :
            [
              "${pkgs.xrizer}/lib/xrizer"
            ],
            "version" : 1
          }
        '';
        # "${pkgs.opencomposite}/lib/opencomposite"
        # "${pkgs.xrixer-custom}/lib/xrizer"
        # env PRESSURE_VESSEL_FILESYSTEMS_RW=$XDG_RUNTIME_DIR/monado_comp_ipc %command%
      };
    };
}
