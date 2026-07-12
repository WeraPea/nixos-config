{
  flake.wrappers.beets =
    {
      config,
      lib,
      pkgs,
      wlib,
      ...
    }@top:
    let
      inherit (lib) mkOption;
    in
    {
      imports = [ wlib.modules.default ];
      options = {
        settings = mkOption {
          type = wlib.types.structuredValueWith { typeName = "YAML 1.1"; };
          default = { };
        };
      };
      config = {
        constructFiles.generatedConfig = {
          relPath = "config.yaml";
          content = lib.generators.toYAML { } config.settings;
        };
        flags."-c" = config.constructFiles.generatedConfig.path;
        package = lib.mkDefault pkgs.beets;
        install.modules.nixos =
          {
            config,
            lib,
            ...
          }:
          let
            cfg = top.config.install.getWrapperConfig config;
          in
          lib.mkIf cfg.enable {
            environment.systemPackages = [ cfg.wrapper ];
          };
      };
    };
}
