{
  pkgs,
  lib,
  config,
  ...
}:
{
  imports = [
    ./dual-function-keys.nix
    ./vr.nix
  ];

  services = {
    fstrim.enable = true;
    openssh.enable = true;
    upower.enable = true;
    vnstat.enable = true;
    avahi = {
      enable = true;
      nssmdns4 = true;
      publish = {
        enable = true;
        addresses = true;
      };
    };
    resolved = {
      enable = true;
      settings.Resolve = {
        DNS = [ "9.9.9.9#dns.quad9.net" ];
        DNSOverTLS = true;
        LLMNR = true;
        MulticastDNS = false;
      };
    };
    pipewire = lib.mkIf config.graphics.enable {
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
    udev.packages = with pkgs; [
      platformio-core.udev
      (writeTextDir "lib/udev/rules.d/70-stm32-dfu.rules" ''
        # DFU (Internal bootloader for STM32 and AT32 MCUs)
        SUBSYSTEM=="usb", ATTRS{idVendor}=="2e3c", ATTRS{idProduct}=="df11", TAG+="uaccess"
        SUBSYSTEM=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="df11", TAG+="uaccess"
      '')
    ];
    protonvpn = {
      enable = true;
      autostart = false;
      interface.privateKeyFile = "/etc/protonvpn";
      endpoint = {
        publicKey = "agoivyLoPqor8MxA/s6UWJSMcA2pMl+ajO3vy/q3oWQ=";
        ip = "103.125.235.18";
        port = 51820;
      };
    };
  };
}
