{
  outputs,
  config,
  pkgs,
  lib,
  ...
}:
{
  options = {
    streamlink.enable = lib.mkEnableOption "Enables streamlink";
  };
  config = lib.mkIf config.streamlink.enable {
    home.packages = with pkgs; [
      streamlink
      streamlink-twitch-gui-bin
    ];
    xdg.dataFile.streamlink-ttvlol = {
      target = "streamlink/plugins/twitch.py";
      source = outputs.packages.${pkgs.stdenv.hostPlatform.system}.streamlink-ttvlol;
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
}
