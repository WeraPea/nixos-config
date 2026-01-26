{
  pkgs,
  lib,
  config,
  ...
}:
{
  options = {
    firefox.enable = lib.mkEnableOption "Enables firefox";
  };
  config = lib.mkIf config.firefox.enable {
    xdg.configFile."glide/glide".source =
      config.lib.file.mkOutOfStoreSymlink config.home.homeDirectory + "/.mozilla/firefox";
    xdg.configFile."glide/glide.ts".source = ./glide/glide.ts;
    home.sessionVariables = {
      MOZ_USE_XINPUT2 = "1";
    };
    # stylix.targets.firefox.enable = false;
    stylix.targets.firefox.profileNames = [ "glide" ];
    stylix.targets.firefox.colorTheme.enable = true;
    home.file."${config.programs.firefox.configPath}/glide/chrome/utils".source =
      let
        src = pkgs.fetchFromGitHub {
          owner = "MrOtherGuy";
          repo = "fx-autoconfig";
          rev = "d76528e93d0c61bef9ca9a4af1e58e545e9099c1";
          hash = "sha256-W0MO8waK+1ZKg94uvuE42RJxxvI9dWabkMzziP8U2i0=";
        };
      in
      (pkgs.runCommand "fx-autoconfig-utils" { } ''
        mkdir -p "$out"
        cp ${src}/profile/chrome/utils/* "$out/"
      '');
    home.file."${config.programs.firefox.configPath}/glide/chrome/JS/enforceTransparent.sys.mjs".source =
      builtins.fetchurl {
        url = "https://gist.githubusercontent.com/wrldspawn/9e76f2b4600d2a84a460735d6c037dfa/raw/enforceTransparent.sys.mjs";
        sha256 = "0v50qc8d7klg4y7f135lj06ymywwbgl1qx2f9y9hv7waga65zlkv";
      };

    programs.firefox = {
      enable = true;
      # package = pkgs.glide-browser;
      package = pkgs.glide-browser.override {
        extraPrefsFiles = [
          (builtins.fetchurl {
            url = "https://raw.githubusercontent.com/MrOtherGuy/fx-autoconfig/master/program/config.js";
            sha256 = "1mx679fbc4d9x4bnqajqx5a95y1lfasvf90pbqkh9sm3ch945p40";
          })
        ];
      };
      # configPath = "${config.xdg.configHome}/glide/glide";
      release = "148.0b4";
      languagePacks = [
        "en-US"
        "pl"
      ];
      policies = {
        # https://mozilla.github.io/policy-templates/
        Handlers = {
          mimeTypes = {
            "application/pdf" = {
              action = "useHelperApp";
              ask = false;
              handlers = [
                {
                  name = "zathura";
                  path = "${pkgs.zathura}/bin/zathura";
                }
              ];
              extensions = [ "pdf" ];
            };
          };
          schemes = {
            magnet.action = "useHelperApp";
          };
        };
        DisableFirefoxAccounts = true;
        DisableFirefoxStudies = true;
        DisablePocket = true;
        DisableSetDesktopBackground = true;
        DisableTelemetry = true;
        EnableTrackingProtection.Cryptomining = true;
        EnableTrackingProtection.Fingerprinting = true;
        EnableTrackingProtection.Locked = true;
        EnableTrackingProtection.Value = true;
        EncryptedMediaExtensions.Enabled = false;
        EncryptedMediaExtensions.Locked = true;
        FirefoxHome.Pocket = false;
        FirefoxHome.Snippets = false;
        GenerativeAI.Enabled = false;
        UserMessaging.ExtensionRecommendations = false;
        UserMessaging.SkipOnboarding = false;
        PasswordManagerEnabled = false;

        ExtensionSettings = {
          "uBlock0@raymondhill.net" = {
            private_browsing = true;
          };
          "addon@darkreader.org" = {
            private_browsing = true;
          };
          "sponsorBlocker@ajay.app" = {
            default_area = "menupanel";
          };
        };
        "3rdparty".Extensions = {
          # See:
          # https://github.com/gorhill/uBlock/wiki/Deploying-uBlock-Origin:-configuration
          # https://raw.githubusercontent.com/gorhill/uBlock/refs/heads/master/platform/common/managed_storage.json
          "uBlock0@raymondhill.net" = {
            # Obtain the default lists with:
            # curl -sSfL https://raw.githubusercontent.com/gorhill/uBlock/refs/heads/master/assets/assets.json \
            #   | jq -r 'to_entries[] | select(.value | .content == "filters" and (.off | not)) | .key'
            toOverwrite.filterLists = lib.mkDefault [
              # default
              "user-filters"
              "ublock-filters"
              "ublock-badware"
              "ublock-privacy"
              "ublock-unbreak"
              "ublock-quick-fixes"
              "easylist"
              "easyprivacy"
              "urlhaus-1"
              "plowe-0"
              # added
              "JPN-1"
              "block-lan"
              "fanboy-cookiemonster"
              "fanboy-social"
              "ublock-annoyances"
              "easylist-annoyances"
              "easylist-chat"
              "easylist-newsletters"
              "easylist-notifications"
              "ublock-cookies-easylist"
            ];
          };
        };
      };
      profiles.glide = {
        name = "glide";
        extensions = {
          force = true;
          packages = with pkgs.nur.repos.rycee.firefox-addons; [
            absolute-enable-right-click
            annotations-restored
            bitwarden
            clearurls
            cliget
            cookies-txt
            darkreader
            don-t-fuck-with-paste
            enhanced-github
            enhancer-for-youtube
            facebook-container
            floccus
            gitako-github-file-tree
            github-file-icons
            github-isometric-contributions
            hyperchat
            image-max-url
            image-search-options
            indie-wiki-buddy
            istilldontcareaboutcookies
            linkwarden
            lovely-forks
            multiselect-for-youtube
            new-window-without-toolbar
            nixpkgs-pr-tracker
            nyaa-linker
            onetab
            polish-dictionary
            redirect-to-wiki-gg
            refined-github
            return-youtube-dislikes
            sidebery
            sponsorblock
            stylus
            translate-web-pages
            ublock-origin
            videospeed
            violentmonkey
            wayback-machine
            web-archives
            web-scrobbler
            widegithub
            wikipedia-vector-skin
            yang
            yomitan
            youtube-no-translation

            # ff2mpv # TODO:

            # extatic # TODO:
          ];
          settings = {
            # "addon@darkreader.org".settings.theme = with config.lib.stylix.colors.withHashtag; {
            #   fontFamily = config.stylix.fonts.sansSerif.name;
            #   lightSchemeBackgroundColor = base00;
            #   darkSchemeBackgroundColor = base00;
            #   lightSchemeTextColor = base05;
            #   darkSchemeTextColor = base05;
            #   selectionColor = base0D;
            #   syncSettings = false;
            #   # "previewNewDesign": true,
            #   # "previewNewestDesign": false,
            #   # "enableForPDF": true,
            #   # "enableForProtectedPages": false,
            #   # "enableContextMenus": false,
            #   # "detectDarkTheme": true
            # };
            "{9a3104a2-02c2-464c-b069-82344e5ed4ec}".settings = {
              "settings" = {
                "titleTranslation" = true;
                "originalThumbnails" = {
                  "enabled" = true;
                };
                "audioTranslation" = {
                  "enabled" = true;
                  "language" = "original";
                };
                "descriptionTranslation" = true;
                "subtitlesTranslation" = {
                  "enabled" = true;
                  "language" = "original";
                  "asrEnabled" = false;
                };
                "youtubeDataApi" = {
                  "enabled" = false;
                  "apiKey" = "";
                };
                "askForSupport" = {
                  "enabled" = false;
                };
              };
            };
            "enhancerforyoutube@maximerf.addons.mozilla.org".settings = {
              "controls" = [
                "loop"
                "reverse-playlist"
                "cards-end-screens"
                "cinema-mode"
                "size"
                "options"
              ];
              "controlbar" = {
                "active" = true;
                "autohide" = false;
                "centered" = false;
                "position" = "absolute";
              };
              "selectquality" = true;
              "qualityvideos" = "highres";
              "qualityplaylists" = "highres";
              "qualityembeds" = "hd1080";
              "controlspeedmousebutton" = true;
              "ignoreplaylists" = false;
              "pausevideos" = false;
              "miniplayersize" = "_640x360";
              "hidecardsendscreens" = true;
              "blackbars" = true;
              "theatermode" = true;
              "hideshorts" = true;
              "convertshorts" = true;
              "hiderelated" = true;
            };
          };
        };
        search = {
          force = true;
          default = "ddg";
          engines = {
            bing.metaData.hidden = true;
            perplexity.metaData.hidden = true;
            ebay.metaData.hidden = true; # still showing up for some reason
            noogle = {
              name = "Noogle";
              urls = [ { template = "https://noogle.dev?term={searchTerms}"; } ];
              iconMapObj."32" = "https://noogle.dev/favicon.ico";
              definedAliases = [ "@nog" ];
            };
            hmopts = {
              name = "Home Manager Options";
              urls = [
                { template = "https://home-manager-options.extranix.com?release=master&query={searchTerms}"; }
              ];
              icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
              definedAliases = [ "@hm" ];
            };
            nix-options = {
              name = "Nix Options";
              urls = [ { template = "https://search.nixos.org/options?channel=unstable&query={searchTerms}"; } ];
              icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
              definedAliases = [ "@no" ];
            };
            nix-packages = {
              name = "Nix Packages";
              urls = [ { template = "https://search.nixos.org/packages?channel=unstable&query={searchTerms}"; } ];
              icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
              definedAliases = [ "@np" ];
            };
            nixos-wiki = {
              name = "NixOS Wiki";
              urls = [ { template = "https://wiki.nixos.org/w/index.php?search={searchTerms}"; } ];
              iconMapObj."16" = "https://wiki.nixos.org/favicon.ico";
              definedAliases = [ "@nw" ];
            };
            nixpkgs = {
              name = "Nixpkgs";
              urls = lib.singleton {
                template = "https://github.com/search";
                params = lib.attrsToList {
                  "type" = "code";
                  "q" = "repo:NixOS/nixpkgs lang:nix {searchTerms}";
                };
              };
              icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
              definedAliases = [ "@npkgs" ];
            };
            github-nix = {
              name = "Github Nix Code";
              urls = lib.singleton {
                template = "https://github.com/search";
                params = lib.attrsToList {
                  "type" = "code";
                  "q" = "lang:nix NOT is:fork {searchTerms}";
                };
              };
              iconMapObj."32" = "https://github.com/favicon.ico";
              definedAliases = [ "@gn" ];
            };
            gh = {
              name = "Github";
              urls = [ { template = "https://github.com/search?q={searchTerms}"; } ];
              iconMapObj."32" = "https://github.githubassets.com/favicons/favicon-dark.png";
              definedAliases = [ "@gh" ];
            };
            youtube = {
              name = "Youtube";
              urls = [ { template = "https://www.youtube.com/results?search_query={searchTerms}"; } ];
              iconMapObj."32" = "https://www.youtube.com/favicon.ico";
              definedAliases = [ "@y" ];
            };
            wikipedia = {
              definedAliases = [ "@wk" ];
            };
          };
        };
        # TODO: make the below be customizable from nix options
        userChrome = # css
          ''
            @-moz-document url(chrome://browser/content/browser.xul), url(chrome://browser/content/browser.xhtml) {
              #navigator-toolbox {
                background-color: #12121290 !important;
                border-bottom: 0px !important;
              }

              #main-window {
                background: transparent !important;
              }

              .tabbrowser-arrowscrollbox,
              #TabsToolbar {
                background-color: #0000 !important;
              }

              #PersonalToolbar {
                background-color: #0000 !important;
              }

              #nav-bar {
                background-color: #0000 !important;
                border-top: 0px !important;
                border-bottom: 0px !important;
              }

              #urlbar:not([breakout-extend]) .urlbar-background {
                background-color: #0000 !important;
                border: none !important;
              }
              #urlbar[breakout-extend] {
                background-color: #121212d0 !important;
              }

              .urlbar-background {
                background-color: #0000 !important;
              }

              #tabbrowser-tabs {
                border-inline: 0px !important;
              }

              #main-window,
              #tabbrowser-tabpanels {
                background: transparent !important;
                background-color: transparent !important;
              }

              :root {
                --tab-selected-bgcolor: #0000 !important;
                --browser-page-background: #0000 !important;
                --content-view-background: #0000 !important;
                --tabpanel-background-color: #0000 !important;
                background: transparent;

                --in-content-page-background: #0000 !important;
                --in-content-box-background: #0000 !important;
                --chrome-content-separator-color: transparent !important; /* removes border under navigation toolbox */
                --toolbarbutton-border-radius: 0 !important;
                --arrowpanel-border-radius: 0 !important;
              }

              #tabpanels {
                background: transparent !important;
                background-color: transparent !important;
              }

              #browser {
                background: transparent !important;
                background-color: transparent !important;
              }

              #browser:not(.browser-toolbox-background) {
                background-color: var(--toolbar-bgcolor);
              }

              #main-window {
                background-color: #0000 !important;
              }

              #browser {
                background-color: #12121290 !important;
              }
            }
          '';
        userContent = # css
          ''
            :root {
              --in-content-page-background: #0000 !important;
              --in-content-box-background: #0000 !important;
              --newtab-background-color: #0000 !important;
            }
            @-moz-document regexp("https://duckduckgo\\.com/.*") {
              html, body, .body--home, .site-wrapper, .region__body, .badge-link, .module--carousel__image-wrapper, .result__image, .vertical--map__sidebar, .vertical--map__sidebar__header, .page-chrome_newtab, .zci--type--tiles:not(.is-fallback).is-full-page.is-expanded, .zci--type--tiles:not(.is-fallback).is-full-page.is-expanded .metabar:not(.is-stuck), .header-wrap {
                --theme-bg-home-custom: #0000 !important;
                background: #0000 !important;
              }
            }

            @-moz-document regexp("https://anilist\\.co/.*") {
              :root, html, body, .site-theme-dark, .site-theme-dark .nav-unscoped, .footer, .banner {
                --color-background-100: #0000 !important;
                --color-background-200: #0000 !important;
                --color-background: #0000 !important;
                --color-foreground: #0000 !important;
                background-color: #0000 !important;
              }
              .media-card, .hover-data {
                box-shadow: none !important;
              }
              .list-preview .media-preview-card .content,
              .hover-data {
                background-color: #121212f0 !important;
              }
            }
          '';

        settings = {
          "browser.download.useDownloadDir" = false;
          "browser.gesture.swipe.left" = ""; # to not go back in history by mistake when using a touchpad
          "browser.gesture.swipe.right" = "";
          "browser.search.separatePrivateDefault" = false;
          "browser.startup.homepage" = "https://duckduckgo.com/";
          "browser.startup.page" = 3; # previous-session
          "browser.tabs.unloadOnLowMemory" = true;
          "browser.toolbars.bookmarks.visibility" = "always";
          "browser.uidensity" = 1;
          "extensions.autoDisableScopes" = 0; # extensions
          "findbar.highlightAll" = true;
          "general.smoothScroll.msdPhysics.continuousMotionMaxDeltaMS" = 3;
          "general.smoothScroll.msdPhysics.enabled" = true;
          "general.smoothScroll.msdPhysics.motionBeginSpringConstant" = 300;
          "layout.css.prefers-color-scheme.content-override" = 0; # dark
          "media.videocontrols.picture-in-picture.video-toggle.enabled" = false;
          "browser.tabs.allow_transparent_browser" = true;
          "browser.uiCustomization.state" = builtins.toJSON {
            placements = {
              widget-overflow-fixed-list = [ ];
              unified-extensions-area = [
                # sort and prioritize these over other extensions:
                "extension_one-tab_com-browser-action"
                "wayback_machine_mozilla_org-browser-action"
                "_6b733b82-9261-47ee-a595-2dda294a4d08_-browser-action" # yomitan
                "_aecec67f-0d10-4fa7-b7c7-609a2db280cf_-browser-action" # violentmonkey
                "floccus_handmadeideas_org-browser-action"
              ];
              nav-bar = [
                "sidebar-button"
                "back-button"
                "forward-button"
                "stop-reload-button"
                "glide-toolbar-mode-button"
                "vertical-spacer"
                "glide-toolbar-keyseq-button"
                "urlbar-container"
                "downloads-button"
                "reset-pbm-toolbar-button"
                "unified-extensions-button"
                "ublock0_raymondhill_net-browser-action"
                "addon_darkreader_org-browser-action"
                "_446900e4-71c2-419f-a6a7-df9c091e268b_-browser-action" # bitwarden
                "_799c0914-748b-41df-a25c-22d008f9e83f_-browser-action" # web-scrobbler
                "_3c078156-979c-498b-8990-85f7987dd929_-browser-action" # sidebery
              ];
              toolbar-menubar = [ "menubar-items" ];
              TabsToolbar = [
                # "firefox-view-button"
                "tabbrowser-tabs"
                "new-tab-button"
                "privateTab-button"
                "alltabs-button"
              ];
              vertical-tabs = [ ];
              PersonalToolbar = [
                "personal-bookmarks"
              ];
            };
            "currentVersion" = 23;
          };
          # "browser.display.background_color" = "#121212";
          # "browser.display.foreground_color" = "#a2a2a2";
          # "browser.display.document_color_use" = 0; # 2 for the above, 1 default
          # "ui.key.menuAccessKey" = 0;
          # browser.ml.linkPreview.enabled
          # browser.tabs.groups.smart.userEnabled
          # browser.tabs.insertAfterCurrent true
          # datareporting.usage.uploadEnabled
          # browser.urlbar.placeholderName?
          # devtools.chrome.enabled
          # devtools.debugger.remote-enabled
          # devtools.editor.keymap vim
          # editor.background_color #121212
          # font.name.serif.x-western
          # gfx.canvas.accelerated.force-enabled
          # gfx.webrender.all
          # gfx.webrender.compositor
          # privacy.fingerprintingProtection
          # reader.custom_colors.background #121212
          # reader.custom_colors.foreground #e0e0e0
          # userChromeJS.enabled
          # media.ffmpeg.vaapi.enabled
        };
      };
    };
  };
}
