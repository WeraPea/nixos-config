{
  pkgs,
  lib,
  config,
  outputs,
  ...
}:
{
  options = {
    htop.enable = lib.mkEnableOption "enables htop";
  };
  config = lib.mkIf config.htop.enable {
    programs.htop = {
      enable = true;
      package = outputs.packages.${pkgs.system}.htop-vim;
      settings =
        {
          color_scheme = 5;
          cpu_count_from_one = 1;
          highlight_base_name = 1;
          highlight_threads = 1;
          show_cpu_frequency = 1;
          show_cpu_temperature = 1;
          show_program_path = 0;
          hide_userland_threads = 1;
          fields = with config.lib.htop.fields; [
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
          with config.lib.htop;
          leftMeters [
            (bar "LeftCPUs2")
            (bar "Blank")
            (bar "Memory")
            (bar "Swap")
          ]
        )
        // (
          with config.lib.htop;
          rightMeters [
            (bar "rightCPUs2")
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
