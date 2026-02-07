{
  lib,
  pkgs,
  outputs,
  ...
}:
{
  home-manager = {
    sharedModules = [
      {
        stylix.targets.fish.enable = false;
        home.username = "wera";
        home.homeDirectory = "/home/wera";
        home.stateVersion = "25.05";
        home.packages =
          with pkgs;
          with outputs.packages.${pkgs.stdenv.hostPlatform.system};
          [
            brightnessctl
            rotate
            switch-boot-partition
            xournalpp
          ];
        mpv.enable = false;
        programs.zathura.enable = false;
        desktopPackages.enable = false;
        koreader.enable = true;
        services.swww.enable = lib.mkForce false;
        wvkbd.enable = true;

        mango = {
          enable = true;
          mainDisplay = "DPI-1";
          extraConfig = # hyprlang
            ''
              monitorrule=name:DPI-1,scale:1.5,x:0,y:0,width:1872,height:1404,refresh:84.996002

              animations=0

              env=DISPLAY,:11
              exec-once=${lib.getExe pkgs.xwayland-satellite} :11
            '';
        };
        quickshell.enable = true;
        programs.quickshell.activeConfig = "pinenote";

        firefox = {
          mobile.enable = true;
          minimal.enable = true;
          theme.dark.enable = false;
        };
      }

    ];
    users.wera = import ./home.nix;
  };
}
