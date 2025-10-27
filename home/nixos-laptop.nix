{
  inputs,
  pkgs,
  ...
}:
{
  home-manager = {
    sharedModules = [
      inputs.hyprland.homeManagerModules.default
      {
        home = {
          username = "wera";
          homeDirectory = "/home/wera";
          packages = with pkgs; [ brightnessctl ];
          stateVersion = "23.11";
        };
        mango = {
          enable = true;
          extraConfig = # hyprlang
            ''
              monitorrule=eDP-1,0.5,1,tile,0,1,0,0,1920,1080,60,0,0,0,0

              bind=SUPER,F1,focusmon,eDP-1
              bind=SUPER+SHIFT,F1,tagmon,eDP-1
            '';
        };
        quickshell.enable = true;
      }
    ];
    users.wera = import ./home.nix;
  };
}
