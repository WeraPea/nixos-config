{
  config,
  lib,
  ...
}:
let
  moduleName = "ssh";
  cfg = config.werapi.${moduleName};
  hmConfig = config.home-manager.users.${config.werapi.username};
in
{
  options.werapi.${moduleName} = {
    enable = lib.mkOption {
      default = config.werapi.defaultModules.enable;
      description = "Whether to enable ${moduleName}.";
      type = lib.types.bool;
    };
  };
  config = lib.mkIf cfg.enable {
    services.openssh.enable = true;
    hm.programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
      matchBlocks = {
        "github.com" = {
          hostname = "github.com";
          user = "git";
          identityFile = "${hmConfig.home.homeDirectory}/.ssh/github_ed25519";
          identitiesOnly = true;
        };
        "*" = {
          forwardAgent = false;
          addKeysToAgent = "no";
          compression = false;
          serverAliveInterval = 0;
          serverAliveCountMax = 3;
          hashKnownHosts = false;
          userKnownHostsFile = "~/.ssh/known_hosts";
          controlMaster = "no";
          controlPath = "~/.ssh/master-%r@%n:%p";
          controlPersist = "no";
        };
        "lavender" = {
          hostname = "lavender";
          port = 8022;
        };
        "lavender-ts" = {
          hostname = "lavender-ts";
          port = 8022;
        };
      };
    };
  };
}
