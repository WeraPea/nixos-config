{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
lib.mkIf config.gaming.enable {
  systemd.user.services.monado.environment = {
    STEAMVR_LH_ENABLE = "1";
    XRT_COMPOSITOR_COMPUTE = "1";
    WMR_HANDTRACKING = "0"; # TODO:
    AMD_VULKAN_ICD = "RADV";
  };
  services.monado = {
    package = inputs.nixpkgs-xr.packages.${pkgs.system}.monado;
    enable = true;
    defaultRuntime = true;
  };
}
