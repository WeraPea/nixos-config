{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
{
  options = {
    koreader.enable = lib.mkEnableOption "enables koreader";
  };
  config = lib.mkIf config.koreader.enable {
    home.packages = [ pkgs.koreader ];
    xdg.configFile."koreader/plugins/rakuyomi.koplugin".source =
      let
        buildSystem = pkgs.stdenv.buildPlatform.system;
        variant =
          {
            "x86_64-linux" = "desktop";
            "aarch64-linux" = "aarch64";
          }
          .${pkgs.system} or (throw "Unsupported system: ${pkgs.system}");
      in
      inputs.rakuyomi.packages.${buildSystem}.rakuyomi.${variant};
    xdg.configFile."koreader/rakuyomi/settings.json".text = ''
      {
        "$schema": "https://github.com/hanatsumi/rakuyomi/releases/download/main/settings.schema.json",
        "source_lists": [
          "https://raw.githubusercontent.com/Skittyblock/aidoku-community-sources/refs/heads/gh-pages/index.min.json"
        ],
        "languages": ["en"]
      }
    '';
  };
}
