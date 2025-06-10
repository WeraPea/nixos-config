{
  programs.nixvim.keymaps = [
    # plugins
    {
      mode = "n";
      key = "<leader>o";
      action = ":Oil<cr>";
    }
    {
      mode = "n";
      key = "<leader>u";
      action = ":UndotreeToggle<cr>";
    }
    # vanilla
    {
      mode = "n";
      key = "   ";
      action = ":noh<CR>";
      options.silent = true;
    }
    {
      mode = "n";
      key = "j";
      action = "gj";
    }
    {
      mode = "n";
      key = "k";
      action = "gk";
    }
    {
      mode = [
        "v"
        "o"
        "n"
      ];
      key = "H";
      action = "^";
    }
    {
      mode = [
        "v"
        "o"
        "n"
      ];
      key = "L";
      action = "$";
    }
    {
      mode = "v";
      key = "<";
      action = "<gv";
    }
    {
      mode = "v";
      key = ">";
      action = ">gv";
    }
    {
      mode = "v";
      key = "<TAB>";
      action = ">gv";
    }
    {
      mode = "v";
      key = "<S-TAB>";
      action = "<gv";
    }
    {
      mode = "n";
      key = "n";
      action = "nzz";
      # options = {
      #   noremap = true;
      # };
    }
    {
      mode = "n";
      key = "N";
      action = "Nzz";
      # options = {
      #   noremap = true;
      # };
    }
    {
      mode = "n";
      key = "*";
      action = "*zz";
    }
    {
      mode = "n";
      key = "#";
      action = "#zz";
    }
    {
      mode = "n";
      key = "<C-h>";
      action = "<C-w>h";
      options.silent = true;
    }
    {
      mode = "n";
      key = "<C-j>";
      action = "<C-w>j";
      options.silent = true;
    }
    {
      mode = "n";
      key = "<C-k>";
      action = "<C-w>k";
      options.silent = true;
    }
    {
      mode = "n";
      key = "<C-l>";
      action = "<C-w>l";
      options.silent = true;
    }
    {
      mode = "i";
      key = "<C-h>";
      action = "<ESC><C-w>h";
      options.silent = true;
    }
    {
      mode = "i";
      key = "<C-j>";
      action = "<ESC><C-w>j";
      options.silent = true;
    }
    {
      mode = "i";
      key = "<C-k>";
      action = "<ESC><C-w>k";
      options.silent = true;
    }
    {
      mode = "i";
      key = "<C-l>";
      action = "<ESC><C-w>l";
      options.silent = true;
    }
  ];
}
