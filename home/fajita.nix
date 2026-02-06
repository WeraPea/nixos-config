{
  lib,
  pkgs,
  inputs,
  config,
  ...
}:
let
  pkgsCross = import inputs.nixpkgs {
    system = "x86_64-linux";
    crossSystem = {
      config = "aarch64-unknown-linux-gnu";
    };
    overlays = [ inputs.quickshell.overlays.default ];
  };
in
{
  home-manager = {
    sharedModules = [
      {
        home.username = "wera";
        home.homeDirectory = "/home/wera";
        home.stateVersion = "25.11";
        home.packages = with pkgs; [
          # chatty
        ];
        programs.zathura.enable = false;
        desktopPackages.enable = false;

        koreader.enable = true;
        services.swww.enable = lib.mkForce false;
        wvkbd.enable = true;

        mango = {
          enable = true;
          mainDisplay = "DSI-1";
          extraConfig = # hyprlang
            ''
              monitorrule=name:DSI-1,scale:1.5,x:0,y:0,width:1080,height:2340,refresh:60
              bind=NONE,XF86PowerOff,spawn,${lib.getExe pkgs.wlopm} --toggle "*"
            '';
        };
        quickshell.enable = true;
        programs.quickshell.activeConfig = "pinenote"; # TODO:
        programs.quickshell.package =
          if (config.buildSystem == "x86_64-linux") then
            pkgsCross.quickshell.override {
              inherit (pkgs)
                qt6
                breakpad
                jemalloc
                cli11
                wayland
                wayland-protocols
                wayland-scanner
                xorg
                libdrm
                pipewire
                pam
                polkit
                glib
                ;
            }
          else
            inputs.quickshell.packages.${pkgs.stdenv.hostPlatform.system}.quickshell;

        firefox = {
          mobile.enable = true;
          minimal.enable = true;
        };

        mpv.enable = false;
      }
    ];
    users.wera = import ./home.nix;
  };
}
