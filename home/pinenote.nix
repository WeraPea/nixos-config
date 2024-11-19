{
  inputs,
  outputs,
  pkgs,
  config,
  ...
}:
{
  imports = [ inputs.home-manager.nixosModules.home-manager ];

  home-manager = {
    extraSpecialArgs = {
      inherit inputs outputs;
    };
    sharedModules = [
      inputs.nixvim.homeManagerModules.nixvim
      {
        home.username = "wera";
        home.homeDirectory = "/home/wera";
        home.stateVersion = "23.11";
        # home.packages = with pkgs; [ ... ];
        hyprland.enable = false;
        mpv.enable = false;
        spicetify.enable = false;
        programs.zathura.enable = false;
        desktopPackages.enable = false;
      }
    ];
    users.wera = import ./home.nix;
    useUserPackages = true;
  };
}
