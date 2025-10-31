{
  lib,
  config,
  pkgs,
  ...
}:
{
  options = {
    nix-search-tv.enable = lib.mkEnableOption "enables nix-search-tv";
  };
  config = lib.mkIf config.nix-search-tv.enable {
    home.packages = [
      (pkgs.writeShellApplication {
        name = "ntv";
        runtimeInputs = with pkgs; [
          fzf
          nix-search-tv
        ];
        checkPhase = ""; # Ignore the shell checks
        text = builtins.readFile "${pkgs.nix-search-tv.src}/nixpkgs.sh";
      })
    ];
    programs.nix-search-tv = {
      enable = true;
      settings = {
        experimental = {
          render_docs_indexes = {
            nvf = "https://notashelf.github.io/nvf/options.html";
          };
        };
      };
    };
  };
}
