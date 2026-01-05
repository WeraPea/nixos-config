{
  programs.nixvim.opts = {
    clipboard = "unnamedplus";
    cursorline = true;
    expandtab = true;
    foldenable = false;
    ignorecase = true;
    lazyredraw = true;
    linebreak = true;
    listchars = "nbsp:¬,trail:•,space:•,tab:-->";
    mouse = "a";
    number = true;
    scrolloff = 8;
    shiftwidth = 2;
    sidescrolloff = 8;
    smartcase = true;
    splitbelow = true;
    splitright = true;
    tabstop = 2;
    undofile = true;
    updatetime = 300;
    writebackup = false;
    exrc = true;
    secure = true;
    foldlevel = 99;
  };
}
