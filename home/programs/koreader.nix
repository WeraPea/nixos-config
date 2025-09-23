{
  osConfig,
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
{
  options = {
    koreader.enable = lib.mkEnableOption "enables koreader";
  };
  config = lib.mkIf config.koreader.enable {
    home.packages = [ pkgs.koreader ];
    xdg.configFile."koreader/plugins/rakuyomi.koplugin".source =
      let
        variant =
          {
            "x86_64-linux" = "desktop";
            "aarch64-linux" = "aarch64";
          }
          .${pkgs.system} or (throw "Unsupported system: ${pkgs.system}");
      in
      inputs.rakuyomi.packages.${osConfig.buildSystem}.rakuyomi.${variant};
    xdg.configFile."koreader/rakuyomi/settings.json".text = # json
      ''
        {
          "$schema": "https://github.com/hanatsumi/rakuyomi/releases/download/main/settings.schema.json",
          "source_lists": [
            "https://raw.githubusercontent.com/Skittyblock/aidoku-community-sources/refs/heads/gh-pages/index.min.json"
          ],
          "source_settings": {
            "en.mangakatana": {
              "imageServer": "3"
            }
          },
          "languages": ["en"]
        }
      '';
    xdg.configFile."koreader/patches/2-pinenote.lua".text = # lua
      ''
        local Device = require("device")
        local function yes() return true end
        local function no() return false end
        Device.hasEinkScreen = yes
        Device.hasKeyboard = no

        refreshOrig = Device.screen.refreshFullImp
        Device.screen.refreshPartialImp = refreshOrig
        Device.screen.refreshFullImp = function(self, x, y, w, h)
          refreshOrig(self,x,y,w,h)
          os.execute("sh -c \"sleep 0.1; dbus-send --type=method_call --dest=org.pinenote.PineNoteCtl /org/pinenote/PineNoteCtl org.pinenote.Ebc1.GlobalRefresh\" &") -- TODO: currently it refreshes normaly once, and then does the full refresh, would be nice to remove the normal refresh
        end
      '';
  };
}
