{
  lib,
  pkgs,
  inputs,
  config,
  outputs,
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
        services.hyprpaper.enable = lib.mkForce false;
        wvkbd.enable = true;

        mango = {
          enable = true;
          mainDisplay = "DPI-1";
          extraConfig = # hyprlang
            ''
              monitorrule=DPI-1,0.5,1,tile,0,1.5,0,0,1872,1404,84.996002,0,0,0,0

              animations=0

              env=DISPLAY,:11
              exec-once=${lib.getExe pkgs.xwayland-satellite} :11
            '';
        };
        quickshell.enable = true;
        programs.quickshell.activeConfig = "pinenote";
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
      }

    ];
    users.wera = import ./home.nix;
  };
}
