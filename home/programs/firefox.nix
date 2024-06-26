{ pkgs, lib, ... }:
{
  home.sessionVariables = {
    MOZ_USE_XINPUT2 = "1";
  };
  programs.firefox = {
    enable = true;
    package =
      (pkgs.wrapFirefox (pkgs.firefox-unwrapped.override { pipewireSupport = true; }) { }).override
        {
          extraPrefsFiles = [
            (builtins.fetchurl {
              url = "https://raw.githubusercontent.com/MrOtherGuy/fx-autoconfig/master/program/config.js";
              sha256 = "1mx679fbc4d9x4bnqajqx5a95y1lfasvf90pbqkh9sm3ch945p40";
            })
          ];
        };
    nativeMessagingHosts = [ pkgs.plasma5Packages.plasma-browser-integration ];
  };
}
