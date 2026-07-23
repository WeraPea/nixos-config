{
  flake,
  inputs,
  ...
}:
let
  moduleName = "firefox";
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
      inherit (pkgs.firefox-addons)
        buildFirefoxXpiAddon
        ;
      right-click-borescope = buildFirefoxXpiAddon rec {
        pname = "right_click_borescope";
        version = "0.0.4";
        addonId = "{1772ab92-844c-4a81-9804-89e4fffa5054}";
        url = "https://addons.mozilla.org/firefox/downloads/file/3947059/${pname}-${version}.xpi";
        sha256 = "sha256-iks2o99cg3H5dSE3/94rMPCRvc9axXTglbgI6cXpXwA=";
        meta = with pkgs.lib; {
          homepage = "https://github.com/blackle/Right-Click-Borescope";
          description = "List all images under your cursor, even ones hidden by other elements";
          license = licenses.publicDomain;
          platforms = platforms.all;
        };
      };
      unhook = buildFirefoxXpiAddon rec {
        pname = "youtube_recommended_videos";
        version = "1.6.9";
        addonId = "myallychou@gmail.com";
        url = "https://addons.mozilla.org/firefox/downloads/file/4733035/${pname}-${version}.xpi";
        sha256 = "sha256-Rrv0C3gazjI3cf8ZPF3ieFtBDV2INkH48Hw5Oo+W1pw=";
        meta = with pkgs.lib; {
          homepage = "https://unhook.app/";
          description = "Hide YouTube related videos, comments, video suggestions wall, homepage recommendations, trending tab, and other distractions.";
          license = licenses.unfree;
          platforms = platforms.all;
        };
      };
      jiten-reader = buildFirefoxXpiAddon rec {
        pname = "jiten_reader";
        version = "1.1.1";
        addonId = "reader@jiten.moe";
        url = "https://addons.mozilla.org/firefox/downloads/file/4807200/${pname}-${version}.xpi";
        sha256 = "sha256-U6gYiw1EVJMiT+RkWoCMMHG1ohIrdjsgIFeLsM8SoF0=";
        meta = with pkgs.lib; {
          homepage = "https://jiten.moe";
          description = "Learn Japanese by immersion by parsing texts, getting definitions for words and tracking your knowledge.";
          license = licenses.asl20;
          platforms = platforms.all;
        };
      };

      utils =
        let
          src = pkgs.fetchFromGitHub {
            owner = "MrOtherGuy";
            repo = "fx-autoconfig";
            rev = "d469a80f12e286c0e937d8b93c01dfc2d55dca8f";
            hash = "sha256-czNgt62fofg3hXw7F4wXSv/+ZAsGtO6bg3sUOiUXcu4=";
          };
        in
        (pkgs.runCommand "fx-autoconfig-utils" { } ''
          mkdir -p "$out"
          cp ${src}/profile/chrome/utils/* "$out/"
        '');

      enforce-transparent = builtins.fetchurl {
        url = "https://gist.githubusercontent.com/wrldspawn/9e76f2b4600d2a84a460735d6c037dfa/raw/enforceTransparent.sys.mjs";
        sha256 = "0v50qc8d7klg4y7f135lj06ymywwbgl1qx2f9y9hv7waga65zlkv";
      };

      toggle-toolbar = # js
        ''
          // ==UserScript==
          // @name            Toggle Toolbar
          // @author          werapi
          // @version         1
          // @description
          // @onlyonce
          // ==/UserScript==
          import { Windows } from "chrome://userchromejs/content/uc_api.sys.mjs";

          Windows.onCreated(async (win) => {
            const { parent } = win;
            if (parent.location.href !== "chrome://browser/content/browser.xhtml") return;

            await Windows.waitWindowLoading(parent);

            const doc = parent.document;
            const toolbox = doc.getElementById("navigator-toolbox");

            const menuitem = doc.createXULElement("menuitem");
            menuitem.id = "context-toggle-toolbar";
            menuitem.setAttribute("label", "Toggle Toolbar");
            menuitem.setAttribute("accesskey", "T");

            menuitem.addEventListener("command", () => {
              if (toolbox) {
                const isHidden = toolbox.style.display === "none";
                if (isHidden) {
                  toolbox.style.display = "";
                  toolbox.style.visibility = "";
                } else {
                  toolbox.style.display = "none";
                  toolbox.style.visibility = "collapse";
                }
              }
            });

            const contentAreaContextMenu = doc.getElementById("contentAreaContextMenu");
            if (contentAreaContextMenu) {
              const separator = doc.createXULElement("menuseparator");
              separator.id = "context-toggle-toolbar-separator";
              contentAreaContextMenu.appendChild(separator);
              contentAreaContextMenu.appendChild(menuitem);
            }

            const key = doc.createXULElement("key");
            key.id = "key-toggle-toolbar";
            key.setAttribute("modifiers", "alt");
            key.setAttribute("key", "T");
            key.addEventListener("command", () => {
              menuitem.click();
            });

            const keyset = doc.getElementById("mainKeyset");
            if (keyset) {
              keyset.appendChild(key);
            }
          });
        '';

      transparent-browser-by-url = # js
        ''
          // ==UserScript==
          // @name            Transparent Browser By URL
          // @author          werapi
          // @version         1
          // @description     Make #browser transparent for matching URLs
          // @onlyonce
          // ==/UserScript==
          import { Windows } from "chrome://userchromejs/content/uc_api.sys.mjs";

          Windows.onCreated(async (win) => {
            const { parent } = win;
            if (parent.location.href !== "chrome://browser/content/browser.xhtml") return;

            await Windows.waitWindowLoading(parent);

            const doc = parent.document;
            const browserEl = doc.getElementById("browser");
            const toolboxEl = doc.getElementById("navigator-toolbox");

            const transparentUrls = [
              /^https:\/\/renji-xd\.github\.io\/texthooker-ui/,
            ];

            function shouldBeTransparent(url) {
              if (!url) return false;
              return transparentUrls.some(pattern => pattern.test(url));
            }

            function updateBrowserBackground(url) {
              if (!browserEl || !toolboxEl) return;

              if (shouldBeTransparent(url)) {
                browserEl.setAttribute("transparent-url", "true");
                toolboxEl.setAttribute("transparent-url", "true");
              } else {
                browserEl.removeAttribute("transparent-url");
                toolboxEl.removeAttribute("transparent-url");
              }
            }

            if (parent.gBrowser.selectedBrowser) {
              updateBrowserBackground(parent.gBrowser.selectedBrowser.currentURI?.spec);
            }

            parent.gBrowser.tabContainer.addEventListener("TabSelect", () => {
              const url = parent.gBrowser.selectedBrowser?.currentURI?.spec;
              updateBrowserBackground(url);
            });

            const TransparencyListener = {
              onLocationChange(browser, webProgress, request, uri, flags) {
                // Only update if this is the selected browser and it's the top-level frame
                if (browser === parent.gBrowser.selectedBrowser && webProgress.isTopLevel) {
                  updateBrowserBackground(uri?.spec);
                }
              }
            };
            parent.gBrowser.addTabsProgressListener(TransparencyListener);
          });
        '';

      mkTheme =
        stylix: polarity:
        with stylix.colors.withHashtag;
        lib.strings.toJSON {
          theme = {
            button_background_active = base04;
            accentcolor = base0D;
            accentcolorInactive = base01;
            icon_color = base04;
            icon_attention_color = base0D;
            ntp_background = base00;
            ntp_text = base05;
            popup = base00;
            popup_border = base0C;
            popup_highlight = base04;
            popup_highlight_text = base05;
            popup_text = base05;
            sidebar = base00;
            sidebar_border = base0C;
            sidebar_highlight = base0D;
            sidebar_highlight_text = base05;
            sidebar_text = base05;
            tab_background_separator = base0D;
            textcolor = base05;
            tab_line = base0C;
            tab_loading = base05;
            tab_selected = base00;
            tab_text = base05;
            toolbarColor = base00;
            toolbar_bottom_separator = base00;
            toolbar_field = base0D;
            toolbar_field_border = base00;
            toolbar_field_border_focus = base0C;
            toolbar_field_focus = base00;
            toolbar_field_highlight = base0D;
            toolbar_field_highlight_text = base00;
            toolbar_field_text = base05;
            toolbar_text = base05;
            toolbar_vertical_separator = base0D;
            id = polarity;
            color_scheme = polarity;
          };
        };

      theme-change-by-output = /* js */ ''
        // ==UserScript==
        // @name            theme-change-by-output
        // @onlyonce
        // ==/UserScript==

        import { Windows } from "chrome://userchromejs/content/uc_api.sys.mjs";

        const { Subprocess } = ChromeUtils.importESModule("resource://gre/modules/Subprocess.sys.mjs");
        const { ctypes } = ChromeUtils.importESModule("resource://gre/modules/ctypes.sys.mjs");

        function setWindowTheme(win, themeData) {
          Services.obs.notifyObservers(
            { wrappedJSObject: { ...themeData, window: win.docShell.outerWindowID } },
            "lightweight-theme-styling-update"
          );
        }

        const base_theme = ${mkTheme config.lib.stylix "dark"};
        const light_theme = ${mkTheme flake.nixosConfigurations.pinenote.config.lib.stylix "light"};

        const gdk = ctypes.open("libgdk-3.so.0");
        const gdk_window_get_screen = gdk.declare("gdk_window_get_screen", ctypes.default_abi, ctypes.voidptr_t, ctypes.voidptr_t);
        let gdk_screen_get_monitor_at_window = gdk.declare("gdk_screen_get_monitor_at_window", ctypes.default_abi, ctypes.int, ctypes.voidptr_t, ctypes.voidptr_t);
        let gdk_screen_get_monitor_plug_name = gdk.declare("gdk_screen_get_monitor_plug_name", ctypes.default_abi, ctypes.char.ptr, ctypes.voidptr_t, ctypes.int);

        function applyThemeForWindow(parent) {
          const doc = parent.document;
          const browserEl = doc.getElementById("browser");
          const toolboxEl = doc.getElementById("navigator-toolbox");
          const urlbarEl = doc.getElementById("urlbar");

          if (doc.hasFocus()) {
            const baseWin = parent.docShell.treeOwner
              .QueryInterface(Ci.nsIInterfaceRequestor)
              .getInterface(Ci.nsIBaseWindow);
            const gdk_window_ptr = ctypes.voidptr_t(ctypes.UInt64(baseWin.nativeHandle));
            const screen = gdk_window_get_screen(gdk_window_ptr);
            const monitorNum = gdk_screen_get_monitor_at_window(screen, gdk_window_ptr);
            const namePtr = gdk_screen_get_monitor_plug_name(screen, monitorNum);
            const name = namePtr.isNull() ? null : namePtr.readString();
            if (/^HEADLESS-/.test(name)) {
              browserEl.setAttribute("pinenote", "true");
              toolboxEl.setAttribute("pinenote", "true");
              urlbarEl.setAttribute("pinenote", "true");
              setWindowTheme(parent, light_theme);
              Services.prefs.setIntPref("layout.css.prefers-color-scheme.content-override", 1);
            } else {
              browserEl.removeAttribute("pinenote");
              toolboxEl.removeAttribute("pinenote");
              urlbarEl.removeAttribute("pinenote");
              setWindowTheme(parent, base_theme);
              Services.prefs.setIntPref("layout.css.prefers-color-scheme.content-override", 0);
            }
          }
        };

        const MonitorWatcher = {
          proc: null,
          windows: new Set(),
          failTimes: [],
          starting: null,

          async ensureStarted() {
            if (!this.proc && !this.starting)
              this.starting = this.start().finally(() => { this.starting = null; });
          },

          async start() {
            const proc = await Subprocess.call({
              command: await Subprocess.pathSearch("setpriv"),
              arguments: [
                "--pdeathsig", "TERM", "--",
                await Subprocess.pathSearch("stdbuf"), "-oL",
                await Subprocess.pathSearch("mmsg"), "watch", "all-monitors",
              ],
            });
            this.proc = proc;

            (async () => {
              let buf = "";
              let chunk;
              while ((chunk = await proc.stdout.readString())) {
                buf += chunk;
                let idx;
                while ((idx = buf.indexOf("\n")) >= 0) {
                  buf = buf.slice(idx + 1);
                  for (const win of this.windows) applyThemeForWindow(win);
                }
              }
            })();

            proc.wait().then(({ exitCode }) => {
              console.log("mmsg watch all-monitors exited", exitCode);
              if (this.proc === proc) this.proc = null;

              const now = Date.now();
              this.failTimes.push(now);
              this.failTimes = this.failTimes.filter((t) => now - t < 30000);
              if (this.failTimes.length >= 5) {
                console.error("mmsg watch all-monitors: 5 exits in 30s, not restarting");
                return;
              }
              setTimeout(() => this.ensureStarted(), 500);
            });
          },

          register(win) {
            this.windows.add(win);
            this.ensureStarted();
          },

          unregister(win) {
            this.windows.delete(win);
          },
        };

        Windows.onCreated(async (win) => {
          const { parent } = win;
          if (parent.location.href !== "chrome://browser/content/browser.xhtml") return;

          await Windows.waitWindowLoading(parent);

          applyThemeForWindow(parent);
          const handler = () => applyThemeForWindow(parent);

          parent.addEventListener("focus", handler)
          MonitorWatcher.register(parent);
          parent.addEventListener("unload", () => {
            MonitorWatcher.unregister(parent);
          }, { once: true });
        });
      '';

      nexusmodsDownloadfix = builtins.fetchurl {
        url = "https://github.com/randomtdev/nexusmods_downloadfix/raw/9d94d132a2ab208a08821bffa28ae6ffad1ba38b/nexusmods_downloadfix.user.js";
        sha256 = "1dyi9nkzaqkjzfzr51lwlfzg9589vx73sv52n0r3ank307gc9ml3";
      };
      automail = builtins.fetchurl {
        url = "https://update.greasyfork.org/scripts/370473/1715243/Automail.user.js";
        sha256 = "09j49rx49kcsq2dn55izdapbcxhkjyrzv998hmxcqh9698fv9pag";
      };
      anilistAutoRefresh = builtins.fetchurl {
        name = "anilistAutoRefresh";
        url = "https://update.greasyfork.org/scripts/502647/1422176/Anilist%20Auto%20Refresh%20on%20Session%20Expiry.user.js";
        sha256 = "0wchbzpf6lrwq2wp4mk8in7ccl9jlnhl7hcqfa2ihpqbhxpibkcr";
      };
      ytNotInterestedInOneClick = builtins.fetchurl {
        name = "ytNotInterestedInOneClick";
        url = "https://update.greasyfork.org/scripts/396936/1823095/YT%3A%20not%20interested%20in%20one%20click.user.js";
        sha256 = "18h7qwflgxw6k50gbg7dh8gcvyjix5z3mkffawjhsasicq2mcxsy";
      };

      texthooker-clear =
        pkgs.writeText "texthooker-clear.js" # js
          ''
            // ==UserScript==
            // @name         texthooker-ui clear
            // @match        https://renji-xd.github.io/texthooker-ui/*
            // ==/UserScript==
            (function () {
              window.addEventListener('blur', () => {
                window.getSelection().removeAllRanges();
                document.body.dispatchEvent(new MouseEvent('click', { bubbles: true }));
              });
            })();
          '';

      cfg = config.werapi.${moduleName};
      hmConfig = config.home-manager.users.${config.werapi.username};

      baseFirefoxPackage =
        if cfg.mobile.enable then
          # pkgs.firefox-mobile
          pkgs.firefox
        else
          inputs.glide.packages.${pkgs.stdenv.hostPlatform.system}.glide-browser-bin;

      firefoxPackage = baseFirefoxPackage.override {
        extraPrefsFiles = [
          (builtins.fetchurl {
            url = "https://raw.githubusercontent.com/MrOtherGuy/fx-autoconfig/master/program/config.js";
            sha256 = "1mx679fbc4d9x4bnqajqx5a95y1lfasvf90pbqkh9sm3ch945p40";
          })
        ];
      };

      profileName = "default";
    in
    {
      options.werapi.${moduleName} = {
        enable = lib.mkOption {
          default = config.werapi.graphics.enable;
          description = "Whether to enable ${moduleName}.";
          type = lib.types.bool;
        };
        mobile.enable = lib.mkEnableOption "firefox-mobile package";
        minimal.enable = lib.mkEnableOption "minimal addons";
        theme = {
          dark.enable = lib.mkEnableOption "dark theme" // {
            default = true;
          };
          backgroundColor = lib.mkOption {
            type = lib.types.str;
            default =
              let
                opacityHex = percentage: lib.toHexString (builtins.floor (percentage * 255 + 0.5));
              in
              "${config.lib.stylix.colors.withHashtag.base00}${opacityHex config.stylix.opacity.applications}";
          };
        };
      };
      config = lib.mkIf cfg.enable {
        nixpkgs.overlays = [
          inputs.rycee.overlays.default
        ];
        hm = {
          home.sessionVariables = {
            MOZ_USE_XINPUT2 = "1";
          };
          # xdg.configFile."glide/glide" = lib.mkIf (!cfg.mobile.enable) {
          #   source = hmConfig.lib.file.mkOutOfStoreSymlink "${hmConfig.home.homeDirectory}/.mozilla/firefox";
          # };
          xdg.configFile."glide/glide.ts" = lib.mkIf (!cfg.mobile.enable) {
            source = ./glide/glide.ts;
          };
          home.file.".glide-browser" = lib.mkIf (!cfg.mobile.enable) {
            source = hmConfig.lib.file.mkOutOfStoreSymlink "${hmConfig.home.homeDirectory}/.mozilla";
          };

          home.file = {
            "${hmConfig.programs.firefox.configPath}/${profileName}/chrome/utils".source = utils;
            "${hmConfig.programs.firefox.configPath}/${profileName}/chrome/JS/enforceTransparent.sys.mjs".source =
              enforce-transparent;
            "${hmConfig.programs.firefox.configPath}/${profileName}/chrome/JS/toggleToolbar.sys.mjs".text =
              toggle-toolbar;
            "${hmConfig.programs.firefox.configPath}/${profileName}/chrome/JS/transparentBrowserByUrl.sys.mjs".text =
              transparent-browser-by-url;
            "${hmConfig.programs.firefox.configPath}/${profileName}/chrome/JS/themeChangeByOutput.sys.mjs".text =
              theme-change-by-output;
          };

          stylix.targets.firefox = {
            profileNames = [ profileName ];
            colorTheme.enable = true;
          };

          programs.firefox = {
            enable = true;
            package = firefoxPackage;
            release = lib.mkIf (!cfg.mobile.enable) "153.0b5";
            configPath =
              if cfg.mobile.enable then
                "${hmConfig.xdg.configHome}/mozilla/firefox"
              else
                "${hmConfig.xdg.configHome}/glide/glide";

            languagePacks = [
              "en-US"
              "pl"
            ];

            nativeMessagingHosts = [ pkgs.werapi.yomitan-api ];

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
                "uBlock0@raymondhill.net".private_browsing = true;
                "addon@darkreader.org".private_browsing = true;
                "sponsorBlocker@ajay.app".default_area = "menupanel";
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
                # violentmonkey
                "{aecec67f-0d10-4fa7-b7c7-609a2db280cf}" = {
                  options.autoUpdate = 0;
                  scripts = map (path: builtins.readFile path) [
                    anilistAutoRefresh
                    automail
                    nexusmodsDownloadfix
                    texthooker-clear
                    ytNotInterestedInOneClick
                  ];
                };
                "addon@darkreader.org" = {
                  syncSettings = false;
                  previewNewDesign = true;
                  enableForProtectedPages = true;
                  theme = {
                    mode = 1;
                    brightness = 100;
                    contrast = 100;
                    grayscale = 0;
                    sepia = 0;
                    useFont = false;
                    fontFamily = "";
                    textStroke = 0;
                    engine = "dynamicTheme";
                    stylesheet = "";
                    darkSchemeBackgroundColor = config.lib.stylix.colors.withHashtag.base00;
                    darkSchemeTextColor = config.lib.stylix.colors.withHashtag.base07;
                    lightSchemeBackgroundColor = config.lib.stylix.colors.withHashtag.base00;
                    lightSchemeTextColor = config.lib.stylix.colors.withHashtag.base07;
                    scrollbarColor = "";
                    selectionColor = "auto";
                    styleSystemControls = true; # ???
                    darkColorScheme = "Default";
                    lightColorScheme = "Default";
                    immediateModify = false;
                  };
                  disabledFor = [
                    "anilist.co"
                    "app.tuta.com"
                    "cad.onshape.com"
                    "connect.prusa3d.com"
                    "docs.google.com"
                    "duckduckgo.com"
                    "google.com/maps"
                    "mapy.geoportal.gov.pl"
                    "web.archive.org"
                    "www.desmos.com"
                  ];
                };
              };
            };
            profiles.${profileName} = {
              name = profileName;

              extensions = {
                force = true;
                packages =
                  with pkgs.firefox-addons;
                  let
                    minimalExtensions = [
                      bitwarden
                      clearurls
                      don-t-fuck-with-paste
                      facebook-container
                      floccus
                      image-max-url
                      istilldontcareaboutcookies
                      linkwarden
                      onetab
                      polish-dictionary
                      right-click-borescope
                      ublock-origin
                      wayback-machine
                      web-archives
                      wikipedia-vector-skin
                      yang
                      yomitan
                    ];
                    allExtensions = minimalExtensions ++ [
                      absolute-enable-right-click
                      annotations-restored
                      cliget
                      cookies-txt
                      enhancer-for-youtube
                      gitako-github-file-tree
                      github-file-icons
                      github-isometric-contributions
                      hyperchat
                      indie-wiki-buddy
                      inputs.firefox-extensions-declarative.packages.${pkgs.stdenv.hostPlatform.system}.darkreader-declarative
                      inputs.firefox-extensions-declarative.packages.${pkgs.stdenv.hostPlatform.system}.violentmonkey-declarative
                      jiten-reader
                      multiselect-for-youtube
                      nixpkgs-pr-tracker
                      nyaa-linker
                      redirect-to-wiki-gg
                      refined-github
                      sidebery
                      sponsorblock
                      stylus
                      translate-web-pages
                      unhook
                      videospeed
                      web-scrobbler
                      youtube-no-translation

                      # ff2mpv # TODO:

                      # extatic # TODO:
                    ];
                  in
                  if cfg.minimal.enable then minimalExtensions else allExtensions;

                settings = {
                  "{9a3104a2-02c2-464c-b069-82344e5ed4ec}".settings = {
                    settings = {
                      titleTranslation = true;
                      originalThumbnails.enabled = true;
                      audioTranslation = {
                        enabled = true;
                        language = "original";
                      };
                      descriptionTranslation = true;
                      subtitlesTranslation = {
                        enabled = true;
                        language = "original";
                        asrEnabled = false;
                      };
                      youtubeDataApi = {
                        enabled = false;
                        apiKey = "";
                      };
                      askForSupport.enabled = false;
                    };
                  };
                  "enhancerforyoutube@maximerf.addons.mozilla.org".settings = {
                    controls = [
                      "loop"
                      "reverse-playlist"
                      "cards-end-screens"
                      "cinema-mode"
                      "size"
                      "options"
                    ];
                    controlbar = {
                      active = true;
                      autohide = false;
                      centered = false;
                      position = "absolute";
                    };
                    selectquality = true;
                    qualityvideos = "highres";
                    qualityplaylists = "highres";
                    qualityembeds = "hd1080";
                    controlspeedmousebutton = true;
                    ignoreplaylists = false;
                    pausevideos = false;
                    miniplayersize = "_640x360";
                    hidecardsendscreens = true;
                    blackbars = true;
                    theatermode = true;
                    hideshorts = true;
                    convertshorts = true;
                    hiderelated = true;
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

              userChrome =
                # lib.mkIf (!cfg.mobile.enable)
                # css
                ''
                  @-moz-document url(chrome://browser/content/browser.xul), url(chrome://browser/content/browser.xhtml) {
                    #browser,
                    #main-window,
                    #nav-bar,
                    #PersonalToolbar,
                    #tabbrowser-tabpanels,
                    #tabpanels,
                    #TabsToolbar,
                    .urlbar-background,
                    .tabbrowser-arrowscrollbox {
                      background: transparent !important;
                      background-color: transparent !important;
                    }

                    #nav-bar {
                      border-top: 0 !important;
                      border-bottom: 0 !important;
                    }
                    #navigator-toolbox {
                      border-bottom: 0 !important;
                    }
                    #tabbrowser-tabs {
                      border-inline: 0 !important;
                    }

                    #urlbar:not([breakout-extend]) .urlbar-background {
                      border: none !important;
                    }
                    #urlbar[breakout-extend] .urlbar-background {
                      background-color: ${cfg.theme.backgroundColor} !important;
                    }
                    #urlbar[breakout-extend][pinenote] .urlbar-background {
                      background-color: ${flake.nixosConfigurations.pinenote.config.werapi.firefox.theme.backgroundColor} !important;
                    }

                    #browser, #navigator-toolbox {
                      background-color: ${cfg.theme.backgroundColor} !important;
                    }
                    #browser[pinenote], #navigator-toolbox[pinenote] {
                      background-color: ${flake.nixosConfigurations.pinenote.config.werapi.firefox.theme.backgroundColor} !important;
                    }
                    #browser[transparent-url], #navigator-toolbox[transparent-url] {
                      background-color: #0000 !important;
                    }

                    :root {
                      background: transparent;
                    }

                    * {
                      --toolbox-bgcolor: #0000 !important;
                      --toolbox-bgcolor-inactive: #0000 !important;
                      --tab-selected-bgcolor: #0000 !important;
                      --browser-page-background: #0000 !important;
                      --content-view-background: #0000 !important;
                      --tabpanel-background-color: #0000 !important;

                      --in-content-page-background: #0000 !important;
                      --in-content-box-background: #0000 !important;
                      --chrome-content-separator-color: transparent !important; /* removes border under navigation toolbox */
                      /*--toolbarbutton-border-radius: 0 !important;*/
                      /*--arrowpanel-border-radius: 0 !important;*/
                      /*--urlbar-border-radius: 0 !important;*/
                      --border-radius-medium: 0 !important;
                      --border-radius-small: 0 !important;
                      --panel-border-radius: 0 !important;
                      --focus-outline-width: 0 !important;
                      --lwt-accent-color-inactive: #0000 !important;
                      --lwt-accent-color: #0000 !important;
                    }
                  }
                '';
              userContent =
                # lib.mkIf (!cfg.mobile.enable)
                # css
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
                      background-color: ${cfg.theme.backgroundColor} !important;
                    }
                  }
                  @-moz-document regexp("https://renji-xd.github.io/texthooker-ui/") {
                    :root, body, .bg-base-100 {
                      background-color: #0000 !important;
                    }
                    * {
                      text-shadow:
                        0 0 2px rgba(0, 0, 0, 0.9),
                        0 0 4px rgba(0, 0, 0, 0.9),
                        0 0 6px rgba(0, 0, 0, 0.9),
                        1px 1px 2px rgba(0, 0, 0, 1) !important;
                    }
                  }
                '';

              settings = {
                "browser.aboutConfig.showWarning" = false;
                "browser.download.useDownloadDir" = false;
                "browser.gesture.swipe.left" = ""; # to not go back in history by mistake when using a touchpad
                "browser.gesture.swipe.right" = "";
                "browser.search.separatePrivateDefault" = false;
                "browser.startup.homepage" = "https://duckduckgo.com/";
                "browser.startup.page" = 3; # previous-session
                "browser.tabs.allow_transparent_browser" = true;
                "browser.tabs.unloadOnLowMemory" = true;
                "browser.toolbars.bookmarks.visibility" = "always";
                "browser.uidensity" = if cfg.mobile.enable then 2 else 1;
                "extensions.autoDisableScopes" = 0; # extensions
                "extensions.update.autoUpdateDefault" = false;
                "extensions.update.enabled" = false;
                "findbar.highlightAll" = true;
                "general.smoothScroll.msdPhysics.continuousMotionMaxDeltaMS" = 3;
                "general.smoothScroll.msdPhysics.enabled" = true;
                "general.smoothScroll.msdPhysics.motionBeginSpringConstant" = 300;
                "layout.css.prefers-color-scheme.content-override" = if cfg.theme.dark.enable then 0 else 1;
                "media.videocontrols.picture-in-picture.video-toggle.enabled" = false;
                "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
                "xpinstall.signatures.required" = false;
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
                    PersonalToolbar = [ "personal-bookmarks" ];
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
      };
    };
}
