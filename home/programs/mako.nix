{
  lib,
  config,
  ...
}:
{
  options = {
    mako.enable = lib.mkEnableOption "enables mako";
  };
  config =
    with config.lib.stylix.colors.withHashtag;
    with config.stylix.fonts;
    let
      makoOpacity = lib.toHexString (((builtins.ceil (config.stylix.opacity.popups * 100)) * 255) / 100);
    in
    lib.mkIf config.mako.enable {
      stylix.targets.mako.enable = false;
      services.mako = {
        enable = true;
        settings = {
          backgroundColor = base00 + makoOpacity;
          borderColor = orange;
          progressColor = "over ${yellow}";
          textColor = base05;
          font = "${sansSerif.name} ${toString sizes.popups}";
          height = 150;
          width = 300;
          layer = "overlay";
          borderSize = 2;

          "urgency=low" = {
            background-color = "${base00}${makoOpacity}";
            border-color = green;
            text-color = base05;
          };
          "urgency=high" = {
            background-color = "${base00}${makoOpacity}";
            border-color = red;
            text-color = base05;
          };
        };
      };
    };
}
