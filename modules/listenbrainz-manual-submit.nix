{
  flake,
  ...
}:
let
  moduleName = "listenbrainz-manual-submit";
in
{

  flake.wrappers.${moduleName} =
    {
      config,
      lib,
      pkgs,
      wlib,
      ...
    }:
    let
      inherit (lib) mkOption;
    in
    {
      imports = [ wlib.modules.default ];
      options = {
        tokenFile = mkOption {
          type = lib.types.nullOr lib.types.path;
          default = null;
        };
      };
      config = {
        flags."--token-file" = config.tokenFile;
        package = lib.mkDefault pkgs.werapi.listenbrainz-manual-submit;
      };
    };

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
        flake.wrappers.listenbrainz-manual-submit.install
      ];
      options.werapi.${moduleName} = {
        enable = lib.mkOption {
          default = false;
          description = "Whether to enable ${moduleName}.";
          type = lib.types.bool;
        };
      };
      config = lib.mkIf cfg.enable {
        wrappers.listenbrainz-manual-submit.tokenFile = config.sops.secrets.listenbrainz_token.path;
        environment.systemPackages = [ config.wrappers.listenbrainz-manual-submit.wrapper ];
      };
    };
}
