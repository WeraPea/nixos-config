{
  programs.nixvim.keymaps = [
    {
      mode = "n";
      key = "   ";
      action = ":noh<CR>";
      options = {
        silent = true;
        noremap = true;
      };
    }
    {
      mode = "n";
      key = "j";
      action = "gj";
      options = {
        silent = true;
        noremap = true;
      };
    }
    {
      mode = "n";
      key = "gj";
      action = "j";
      options = {
        silent = true;
        noremap = true;
      };
    }
    {
      mode = "n";
      key = "k";
      action = "gk";
      options = {
        silent = true;
        noremap = true;
      };
    }
    {
      mode = "n";
      key = "gk";
      action = "k";
      options = {
        silent = true;
        noremap = true;
      };
    }
    {
      mode = "n";
      key = "H";
      action = "^";
      options = {
        silent = true;
        noremap = true;
      };
    }
    {
      mode = "n";
      key = "L";
      action = "$";
      options = {
        silent = true;
        noremap = true;
      };
    }
    {
      mode = "v";
      key = "<";
      action = "<gv";
      options = {
        silent = true;
        noremap = true;
      };
    }
    {
      mode = "v";
      key = ">";
      action = ">gv";
      options = {
        silent = true;
        noremap = true;
      };
    }
    {
      mode = "n";
      key = "n";
      action = "nzz";
      options = {
        silent = true;
        noremap = true;
      };
    }
    {
      mode = "n";
      key = "N";
      action = "Nzz";
      options = {
        silent = true;
        noremap = true;
      };
    }
    {
      mode = "n";
      key = "*";
      action = "*zz";
      options = {
        silent = true;
        noremap = true;
      };
    }
    {
      mode = "n";
      key = "#";
      action = "#zz";
      options = {
        silent = true;
        noremap = true;
      };
    }
    {
      mode = "n";
      key = "g*";
      action = "g*zz";
      options = {
        silent = true;
        noremap = true;
      };
    }
    {
      mode = "n";
      key = "<C-h>";
      action = "<C-w>h";
      options = {
        silent = true;
        noremap = true;
      };
    }
    {
      mode = "n";
      key = "<C-j>";
      action = "<C-w>j";
      options = {
        silent = true;
        noremap = true;
      };
    }
    {
      mode = "n";
      key = "<C-k>";
      action = "<C-w>k";
      options = {
        silent = true;
        noremap = true;
      };
    }
    {
      mode = "n";
      key = "<C-l>";
      action = "<C-w>l";
      options = {
        silent = true;
        noremap = true;
      };
    }
    {
      mode = "i";
      key = "<C-h>";
      action = "<ESC><C-w>h";
      options = {
        silent = true;
        noremap = true;
      };
    }
    {
      mode = "i";
      key = "<C-j>";
      action = "<ESC><C-w>j";
      options = {
        silent = true;
        noremap = true;
      };
    }
    {
      mode = "i";
      key = "<C-k>";
      action = "<ESC><C-w>k";
      options = {
        silent = true;
        noremap = true;
      };
    }
    {
      mode = "i";
      key = "<C-l>";
      action = "<ESC><C-w>l";
      options = {
        silent = true;
        noremap = true;
      };
    }
    {
      mode = "c";
      key = "w!!";
      action = "w ! sudo tee %";
      options = {noremap = true;};
    } # delete this
  ];
}
