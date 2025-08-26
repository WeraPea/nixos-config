{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}:
{

  options = {
    firefox.enable = lib.mkEnableOption "Enables firefox";
  };
  config = lib.mkIf config.firefox.enable {
    home.sessionVariables = {
      MOZ_USE_XINPUT2 = "1";
    };
    stylix.targets.firefox.enable = false;
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
      languagePacks = [
        "en-US"
        "pl"
      ];
      # profiles.default = {
      #   name = "Default-Managed";
      #   extensions = with osConfig.nur.repos.rycee.firefox-addons; [
      #     add-custom-search-engine
      #     annotations-restored
      #     # bypass-paywalls-clean # outdated/broken, update flake inputs
      #     cookies-txt
      #     darkreader
      #     enhanced-github
      #     enhancer-for-youtube
      #     flagfox
      #     istilldontcareaboutcookies
      #     nyaa-linker
      #     onetab
      #     plasma-integration
      #     sponsorblock
      #     translate-web-pages
      #     ublock-origin
      #     vimium
      #     violentmonkey
      #     web-scrobbler
      #     noscript
      #     wayback-machine
      #     web-archives
      #     floccus
      #     forget_me_not
      #     github-file-icons
      #     google-container
      #   ];
      #   settings = {
      #     "browser.download.useDownloadDir" = false;
      #     "browser.gesture.swipe.left" = ""; # to not go back in history by mistake when using a touchpad
      #     "browser.gesture.swipe.right" = "";
      #     "browser.startup.homepage" = "https://duckduckgo.com/";
      #     "browser.tabs.unloadOnLowMemory" = true;
      #     "ui.key.menuAccessKey" = 0; # for alt+<X> to work
      #     "extensions.autoDisableScopes" = 0;
      #   };
      # };
    };
  };
}
