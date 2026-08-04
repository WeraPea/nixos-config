let
  moduleName = "bgutil-ytdlp-pot-provider";
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
      options.werapi.${moduleName} = {
        enable = lib.mkOption {
          default = false;
          description = "Whether to enable ${moduleName}.";
          type = lib.types.bool;
        };
      };
      config = lib.mkIf cfg.enable {
        virtualisation.oci-containers = {
          backend = "podman";
          containers = {
            bgutil-ytdlp-pot-provider = {
              image = "docker.io/brainicism/bgutil-ytdlp-pot-provider:${pkgs.python3Packages.bgutil-ytdlp-pot-provider.version}";
              autoStart = true;
              ports = [ "127.0.0.1:4416:4416" ];
            };
          };
        };
      };
    };
}
