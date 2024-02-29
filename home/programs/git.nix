{
  programs.git = {
    enable = true;
    userName = "werapi";
    userEmail = "sokneip@tuta.io";
    ignores = [
      ".direnv/"
      "result"
      "result-*"
    ];
    extraConfig = {
      init = {defaultBranch = "main";};
    };
    lfs.enable = true;
    aliases = {
      essa = "push --force";
      fuck = "commit --amend -m";
      c = "commit -m";
      ca = "commit -am";
      forgor = "commit --amend --no-edit";
      graph = "log --all --decorate --graph --oneline";
      oops = "checkout --";
      ps = "!git push origin $(git rev-parse --abbrev-ref HEAD)";
      pl = "!git pull origin $(git rev-parse --abbrev-ref HEAD)";
      df = "!git hist | peco | awk '{print $2}' | xargs -I {} git diff {}^ {}";
      hist = ''
        log --pretty=format:"%Cgreen%h %Creset%cd %Cblue[%cn] %Creset%s%C(yellow)%d%C(reset)" --graph --date=relative --decorate --all'';
      llog = ''
        log --graph --name-status --pretty=format:"%C(red)%h %C(reset)(%cd) %C(green)%an %Creset%s %C(yellow)%d%Creset" --date=relative'';
      edit-unmerged = "!f() { git ls-files --unmerged | cut -f2 | sort -u ; }; hx `f`";
    };
  };
}
