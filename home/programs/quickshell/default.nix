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
      cp -r ${./common}/. $out/common
      substituteInPlace $out/common/BrightnessWidget.qml \
        --replace-fail brightnessctl ${lib.getExe pkgs.brightnessctl};
    '';

  pinenote-patched = pkgs.runCommand "pinenote-patched" { } ''
    mkdir -p $out
    cp -r ${./pinenote}/* $out
    substituteInPlace $out/Bar.qml \
      --replace-fail rotate-screen ${
        lib.getExe outputs.packages.${pkgs.stdenv.hostPlatform.system}.rotate
      } \
      --replace-fail usb-tablet ${
        lib.getExe outputs.packages.${pkgs.stdenv.hostPlatform.system}.usb-tablet
      } \
      --replace-fail dbus-send ${lib.getExe' pkgs.dbus "dbus-send"};
  '';

  fajita-patched = pkgs.runCommand "fajita-patched" { } ''
    mkdir -p $out
    cp -r ${./fajita}/* $out
    substituteInPlace $out/Bar.qml \
      --replace-fail rotate-screen ${
        lib.getExe outputs.packages.${pkgs.stdenv.hostPlatform.system}.rotate
      }
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
      configs.fajita = make-config fajita-patched "fajita";
      systemd.enable = true;
      package = lib.mkDefault inputs.quickshell.packages.${pkgs.stdenv.hostPlatform.system}.quickshell;
    };
  };
}
