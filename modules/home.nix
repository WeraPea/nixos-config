{
  inputs,
  ...
}:
let
  moduleName = "home-manager";
in
{
  flake.modules.${moduleName}.nixos =
    {
      config,
      lib,
      ...
    }:
    let
      cfg = config.werapi.${moduleName};
      hmConfig = config.home-manager.users.${config.werapi.username};
    in
    {
      imports = [
        inputs.home-manager.nixosModules.home-manager
        (lib.mkAliasOptionModule [ "hm" ] [ "home-manager" "users" config.werapi.username ])
      ];

      options.werapi.${moduleName} = {
        enable = lib.mkOption {
          default = config.werapi.defaultModules.enable;
          description = "Whether to enable ${moduleName}.";
          type = lib.types.bool;
        };
      };
      config = lib.mkIf cfg.enable {
        home-manager = {
          useUserPackages = true;
          useGlobalPkgs = true;
        };
        environment.sessionVariables = builtins.mapAttrs (
          name: value: lib.mkDefault value
        ) hmConfig.home.sessionVariables; # hacky
        hm = {
          home = {
            username = config.werapi.username;
            homeDirectory = "/home/${config.werapi.username}";
            pointerCursor.enable = true;
          };
          programs.home-manager.enable = true;
          gtk.enable = lib.mkIf config.werapi.graphics.enable <| lib.mkDefault true;
          programs.zathura.enable = lib.mkIf config.werapi.graphics.enable <| lib.mkDefault true;

          services = {
            cliphist.enable = lib.mkIf config.werapi.graphics.enable <| lib.mkDefault true;
            wl-clip-persist.enable = lib.mkIf config.werapi.graphics.enable <| lib.mkDefault true;
          };
        };
      };
    };
}
