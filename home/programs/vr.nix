{
  config,
  pkgs,
  inputs,
  ...
}:
{
  home.packages = [
    # inputs.nixpkgs-xr.packages.${pkgs.system}.proton-ge-rtsp-bin
    inputs.nixpkgs-xr.packages.${pkgs.system}.wlx-overlay-s
    pkgs.lighthouse-steamvr
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
