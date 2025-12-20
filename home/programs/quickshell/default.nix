{
  config,
  inputs,
  outputs,
  lib,
  pkgs,
  ...
}:
let
  make-config =
    base: name:
    pkgs.runCommand name { } ''
      mkdir -p $out/common
      ${pkgs.lndir}/bin/lndir -silent ${base} $out
      ${pkgs.lndir}/bin/lndir -silent ${./common} $out/common/
    '';

  pinenote-patched = pkgs.runCommand "pinenote-patched" { } ''
    mkdir -p $out
    cp -r ${./pinenote}/* $out
    substituteInPlace $out/Bar.qml \
      --replace-fail rotate-screen ${lib.getExe (pkgs.callPackage ./../pinenote/rotate.nix { })} \
      --replace-fail usb-tablet ${
        lib.getExe outputs.packages.${pkgs.stdenv.hostPlatform.system}.usb-tablet
      } \
      --replace-fail dbus-send ${lib.getExe' pkgs.dbus "dbus-send"} \
      --replace-fail nwggrid ${lib.getExe' pkgs.nwg-launchers "nwggrid"};
    substituteInPlace $out/BrightnessWidget.qml \
      --replace-fail brightnessctl ${lib.getExe pkgs.brightnessctl};
  '';
in
{
  options = {
    quickshell.enable = lib.mkEnableOption "Enables quickshell";
  };
  config = lib.mkIf config.quickshell.enable {
    programs.quickshell = {
      enable = true;
      activeConfig = lib.mkDefault "desktop";
      configs.desktop = make-config ./desktop "desktop";
      configs.pinenote = make-config pinenote-patched "pinenote";
      systemd.enable = true;
      package = lib.mkDefault inputs.quickshell.packages.${pkgs.stdenv.hostPlatform.system}.quickshell;
    };
  };
}
