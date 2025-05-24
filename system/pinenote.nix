{
  lib,
  pkgs,
  config,
  ...
}:
{
  user.hostname = "pinenote";
  pinenote.config.enable = true;
  pinenote.sway-dbus-integration.enable = true;
  hardware.graphics.enable32Bit = lib.mkForce false; # shouldnt be needed?
  hardware.opentabletdriver.enable = lib.mkForce false;
  system.stateVersion = "25.05";
  fileSystems."/" = {
    label = "nixos";
    fsType = "ext4";
  };
  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
  services.logind.extraConfig = ''
    HandlePowerKey=suspend
    HandlePowerKeyLongPress=poweroff
  '';

  services.journald.storage = "volatile";
  # zramSwap.enable = true;
  stylix = lib.mkForce {
    # base16Scheme = "${pkgs.base16-schemes}/share/themes/grayscale-light.yaml";
    base16Scheme = {
      scheme = "eink-light";
      base00 = "#ffffff";
      base01 = "#e3e3e3";
      base02 = "#b9b9b9";
      base03 = "#ababab";
      base04 = "#525252";
      base05 = "#464646";
      base06 = "#252525";
      base07 = "#000000";
      base08 = "#7c7c7c";
      base09 = "#999999";
      base0A = "#a0a0a0";
      base0B = "#8e8e8e";
      base0C = "#868686";
      base0D = "#686868";
      base0E = "#747474";
      base0F = "#5e5e5e";
    };
  };

  services.greetd = {
    enable = true;
    settings = rec {
      sway_session = lib.mkForce {
        command = lib.getExe (
          pkgs.writeShellScriptBin "sway-run" ''
            # from https://man.sr.ht/~kennylevinsen/greetd/#how-to-set-xdg_session_typewayland
            # Session
            export XDG_SESSION_TYPE=wayland
            export XDG_SESSION_DESKTOP=sway
            export XDG_CURRENT_DESKTOP=sway

            # Wayland stuff
            export MOZ_ENABLE_WAYLAND=1
            export QT_QPA_PLATFORM=wayland
            export SDL_VIDEODRIVER=wayland
            export _JAVA_AWT_WM_NONREPARENTING=1

            # exec sway "$@"
            exec systemd-cat --identifier=sway sway "$@"
          ''
        );
        user = config.user.username;
      };
      default_session = sway_session;
    };
  };
}
