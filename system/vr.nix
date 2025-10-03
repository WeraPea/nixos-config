{
  config,
  lib,
  pkgs,
  ...
}:
lib.mkIf config.gaming.enable {
  nixpkgs.xr.enable = true;
  systemd.user.services.monado.environment = {
    STEAMVR_LH_ENABLE = "1";
    XRT_COMPOSITOR_COMPUTE = "1";
    # WMR_HANDTRACKING = "0"; # TODO:
  };
  services.monado = {
    package = pkgs.monado-custom;
    enable = true;
    defaultRuntime = true;
    highPriority = true;
  };
}
