{
  config,
  lib,
  pkgs,
  ...
}:
let
  moduleName = "htop";
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
    hm.programs.htop = {
      enable = true;
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
        fields = with hmConfig.lib.htop.fields; [
          PID
          USER
          PRIORITY
          NICE
          M_SIZE
          M_RESIDENT
          M_SHARE
          STATE
          TIME
          PERCENT_NORM_CPU
          PERCENT_CPU
          PERCENT_MEM
          COMM
        ];
      }
      // (
        with hmConfig.lib.htop;
        leftMeters [
          (bar "LeftCPUs2")
          (bar "Blank")
          (bar "Memory")
          (bar "Swap")
        ]
      )
      // (
        with hmConfig.lib.htop;
        rightMeters [
          (bar "RightCPUs2")
          (text "Tasks")
          (text "Systemd")
          (text "SystemdUser")
          (text "NetworkIO")
          (text "DiskIO")
          (text "Uptime")
        ]
      );
    };
  };
}
