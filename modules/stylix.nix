{
  inputs,
  ...
}:
let
  moduleName = "stylix";
in
{
  flake.modules.${moduleName}.nixos =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.werapi.${moduleName};
    in
    {
      imports = [
        inputs.stylix.nixosModules.stylix
      ];
      options.werapi.${moduleName} = {
        enable = lib.mkOption {
          default = config.werapi.defaultModules.enable;
          description = "Whether to enable ${moduleName}.";
          type = lib.types.bool;
        };
      };
      config = lib.mkIf cfg.enable {
        stylix = {
          enable = true;
          base16Scheme = lib.mkDefault {
            scheme = "molokai";
            base00 = "#121212";
            base01 = "#303030";
            base02 = "#505050";
            base03 = "#707070";
            base04 = "#909090";
            base05 = "#c0c0c0";
            base06 = "#e0e0e0";
            base07 = "#f9f9f9";
            base08 = "#fa2772";
            base09 = "#fc9620";
            base0A = "#d4c96e";
            base0B = "#a7e22e";
            base0C = "#56b7a5";
            base0D = "#55bcce";
            base0E = "#ae82ff";
            base0F = "#cc6633";
          };
          fonts = {
            monospace = {
              package = pkgs.werapi.udev-gothic-hs-nf;
              name = "UDEV Gothic 35HSDZNFLG";
            };
            sizes = {
              applications = 12;
              desktop = 12;
              popups = 12;
              terminal = 10;
            };
          };
          cursor = {
            package = pkgs.bibata-cursors;
            name = "Bibata-Modern-Classic";
            size = 24;
          };
          opacity = {
            applications = 0.8;
            desktop = 0.8;
            popups = 0.8;
            terminal = 0.8;
          };
          targets.gtksourceview.enable = false;
        };
      };
    };
}
