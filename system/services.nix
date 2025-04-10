{
  pkgs,
  lib,
  config,
  ...
}:
{
  imports = [
    ./dual-function-keys.nix
    ./polkit.nix
    ./sql.nix
    ./vr.nix
  ];

  services = {
    fstrim.enable = true;
    greetd = lib.mkIf config.graphics.enable {
      enable = true;
      settings = rec {
        initial_session = {
          command = "Hyprland";
          user = config.user.username;
        };
        default_session = initial_session;
      };
    };
    openssh.enable = true;
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
    };
    udev.packages = with pkgs; [
      android-udev-rules
      platformio-core.udev
      (writeTextDir "lib/udev/rules.d/70-stm32-dfu.rules" ''
        # DFU (Internal bootloader for STM32 and AT32 MCUs)
        SUBSYSTEM=="usb", ATTRS{idVendor}=="2e3c", ATTRS{idProduct}=="df11", TAG+="uaccess"
        SUBSYSTEM=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="df11", TAG+="uaccess"
      '')
      (writeTextDir "lib/udev/rules.d/70-pinenote.rules" ''
        # For use with OpenTabletDriver to mitigate double cursor
        SUBSYSTEM=="input", ATTRS{idVendor}=="1d6b", ATTRS{idProduct}=="0104", ENV{LIBINPUT_IGNORE_DEVICE}="1"
      '')
    ];
    upower.enable = true;
    vnstat.enable = true;
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
  xdg.portal = lib.mkIf config.graphics.enable {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-hyprland
      # pkgs.xdg-desktop-portal-kde
    ];
    configPackages = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-hyprland
      # pkgs.xdg-desktop-portal-kde
    ];
  };
  hardware = lib.mkIf config.graphics.enable {
    bluetooth.enable = true;
    keyboard.qmk.enable = true;
    xpadneo.enable = true;
    opentabletdriver.enable = true;
  };
}
