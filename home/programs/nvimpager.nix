{
  lib,
  pkgs,
  inputs,
  config,
  ...
}:
{
  home.sessionVariables = {
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
          # TODO: ↓ clean this up?
          extraConfigLuaPost = ''
            nvimpager.maps = false
            vim.opt.clipboard:append("unnamedplus")
            vim.opt.number = false

            local function strip_ansi_escape_codes(text)
                local stripped_text = {}
                for _, line in ipairs(text) do
                    table.insert(stripped_text, (line:gsub("\27%[[%d;]*[mK]", "")))
                end
                return stripped_text
            end

            vim.g.clipboard = {
                copy = {
                    ["+"] = function(lines, _)
                        local processed = table.concat(strip_ansi_escape_codes(lines), "\n")
                        vim.fn.system("wl-copy", processed)
                    end,
                    ["*"] = function(lines, _)
                        local processed = table.concat(strip_ansi_escape_codes(lines), "\n")
                        vim.fn.system("wl-copy", processed)
                    end,
                },
                paste = {
                    ["+"] = function()
                        local result = vim.fn.system("wl-paste")
                        return vim.split(result, "\n", { plain = true })
                    end,
                    ["*"] = function()
                        local result = vim.fn.system("wl-paste --primary")
                        return vim.split(result, "\n", { plain = true })
                    end,
                },
            }
          '';
        }
        // (import ./nixvim/options.nix).programs.nixvim
        // (import ./nixvim/keymaps.nix).programs.nixvim
      )).extend
        config.lib.stylix.nixvim.config
    );
    MANPAGER = lib.getExe pkgs.nvimpager;
  };
}
