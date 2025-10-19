{
  pkgs,
  lib,
  config,
  ...
}:
{
  options = {
    # TODO: extend for pinenote, lower latency
    roc.enable = lib.mkEnableOption "Enables pipewire roc modules";
    roc.sink = lib.mkEnableOption "Enables roc sink";
    roc.source = lib.mkEnableOption "Enables roc source";
    roc.source-ip = lib.mkOption {
      description = "Sets source ip address";
    };
  };
  config = lib.mkIf config.roc.enable {
    networking.firewall = lib.mkIf config.roc.source rec {
      allowedTCPPorts = [
        10001
        10002
        10003
      ];
      allowedUDPPorts = allowedTCPPorts;
    };
    services.pipewire.configPackages =
      if config.roc.sink then
        [
          (pkgs.writeTextDir "share/pipewire/pipewire.conf.d/10-roc-sink.conf" ''
            context.modules = [
              { name = libpipewire-module-roc-sink
                args = {
                  fec.code = disable
                  remote.ip = ${config.roc.source-ip}
                  remote.source.port = 10001
                  remote.repair.port = 10002
                  remote.control.port = 10003
                  sink.name = "ROC Sink"
                  sink.props = {
                   node.name = "roc-sink"
                  }
                }
                flags = [ nofail ]
              }
            ]
          '')
        ]
      else if config.roc.source then
        [
          (pkgs.writeTextDir "share/pipewire/pipewire.conf.d/10-roc-source.conf" ''
            context.modules = [
              { name = libpipewire-module-roc-source
                args = {
                  local.ip = ${config.roc.source-ip}
                  #roc.resampler.backend = default
                  roc.resampler.profile = medium
                  #roc.latency-tuner.backend = default
                  #roc.latency-tuner.profile = default
                  fec.code = disable
                  sess.latency.msec = 250
                  local.source.port = 10001
                  local.repair.port = 10002
                  local.control.port = 10003
                  source.name = "ROC Source"
                  source.props = {
                   node.name = "roc-source"
                  }
                }
                flags = [ nofail ]
              }
            ]
          '')
        ]
      else
        [ ];
  };
}
