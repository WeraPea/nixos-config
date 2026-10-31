let
  moduleName = "graphics";
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
          default = config.werapi.defaultModules.enable;
          description = "Whether to enable ${moduleName}.";
          type = lib.types.bool;
        };
      };
      config = lib.mkIf cfg.enable {
        users.users.${config.werapi.username}.extraGroups = [
          "video"
        ];

        environment.systemPackages = [
          pkgs.kdePackages.breeze-icons
        ];

        fonts = {
          packages = with pkgs; [
            noto-fonts
            noto-fonts-cjk-sans
            noto-fonts-cjk-serif
            noto-fonts-color-emoji
          ];
          fontconfig.localConf = ''
            <?xml version="1.0"?>
            <!DOCTYPE fontconfig SYSTEM "fonts.dtd">
            <fontconfig>
              <alias>
                <family>sans-serif</family>
                <prefer>
                  <family>Noto Sans CJK JP</family>
                </prefer>
              </alias>
              <alias>
                <family>serif</family>
                <prefer>
                  <family>Noto Serif CJK JP</family>
                </prefer>
              </alias>
              <alias>
                <family>monospace</family>
                <prefer>
                  <family>Noto Sans Mono CJK JP</family>
                </prefer>
              </alias>
            </fontconfig>
          '';
        };

        programs.dconf.enable = true;
        security.polkit = {
          enable = true;
          extraConfig = /* js */ ''
            polkit.addRule(function (action, subject) {
              if (
                subject.isInGroup("wheel") &&
                [
                  "org.freedesktop.login1.suspend",
                  "org.freedesktop.login1.suspend-multiple-sessions",
                  "org.freedesktop.login1.suspend-ignore-inhibit",
                ].indexOf(action.id) !== -1
              ) {
                return polkit.Result.YES;
              }
            });
          '';
        };
        security.rtkit.enable = true;
      };
    };
}
