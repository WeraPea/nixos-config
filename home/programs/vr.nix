{
  osConfig,
  config,
  pkgs,
  lib,
  ...
}:
lib.mkIf osConfig.gaming.enable {
  home.packages = [
    pkgs.wlx-overlay-s
    pkgs.wayvr-dashboard
    pkgs.lighthouse-steamvr
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
  xdg.configFile."openxr/1/active_runtime.json".source =
    "${pkgs.monado}/share/openxr/1/openxr_monado.json";
  xdg.configFile."openvr/openvrpaths.vrpath-monado".text = ''
    {
      "config" :
      [
        "${config.xdg.dataHome}/Steam/config"
      ],
      "external_drivers" : null,
      "jsonid" : "vrpathreg",
      "log" :
      [
        "${config.xdg.dataHome}/Steam/logs"
      ],
      "runtime" :
      [
        "${pkgs.xrizer}/lib/xrizer"
      ],
      "version" : 1
    }
  '';
  # "${pkgs.opencomposite}/lib/opencomposite"
  # "${outputs.packages.${pkgs.system}.xrizer-experimental2}/lib/xrizer"
  # env PRESSURE_VESSEL_FILESYSTEMS_RW=$XDG_RUNTIME_DIR/monado_comp_ipc %command%
}
