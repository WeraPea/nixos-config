{
  config,
  lib,
  pkgs,
  ...
}:
let
  moduleName = "dual-function-keys";
  cfg = config.werapi.${moduleName};
in
{
  options.werapi.${moduleName} = {
    enable = lib.mkOption {
      default = config.werapi.defaultModules.enable;
      description = "Whether to enable ${moduleName}.";
      type = lib.types.bool;
    };
  };
  config = lib.mkIf cfg.enable {
    environment.etc."dual-function-keys.yaml".text = ''
      MAPPINGS:
        - KEY: KEY_LEFTMETA
          TAP: KEY_ESC
          HOLD: KEY_LEFTMETA
        - KEY: KEY_CAPSLOCK
          TAP: KEY_ESC
          HOLD: KEY_LEFTMETA
    '';
    services.interception-tools = {
      enable = true;
      plugins = with pkgs.interception-tools-plugins; [ dual-function-keys ];
      udevmonConfig = ''
        - JOB: "${pkgs.interception-tools}/bin/intercept -g $DEVNODE | ${pkgs.interception-tools-plugins.dual-function-keys}/bin/dual-function-keys -c /etc/dual-function-keys.yaml | ${pkgs.interception-tools}/bin/uinput -d $DEVNODE"
          DEVICE:
            NAME: "splitkb.com Kyria rev2*"
        - JOB: "${pkgs.interception-tools}/bin/intercept -g $DEVNODE | ${pkgs.interception-tools-plugins.dual-function-keys}/bin/dual-function-keys -c /etc/dual-function-keys.yaml | ${pkgs.interception-tools}/bin/uinput -d $DEVNODE"
          DEVICE:
            EVENTS:
              EV_KEY: [KEY_CAPSLOCK]
      '';
    };
  };
}
