{
  lib,
  pkgs,
  inputs,
  outputs,
  ...
}:
{
  imports = [ inputs.home-manager.nixosModules.home-manager ];

  home-manager = {
    extraSpecialArgs = {
      inherit inputs outputs;
    };
    sharedModules = [
      inputs.hyprland.homeManagerModules.default
      inputs.nix-index-database.hmModules.nix-index
      inputs.nixvim.homeManagerModules.nixvim
      {
        stylix.targets.fish.enable = false;
        home.username = "wera";
        home.homeDirectory = "/home/wera";
        home.stateVersion = "25.05";
        home.packages = with pkgs; [
          brightnessctl
          squeekboard
          koreader
          xournalpp
          krita
        ];
        services.kdeconnect.enable = lib.mkForce false;
        mpv.enable = false;
        spicetify.enable = false;
        programs.zathura.enable = false;
        desktopPackages.enable = false;
        pinenote.enable = true;
      }
    ];
    users.wera = import ./home.nix;
    useUserPackages = true;
  };
}
