{
  pkgs,
  lib,
  config,
  ...
}:
{
  options = {
    git.enable = lib.mkEnableOption "enables git";
  };
  config = lib.mkIf config.git.enable {
    programs.git = {
      enable = true;
      userName = "werapi";
      userEmail = "sokneip@tuta.io";
      ignores = [
        ".ccls-cache"
        ".ccls"
        ".clangd"
        ".direnv/"
        "result"
        "result-*"
      ];
      extraConfig = {
        init = {
          defaultBranch = "main";
        };
        merge = {
          tool = "nvimdiff";
        };
      };
      lfs.enable = true;
      aliases = {
        essa = "push --force";
        c = "commit -m";
        ca = "commit -am";
        graph = "log --all --decorate --graph --oneline";
        ps = "!git push origin $(git rev-parse --abbrev-ref HEAD)";
        pl = "!git pull origin $(git rev-parse --abbrev-ref HEAD)";
        df = "!git hist | ${lib.getExe pkgs.peco} | awk '{print $2}' | xargs -I {} git diff {}^ {}";
        hist = ''log --pretty=format:"%Cgreen%h %Creset%cd %Cblue[%cn] %Creset%s%C(yellow)%d%C(reset)" --graph --date=relative --decorate --all'';
        llog = ''log --graph --name-status --pretty=format:"%C(red)%h %C(reset)(%cd) %C(green)%an %Creset%s %C(yellow)%d%Creset" --date=relative'';
        edit-unmerged = "!f() { git ls-files --unmerged | cut -f2 | sort -u ; }; nvim `f`";
      };
    };
  };
}
