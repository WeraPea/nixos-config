{
  config,
  lib,
  pkgs,
  ...
}:
let
  moduleName = "streamlink";
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
    hm = {
      home.packages = with pkgs; [
        streamlink
        streamlink-twitch-gui-bin
      ];
      xdg.dataFile.streamlink-ttvlol = {
        target = "streamlink/plugins/twitch.py";
        source = pkgs.werapi.streamlink-ttvlol;
      };
      xdg.configFile.streamlink = {
        target = "streamlink/config";
        text = ''
          player=mpv
          default-stream=best
          twitch-disable-ads
          twitch-proxy-playlist=https://eu.luminous.dev,https://eu2.luminous.dev,https://lb-eu.cdn-perfprod.com,https://lb-eu2.cdn-perfprod.com,https://lb-eu4.cdn-perfprod.com,https://lb-eu5.cdn-perfprod.com
          twitch-proxy-playlist-fallback
        '';
      };
    };
  };
}
