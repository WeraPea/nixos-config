{
  inputs,
  ...
}:
let
  moduleName = "sops";
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
    in
    {
      imports = [
        inputs.sops-nix.nixosModules.sops
      ];
      options.werapi.${moduleName} = {
        enable = lib.mkOption {
          default = config.werapi.defaultModules.enable;
          description = "Whether to enable ${moduleName}.";
          type = lib.types.bool;
        };
      };
      config = lib.mkIf cfg.enable {
        sops = {
          defaultSopsFormat = "yaml";
          age.keyFile = "/var/lib/sops-nix/key.txt";
          defaultSopsFile = "/etc/sops/secrets.yaml";
          validateSopsFiles = false;
        };
        environment.sessionVariables."SOPS_AGE_KEY_FILE" = config.sops.age.keyFile;
      };
    };
}
