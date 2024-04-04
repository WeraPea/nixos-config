{ outputs, pkgs, ... }:
{
  programs.mpv = {
    enable = true;
    scripts = with pkgs; [
      mpvScripts.mpris
      mpvScripts.thumbfast
      mpvScripts.webtorrent-mpv-hook
      outputs.packages.progressbar
    ];
    config = {
      ontop = "no";
      osc = "no";
      slang = "en";
    };
    scriptOpts = {
      thumbfast = {
        network = "yes";
      };
      "torque-progressbar/main" = {
        bar-cache-height-active = 16;
        bar-height-active = 16;
        bar-hide-inactive = "yes";
        enable-system-time = "no";
        hover-zone-height = 80;
        top-hover-zone-height = 80;
      };
    };
    bindings = {
      c = "script-binding progressbar/toggle-inactive-bar";
      tab = "script-binding progressbar/request-display";
      mouse_btn0 = "script-binding progressbar/left-click";

      RIGHT = "seek  3";
      LEFT = "seek -3";
      UP = "add volume +2";
      DOWN = "add volume -2";

      h = "seek -3";
      l = "seek +3";
      j = "add volume -2";
      k = "add volume +2";

      H = "seek -10";
      J = "seek +10";

      "Alt+h" = "add sub-delay -0.1";
      "Alt+l" = "add sub-delay 0.1";

      "Alt+j" = "add sub-scale -0.1";
      "Alt+k" = "add sub-scale 0.1";

      "Alt+J" = "add sub-scale +0.1";
      "Alt+K" = "add sub-scale +0.1";

      v = "cycle sub-visibility";

      s = "cycle sub";
      S = "cycle sub down";

      MBTN_LEFT_DBL = "cycle fullscreen";
      MBTN_LEFT = "cycle pause";

      WHEEL_LEFT = "seek -10";
      WHEEL_RIGHT = "seek 10";
      WHEEL_UP = "add volume 2";
      WHEEL_DOWN = "add volume -2";

      "Ctrl+j" = "add video-zoom -0.1";
      "Ctrl+k" = "add video-zoom 0.1";
      "Ctrl+u" = "set video-zoom 0";

      "[" = "multiply speed 1/1.1";
      "]" = "multiply speed 1.1";
      "{" = "multiply speed 0.5";
      "}" = "multiply speed 2.0";

      u = "set speed 1.0";

      U = "revert-seek";
      "Ctrl+U" = "revert-seek mark";

      ESC = "set fullscreen no";
      f = "cycle fullscreen";

      q = "quit-watch-later";
      Q = "quit";

      m = "cycle mute";
      SPACE = "cycle pause";
      p = "show-progress";

      "." = "frame-step";
      "," = "frame-back-step";

      N = "playlist-next";
      P = "playlist-prev";

      o = ''cycle-values loop-file "inf" "no"'';
      O = "ab-loop";
      i = "show-text \${playlist}";
      I = "show-text \${track-list}";

      PGUP = "add chapter 1";
      PGDWN = "add chapter -1";
    };
  };
}
