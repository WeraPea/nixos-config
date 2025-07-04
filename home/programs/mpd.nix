{
  pkgs,
  lib,
  config,
  ...
}:
{
  options = {
    mpd.enable = lib.mkEnableOption "enables mpd";
  };
  config = lib.mkIf config.mpd.enable {
    services.mpd = {
      enable = true;
      network.listenAddress = "any";
      musicDirectory = "/home/wera/music/Downloads/";
      extraConfig = ''
        audio_output {
          type "pipewire"
          name "PipeWire Sound Server"
        }
      '';
    };
    services.mpdris2 = {
      enable = true;
    };
    sops.secrets.listenbrainz_token = { };
    services.mpdscribble = {
      enable = true;
      endpoints.listenbrainz = {
        passwordFile = config.sops.secrets.listenbrainz_token.path;
        username = "werapi";
      };
    };
    home.packages = with pkgs; [
      mpc
      rmpc
      cantata
    ];
  };
}
