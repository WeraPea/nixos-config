let
  moduleName = "pipewire";
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
          default = config.werapi.graphics.enable;
          description = "Whether to enable ${moduleName}.";
          type = lib.types.bool;
        };
      };
      config = lib.mkIf cfg.enable {
        services.pipewire = {
          alsa.enable = true;
          alsa.support32Bit = true;
          enable = true;
          jack.enable = true;
          pulse.enable = true;
          extraConfig.pipewire = {
            "10-clock-rate" = {
              "context.properties" = {
                "default.clock.rate" = 48000;
              };
            };
          };
          configPackages = [
            (pkgs.writeTextDir "share/pipewire/pipewire.conf.d/10-switch-channels.conf" ''
              context.modules = [
               { name = libpipewire-module-loopback
                    args = {
                        node.description = "Analog Output - channel remap"
                        capture.props = {
                            media.class = Audio/Sink
                            node.name = analog_output_channel_remap
                            audio.position = [ FL FR ]
                            priority.driver = 2000
                            priority.session = 2000
                        }
                        playback.props = {
                            node.name = analog_output_channel_remap_playback
                            audio.position = [ FR FL ]
                            target.object = "alsa_output.pci-0000_18_00.6.analog-stereo"
                        }
                    }
                }
              ]
            '')
          ];
          wireplumber.configPackages = [
            (pkgs.writeTextDir "share/wireplumber/wireplumber.conf.d/51-mpv-fix.conf" ''
              stream.rules = [
                {
                  matches = [
                    {
                      application.name = "mpv"
                    }
                  ]
                  actions = {
                    update-props = {
                      state.restore-props = false
                    }
                  }
                }
              ]
            '') # taken from https://howthefu.cc/posts/04/index.html
            (pkgs.writeTextDir "share/wireplumber/wireplumber.conf.d/52-linking-settings.conf" ''
              wireplumber.settings = {
                linking.follow-default-target = false
              }
            '')
            (pkgs.writeTextDir "share/wireplumber/wireplumber.conf.d/53-device-priorities.conf" ''
              monitor.bluez.rules = [
                {
                  matches = [
                    {
                      api.bluez5.address = "58:18:62:39:A0:E2"
                    }
                  ]
                  actions = {
                    update-props = {
                      priority.driver = 3000
                      priority.session = 3000
                    }
                  }
                }
              ]

              monitor.alsa.rules = [
                {
                  matches = [
                    {
                      node.name = "alsa_output.pci-0000_18_00.6.analog-stereo"
                    }
                  ]
                  actions = {
                    update-props = {
                      priority.driver = 1000
                      priority.session = 1000
                    }
                  }
                }
              ]
            '')
          ];
        };
      };
    };
}
