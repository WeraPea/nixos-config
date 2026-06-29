{
  lib,
  ...
}:
{
  options.flake.settings = lib.mkOption { };
  config.flake.settings = {
    systems = [
      "x86_64-linux"
      "aarch64-linux"
    ];
  };
}
