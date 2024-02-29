{...}: {
  imports = [./keymaps.nix ./options.nix ./plugins.nix];
  home.sessionVariables.EDITOR = "nvim";
  programs.nixvim = {
    enable = true;
    globals.mapleader = " ";
    autoCmd = [
      # Remove trailing whitespace on save
      {
        event = "BufWrite";
        command = "%s/\\s\\+$//e";
      }

      {
        event = ["BufEnter" "FocusGained"];
        command = "checktime";
      }

      # Set indentation to 2 spaces for nix files
      # {
      #   event = "FileType";
      #   pattern = "nix";
      #   command = "setlocal tabstop=2 shiftwidth=2";
      # }

      {
        event = "FileType";
        pattern = [
          "markdown"
          "text"
        ];
        command = "setlocal spell spelllang=en";
      }
    ];
    extraConfigLua = ''
      local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
      for type, icon in pairs(signs) do
        local hl = "DiagnosticSign" .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
      end
    '';
  };
}
