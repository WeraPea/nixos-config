{
  flake,
  ...
}:
let
  moduleName = "ccache";
  cacheDir = "/var/cache/ccache";
in
{

  flake.overlays = {
    _ccache = (
      final: prev: {
        # from ccache module, at the time of writing this only gets added when ccache.packageNames is non-empty
        ccacheWrapper = prev.ccacheWrapper.override {
          extraConfig = ''
            export CCACHE_COMPRESS=1
            export CCACHE_SLOPPINESS=random_seed
            export CCACHE_DIR="${cacheDir}"
            export CCACHE_UMASK=007
            if [ ! -d "$CCACHE_DIR" ]; then
              echo "====="
              echo "Directory '$CCACHE_DIR' does not exist"
              echo "Please create it with:"
              echo "  sudo mkdir -m0770 '$CCACHE_DIR'"
              echo "  sudo chown root:nixbld '$CCACHE_DIR'"
              echo "====="
              exit 1
            fi
            if [ ! -w "$CCACHE_DIR" ]; then
              echo "====="
              echo "Directory '$CCACHE_DIR' is not accessible for user $(whoami)"
              echo "Please verify its access permissions"
              echo "====="
              exit 1
            fi
          '';
        };
      }
    );
  };
  flake.modules.${moduleName}.nixos =
    {
      config,
      lib,
      ...
    }:
    let
      cfg = config.werapi.${moduleName};
    in
    {
      options.werapi.${moduleName} = {
        enable = lib.mkOption {
          default = false;
          description = "Whether to enable ${moduleName}.";
          type = lib.types.bool;
        };
        targetOnly.enable = lib.mkOption {
          default = false;
          description = "Whether to enable ${moduleName} as a target host.";
          type = lib.types.bool;
        };
      };
      config = lib.mkIf cfg.enable {
        programs.ccache = {
          inherit cacheDir;
          enable = !cfg.targetOnly.enable;
        };
        nix.settings.extra-sandbox-paths = [ config.programs.ccache.cacheDir ];
        nixpkgs.overlays = [ flake.overlays._ccache ];
      };
    };
}
