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
