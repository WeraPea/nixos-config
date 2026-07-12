{
  flake,
  ...
}:
let
  moduleName = "htop";
in
{
  flake.wrappers.htop =
    {
      pkgs,
      wlib,
      ...
    }:
    {
      imports = [
        wlib.wrapperModules.htop
      ];
      package = pkgs.htop-vim;
      settings = {
        color_scheme = 5;
        cpu_count_from_one = 1;
        highlight_base_name = 1;
        highlight_threads = 1;
        show_cpu_frequency = 1;
        show_cpu_temperature = 1;
        show_program_path = 0;
        hide_userland_threads = 1;
        fields = [
          0 # PID
          48 # USER
          17 # PRIORITY
          18 # NICE
          38 # M_SIZE
          39 # M_RESIDENT
          40 # M_SHARE
          2 # STATE
          49 # TIME
          52 # PERCENT_NORM_CPU
          46 # PERCENT_CPU
          47 # PERCENT_MEM
          1 # COMM
        ];
        left_meter_modes = [
          1 # bar
          1
          1
          1
        ];
        left_meters = [
          "LeftCPUs2"
          "Blank"
          "Memory"
          "Swap"
        ];
        right_meter_modes = [
          1 # bar
          2 # text
          2
          2
          2
          2
          2
        ];
        right_meters = [
          "RightCPUs2"
          "Tasks"
          "Systemd"
          "SystemdUser"
          "NetworkIO"
          "DiskIO"
          "Uptime"
        ];
      };
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
      imports = [
        flake.wrappers.htop.install
      ];
      options.werapi.${moduleName} = {
        enable = lib.mkOption {
          default = config.werapi.defaultModules.enable;
          description = "Whether to enable ${moduleName}.";
          type = lib.types.bool;
        };
      };
      config = lib.mkIf cfg.enable {
        environment.systemPackages = [ config.wrappers.htop.wrapper ];
      };
    };
}
