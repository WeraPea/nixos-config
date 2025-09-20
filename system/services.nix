{
  pkgs,
  lib,
  config,
  ...
}:
{
  imports = [
    ./dual-function-keys.nix
    ./sql.nix
    ./vr.nix
    ./roc.nix # TODO: move all of pipewire to a module
  ];

  services = {
    fstrim.enable = true;
    openssh.enable = true;
    upower.enable = true;
    vnstat.enable = true;
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
                        audio.position = [FL FR]
                    }
                    playback.props = {
                        audio.position = [ FR FL ]
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
      ];
    };
    udev.packages = with pkgs; [
      android-udev-rules
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
