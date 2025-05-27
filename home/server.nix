{
  home-manager = {
    sharedModules = [
      {
        home = {
          username = "wera";
          homeDirectory = "/home/wera";
          stateVersion = "23.11";
        };
      }
    ];
    users.wera = import ./home.nix;
  };
}
