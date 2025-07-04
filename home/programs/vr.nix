{
  osConfig,
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
lib.mkIf osConfig.gaming.enable {
  home.packages = [
    inputs.nixpkgs-xr.packages.${pkgs.system}.wlx-overlay-s
    inputs.nixpkgs-xr.packages.${pkgs.system}.wayvr-dashboard
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
      export AMD_VULKAN_ICD=RADV
      monado-steamvr-switch steamvr
      steam steam://rungameid/250820 # steamvr
      sleep 5
      wlx-overlay-s --openvr --show --replace &
      sleep 5
      vrlink
    '')
  ];
  xdg.configFile."openxr/1/active_runtime.json".source = "${
    inputs.nixpkgs-xr.packages.${pkgs.system}.monado
  }/share/openxr/1/openxr_monado.json";
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
        "${inputs.nixpkgs-xr.packages.${pkgs.system}.opencomposite-vendored}/lib/opencomposite"
      ],
      "version" : 1
    }
  '';
  # env PRESSURE_VESSEL_FILESYSTEMS_RW=$XDG_RUNTIME_DIR/monado_comp_ipc %command%
}
