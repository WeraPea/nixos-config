{
  inputs,
  ...
}:
let
  moduleName = "nvimpager";
in
{
  flake.modules.${moduleName}.nixos =
    {
      config,
      lib,
      pkgs,
      ...
    }@args:
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
        environment.sessionVariables = {
          NVIMPAGER_NVIM = lib.getExe (
            (inputs.nixvim.legacyPackages."${pkgs.stdenv.hostPlatform.system}".makeNixvim (
              {
                globals.mapleader = " ";
                plugins = {
                  lualine = {
                    enable = true;
                    settings.sections.lualine_c = [ "none" ];
                  };
                };
                extraConfigLuaPost = ''
                  nvimpager.maps = false
                  vim.opt.number = false

                  local function strip_ansi_escape_codes(text)
                    local stripped_text = {}
                    for _, line in ipairs(text) do
                      table.insert(stripped_text, (line:gsub("\27%[[%d;]*[mK]", "")))
                    end
                    return stripped_text
                  end
                  vim.g.clipboard = {
                    name = 'OSC 52',
                    copy = {
                      ["+"] = function(lines, _)
                        require('vim.ui.clipboard.osc52').copy('+')(strip_ansi_escape_codes(lines))
                      end,
                      ["*"] = function(lines, _)
                        require('vim.ui.clipboard.osc52').copy('*')(strip_ansi_escape_codes(lines))
                      end,
                    },
                    paste = {
                      ['+'] = require('vim.ui.clipboard.osc52').paste('+'),
                      ['*'] = require('vim.ui.clipboard.osc52').paste('*'),
                    },
                  }
                '';
              }
              // ((import ./nixvim/options.nix).flake.modules.nixvim.nixos args).config.content.hm.programs.nixvim
              // ((import ./nixvim/keymaps.nix).flake.modules.nixvim.nixos args).config.content.hm.programs.nixvim
            )).extend
              config.stylix.targets.nixvim.exportedModule
          );
        };
      };
    };
}
