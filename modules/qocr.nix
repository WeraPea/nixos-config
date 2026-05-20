{
  config,
  inputs,
  lib,
  ...
}:
let
  moduleName = "qocr";
  cfg = config.werapi.${moduleName};
in
{
  options.werapi.${moduleName} = {
    enable = lib.mkOption {
      default = false;
      description = "Whether to enable ${moduleName}.";
      type = lib.types.bool;
    };
  };
  config = lib.mkIf cfg.enable {
    home-manager.sharedModules = [
      inputs.qocr.homeModules.qocr
    ];
    hm.services.qocr = {
      enable = true;
      settings.yomitan.fetchAudio = true;
    };
  };
}
