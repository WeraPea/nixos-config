{ pkgs, ... }:
{
  imports = [
    ./programs
    ./scripts
  ];

  home.username = "wera";
  home.homeDirectory = "/home/wera";

  nixpkgs.config.allowUnfree = true;

  home.shellAliases = {
    cp = "cp -rip";
    mv = "mv -i";
    rm = "rm -i";
  };

  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  home.sessionVariables = {
    # EDITOR = "emacs";
  };
  home.stateVersion = "23.11";
  programs.home-manager.enable = true;
}
