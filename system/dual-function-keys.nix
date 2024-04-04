{ pkgs, ... }:
{
  environment.etc."dual-function-keys.yaml".text = ''
    MAPPINGS:
      - KEY: KEY_LEFTMETA
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
    '';
  };
}
