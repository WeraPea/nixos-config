{
  lib,
  pkgs,
  outputs,
  inputs,
  config,
  ...
}:
let
  pkgsCross = import inputs.pinenote-nixos.inputs.nixpkgs {
    # nixpkgs from pinenote-nixos to not rebuild the kernel when not needed
    system = "x86_64-linux";
    crossSystem = {
      config = "aarch64-unknown-linux-gnu";
    };
  };
  pkgsX86_64 = import inputs.nixpkgs {
    system = "x86_64-linux";
  };
in
{
  imports = [ inputs.pinenote-nixos.nixosModules.default ];
  werapi = {
    hostname = "pinenote";
    defaultModules.enable = true;

    firefox = {
      mobile.enable = true;
      minimal.enable = true;
      theme.dark.enable = false;
    };
    koreader.enable = true;
    mango = {
      mainDisplay = "DPI-1";
      defaultLayout = "scroller";
      bindModes.default.binds.touchgesturebind."down,any,any,3" =
        "spawn,busctl --user call org.pinenote.PineNoteCtl /org/pinenote/PineNoteCtl org.pinenote.Ebc1 GlobalRefresh";
    };
    mpv.enable = false;
    pinenote-dither-sync.enable = true;
    quickshell.enable = true;
    wvkbd.enable = true;
  };

  environment.systemPackages =
    with pkgs;
    with outputs.packages.${pkgs.stdenv.hostPlatform.system};
    [
      brightnessctl
      pinenote-screenshot
      rotate
      switch-boot-partition
      xournalpp
    ];

  hm = {
    home.stateVersion = "25.05";
    stylix.targets.fish.enable = false;
    programs.zathura.enable = false;
    wayland.windowManager.mango.settings = {
      monitorrule = "name:DPI-1,scale:1.5,x:0,y:0,width:1872,height:1404,refresh:84.996002,rr:1";

      animations = lib.mkForce 0;
      dither = 1;
      tablet_map_to_mon = "name:DPI-1";

      env = [ "DISPLAY,:11" ];
      exec-once = [ "${lib.getExe pkgs.xwayland-satellite} :11" ];
    };
    programs.quickshell.activeConfig = "pinenote";
  };

  pinenote.config.enable = true;
  pinenote.pinenote-service.enable = true;

  stylix.targets.fish.enable = false;
  stylix = {
    fonts.monospace.package = lib.mkForce (
      if (config.werapi.buildSystem == "x86_64-linux") then
        pkgsX86_64.callPackage ../pkgs/udev-gothic-hs-nf.nix { }
      else
        outputs.packages.${pkgs.stdenv.hostPlatform.system}.udev-gothic-hs-nf
    );

    cursor.name = lib.mkForce "Bibata-Modern-Ice";

    opacity = lib.mkForce {
      applications = 1.;
      desktop = 1.;
      popups = 1.;
      terminal = 1.;
    };

    base16Scheme = lib.mkForce {
      scheme = "eink-light";
      base00 = "#ffffff";
      base01 = "#eeeeee";
      base02 = "#dddddd";
      base03 = "#bbbbbb";
      base04 = "#444444";
      base05 = "#222222";
      base06 = "#111111";
      base07 = "#000000";
      base08 = "#777777";
      base09 = "#cccccc";
      base0A = "#aaaaaa";
      base0B = "#999999";
      base0C = "#888888";
      base0D = "#333333";
      base0E = "#666666";
      base0F = "#555555";
    };
  };

  services.logind.settings.Login = {
    HandlePowerKey = "suspend";
    HandlePowerKeyLongPress = "poweroff";
  };
  services.journald.storage = "volatile";

  hardware.opentabletdriver.enable = lib.mkForce false;

  security.sudo.extraRules = [
    {
      groups = [ "wheel" ];
      commands = [
        {
          command = lib.getExe outputs.packages.${pkgs.stdenv.hostPlatform.system}.usb-tablet;
          options = [
            "SETENV"
            "NOPASSWD"
          ];
        }
      ];
    }
  ];

  system.stateVersion = "25.05";
  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";

  boot.kernelPackages = lib.mkIf (config.werapi.buildSystem == "x86_64-linux") (
    pkgsCross.linuxPackagesFor (
      pkgsCross.callPackage "${inputs.pinenote-nixos}/packages/pinenote-kernel.nix" { }
    )
  );

  fileSystems."/" = {
    label = "nixos";
    fsType = "ext4";
  };
}
