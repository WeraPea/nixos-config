{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  moduleName = "home-manager";
  cfg = config.werapi.${moduleName};
  hmConfig = config.home-manager.users.${config.werapi.username};
in
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
    (lib.mkAliasOptionModule [ "hm" ] [ "home-manager" "users" config.werapi.username ])
  ];

  options.werapi.${moduleName} = {
    enable = lib.mkOption {
      default = config.werapi.defaultModules.enable;
      description = "Whether to enable ${moduleName}.";
      type = lib.types.bool;
    };
  };
  config = lib.mkIf cfg.enable {
    home-manager = {
      useUserPackages = true;
      useGlobalPkgs = true;
      sharedModules = [
        inputs.nix-index-database.homeModules.nix-index
      ];
    };
    hm = {
      home = {
        username = config.werapi.username;
        homeDirectory = "/home/${config.werapi.username}";
      };
      programs.home-manager.enable = true;

      home.shellAliases = {
        cp = "cp -rip";
        mv = "mv -i";
        rm = "rm -i";
        cl = "clear";
        dc = "cd";
        lc = "clear";
        ls = "ll";
        ns = "sudo nixos-rebuild switch --flake ~/nixos-config";
        nt = "sudo nixos-rebuild test --flake ~/nixos-config";
        sl = "ll";
        vim = "nvim";
        vm = "mv";
        x = "exit";
      };
      gtk.enable = lib.mkIf config.werapi.graphics.enable <| lib.mkDefault true;
      # gtk.gtk4.theme = config.gtk.theme;
      gtk.gtk4.theme = null;

      programs = {
        aria2.enable = true;
        bash.enable = true;
        jq.enable = true;
        nix-index.enable = true;
        nix-index-database.comma.enable = true;
        command-not-found.enable = lib.mkIf hmConfig.programs.nix-index.enable <| false;
        zathura.enable = lib.mkIf config.werapi.graphics.enable <| lib.mkDefault true;
        bat = {
          enable = true;
          extraPackages = with pkgs.bat-extras; [
            batdiff
            batwatch
          ];
          config.paging = "never";
        };
        eza = {
          enable = true;
          git = true;
          icons = "auto";
          extraOptions = [ "--group-directories-first" ];
        };
        direnv = {
          enable = true;
          nix-direnv.enable = true;
        };
      };

      services = {
        cliphist.enable = lib.mkIf config.werapi.graphics.enable <| lib.mkDefault true;
        wl-clip-persist = {
          enable = lib.mkIf config.werapi.graphics.enable <| lib.mkDefault true;
          clipboardType = "both";
        };
      };
    };
  };
}
