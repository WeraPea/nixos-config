let
  moduleName = "mpd";
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
        networking.firewall.allowedTCPPorts = [ 6600 ];
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
        sops.secrets.listenbrainz_token = {
          owner = config.werapi.username;
        };
        hm.services.listenbrainz-mpd = {
          enable = true;
          settings.submission.token_file = config.sops.secrets.listenbrainz_token.path;
        };
        environment.systemPackages = with pkgs; [
          mpc
          rmpc
          cantata
        ];
      };
    };
}
