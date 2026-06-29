let
  moduleName = "mako";
in
{
  flake.modules.${moduleName}.nixos =
    {
      config,
      lib,
      ...
    }:
    with config.lib.stylix.colors.withHashtag;
    with config.stylix.fonts;
    let
      cfg = config.werapi.${moduleName};
      makoOpacity = lib.toHexString (((builtins.ceil (config.stylix.opacity.popups * 100)) * 255) / 100);
    in
    {
      options.werapi.${moduleName} = {
        enable = lib.mkOption {
          default = config.werapi.graphics.enable;
          description = "Whether to enable ${moduleName}.";
          type = lib.types.bool;
        };
      };
      config = lib.mkIf cfg.enable {
        hm.stylix.targets.mako.enable = false;
        hm.services.mako = {
          enable = true;
          settings = {
            background-color = base00;
            border-color = orange;
            progress-color = "over ${yellow}";
            text-color = base05;
            font = "${sansSerif.name} ${toString sizes.popups}";
            height = 150;
            width = 300;
            layer = "overlay";
            border-size = 2;

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
            "mode=dnd" = {
              invisible = true;
            };
          };
        };
      };
    };
}
