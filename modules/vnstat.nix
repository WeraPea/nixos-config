let
  moduleName = "vnstat";
in
{
  flake.modules.${moduleName}.nixos =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.werapi.${moduleName};
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
        services.vnstat.enable = true;
        systemd.services.vnstat.serviceConfig.ExecStart =
          lib.mkForce "${config.services.vnstat.package}/bin/vnstatd -n --config ${pkgs.writeText "vnstat.conf" ''
            AlwaysAddNewInterfaces 1
            5MinuteHours 744
            HourlyDays -1
            DailyDays -1
            MonthlyMonths -1
            TopDayEntries 100
          ''}";
      };
    };
}
