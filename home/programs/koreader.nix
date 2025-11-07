{
  osConfig,
  config,
  inputs,
  outputs,
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
    xdg.configFile."koreader/plugins/anki.koplugin".source = (
      outputs.packages.${pkgs.system}.anki-koplugin.override {
        profiles = {
          default = (
            pkgs.writeText "default.lua" # lua
              ''
                -- This file contains all the user configurable options
                -- Entries which aren't marked as REQUIRED can be ommitted completely
                local Config = {
                    deckName = "Mining",
                    modelName = "Lapis",
                    -- Each note created by the plugin will have the tag 'KOReader', it is possible to add other custom tags
                    -- custom_tags = { "NEEDS_WORK" },

                    -- It is possible to toggle whether duplicate notes can be created. This can be of use if your note type contains the full sentence as first field (meaning this gets looked at for uniqueness)
                    -- When multiple unknown words are present, it won't be possible to add both in this case, because the sentence would be the same.
                    allow_dupes = false,
                    dupe_scope = "deck",

                    -- [REQUIRED] The field name where the word which was looked up in a dictionary will be sent to.
                    word_field = "Expression",

                    -- The field name where the sentence in which the word we looked up occurred will be sent to.
                    context_field = "Sentence",

                    -- Translation of the context field
                    -- translated_context_field = "",

                    prev_sentence_count = 1,
                    next_sentence_count = 1,

                    -- [REQUIRED] The field name where the dictionary definition will be sent to.
                    def_field = "MainDefinition",

                    -- The field name where metadata (book source, page number, ...) will be sent to.
                    -- This metadata is parsed from the EPUB's metadata, or from the filename
                    meta_field = "MiscInfo",

                    -- The plugin can query Forvo for audio of the word you just looked up.
                    -- The field name where the audio will be sent to.
                    audio_field = "ExpressionAudio",

                    -- list of extensions which should be enabled, by default they are all off
                    -- an extension is turned on by listing its filename in the table below
                    -- existing extensions are listed below, remove the leading -- to enable them
                    enabled_extensions = {
                        --"EXT_dict_edit.lua",
                        --"EXT_dict_word_lookup.lua",
                        --"EXT_multi_def.lua",
                        --"EXT_pitch_accent.lua"
                    }
                }
                return Config
              ''
          );
        };
      }
    );
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
