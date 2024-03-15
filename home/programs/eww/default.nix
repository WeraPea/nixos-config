{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    eww
    pamixer
  ];

  systemd.user.services.eww = {
    Unit = {
      Description = "eww";
      After = ["graphical-session-pre.target"];
      PartOf = ["graphical-session.target"];
    };

    Service = {
      ExecStart = "${lib.getExe pkgs.eww} daemon --no-daemonize";
      Restart = "on-failure";
      RestartSec = 10;
    };

    Install = {WantedBy = ["graphical-session.target"];};
  };
  home.activation.linkEww = let
    themeFile = config.lib.stylix.colors {
      templateRepo = inputs.base16Styles;
      target = "scss";
    };
    test = pkgs.substituteAll {
      src = ./test;
      test = "helloworldiguess";
    };
  in
    lib.hm.dag.entryAfter ["writeBoundary"] ''
      if [[ -e $HOME/.config/eww ]]; then
        $DRY_RUN_CMD rm -r $VERBOSE_ARG $HOME/.config/eww
      fi
      $DRY_RUN_CMD mkdir -p $HOME/.config/eww
      for f in ${builtins.toPath ./files/.}/*; do
        $DRY_RUN_CMD ln -s $VERBOSE_ARG $f $HOME/.config/eww/
      done
      $DRY_RUN_CMD ln -s $VERBOSE_ARG \
        ${themeFile} $HOME/.config/eww/theme.scss
      $DRY_RUN_CMD ln -s $VERBOSE_ARG \
        ${test} $HOME/.config/eww/test
    '';
}
