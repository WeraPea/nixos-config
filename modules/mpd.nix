{
  config,
  lib,
  pkgs,
  ...
}:
let
  moduleName = "mpd";
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
    hm.services.mpd = {
      enable = true;
      network.listenAddress = "any";
      musicDirectory = "/mnt/mnt3/music/";
      playlistDirectory = "/mnt/mnt3/music/playlists/";
      extraConfig = ''
        audio_output {
          type "pipewire"
          name "PipeWire Sound Server"
        }
      '';
    };
    hm.services.mpdris2 = {
      enable = true;
    };
    sops.secrets.listenbrainz_token = { };
    hm.services.mpdscribble = {
      enable = true;
      endpoints.listenbrainz = {
        passwordFile = config.sops.secrets.listenbrainz_token.path;
        username = "werapi";
      };
    };
    environment.systemPackages = with pkgs; [
      mpc
      rmpc
      cantata
    ];
  };
}
