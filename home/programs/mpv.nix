{
  pkgs,
  lib,
  config,
  outputs,
  ...
}:
{
  options = {
    mpv.enable = lib.mkEnableOption "enables mpv";
  };
  config = lib.mkIf config.mpv.enable {
    stylix.targets.mpv.enable = false;
    programs.mpv = {
      enable = true;
      scripts =
        with pkgs.mpvScripts;
        with outputs.packages.${pkgs.system};
        [
          mpris
          thumbfast
          webtorrent-mpv-hook
          progressbar
          detect-image
          minimap
          image-positioning
          status-line
          ruler
          freeze-window
          equalizer
          youtube-upnext
        ];
      defaultProfiles = [ "high-quality" ];
      config = {
        ontop = "no";
        osc = "no";
        image-display-duration = "inf";
        loop-playlist = "inf";

        # video
        gpu-api = "vulkan";
        hwdec = "vaapi-copy";
        vo = "gpu-next";
        gpu-context = "waylandvk";
        hr-seek-framedrop = "no";
        msg-color = "yes";
        sub-auto = "fuzzy";
        sub-file-paths = "ass,srt,sub,subs,subtitles";
        demuxer-mkv-subtitle-preroll = "yes";

        # debanding
        deband = "yes";
        deband-iterations = "4";
        deband-threshold = "35";
        deband-range = "16";
        deband-grain = "4";

        # hdr ???
        target-colorspace-hint = "yes";

        # sdr
        tone-mapping = "bt.2446a";

        # audio
        volume-max = 200;
        audio-file-auto = "fuzzy";

        # lang
        alang = "jpn,jp,eng,en,enUS,en-US";
        slang = "eng,en,jp,jap,jpn";

        sub-scale = "0.6";
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
        detect_image = {
          command_on_first_image_loaded = "enable-section image-viewer; script-message status-line-enable; set video-zoom 0; set loop-file inf; hide-text";
          command_on_image_loaded = "enable-section image-viewer; script-message status-line-enable; set video-zoom 0; set loop-file inf; hide-text";
          command_on_non_image_loaded = "disable-section image-viewer; script-message status-line-disable; set video-zoom 0; set loop-file no; hide-text";
        };
        status_line = {
          enabled = "no";
        };
      };
      profiles = {
        fast = {
          vo = "vdpau";
        };
      };
      bindings = {
        c = "script-binding progressbar/toggle-inactive-bar";
        tab = "script-binding progressbar/request-display";
        MBTN_LEFT = "script-binding progressbar/left-click";

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

        a = "cycle audio";
        A = "cycle audio down";

        MBTN_LEFT_DBL = "cycle fullscreen";

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
      extraInput = ''
        # 1 change-list script-opts append image_positioning-drag_to_pan_margin=200
        # 2 change-list script-opts append ruler-exit_bindings=8
        # 3 change-list script-opts append ruler-line_color=FF
        # 4 change-list script-opts append ruler-scale=25
        # 5 change-list script-opts append ruler-max_size=20,20

        alt+h repeatable playlist-prev
        alt+l repeatable playlist-next

        alt+left repeatable playlist-prev
        alt+right repeatable playlist-next

        N repeatable playlist-next
        P repeatable playlist-prev

        # simple reminder of default bindings
        # 1 add contrast -1
        # 2 add contrast 1
        # 3 add brightness -1
        # 4 add brightness 1
        # 5 add gamma -1
        # 6 add gamma 1
        # 7 add saturation -1
        # 8 add saturation 1

        # mouse-centric bindings
        MBTN_RIGHT {image-viewer} script-binding pan-follows-cursor
        MBTN_LEFT  {image-viewer} script-binding drag-to-pan
        MBTN_LEFT_DBL {image-viewer} ignore
        WHEEL_UP   {image-viewer} script-message cursor-centric-zoom 0.1
        WHEEL_DOWN {image-viewer} script-message cursor-centric-zoom -0.1

        # panning with the keyboard:
        # pan-image takes the following arguments
        # pan-image AXIS AMOUNT ZOOM_INVARIANT IMAGE_CONSTRAINED
        #            ^            ^                  ^
        #          x or y         |                  |
        #                         |                  |
        #   if yes, will pan by the same         if yes, stops panning if the image
        #     amount regardless of zoom             would go outside of the window

        down  {image-viewer} repeatable script-message pan-image y -0.1 yes yes
        up    {image-viewer} repeatable script-message pan-image y +0.1 yes yes
        right {image-viewer} repeatable script-message pan-image x -0.1 yes yes
        left  {image-viewer} repeatable script-message pan-image x +0.1 yes yes

        j {image-viewer} repeatable script-message pan-image y -0.1 yes yes
        k {image-viewer} repeatable script-message pan-image y +0.1 yes yes
        l {image-viewer} repeatable script-message pan-image x -0.1 yes yes
        h {image-viewer} repeatable script-message pan-image x +0.1 yes yes

        # now with more precision
        ctrl+down  {image-viewer} repeatable script-message pan-image y -0.01 yes yes
        ctrl+up    {image-viewer} repeatable script-message pan-image y +0.01 yes yes
        ctrl+right {image-viewer} repeatable script-message pan-image x -0.01 yes yes
        ctrl+left  {image-viewer} repeatable script-message pan-image x +0.01 yes yes

        ctrl+j {image-viewer} repeatable script-message pan-image y -0.01 yes yes
        ctrl+k {image-viewer} repeatable script-message pan-image y +0.01 yes yes
        ctrl+l {image-viewer} repeatable script-message pan-image x -0.01 yes yes
        ctrl+h {image-viewer} repeatable script-message pan-image x +0.01 yes yes

        # replace at will with h,j,k,l if you prefer vim-style bindings

        # on a trackpad you may want to use these
        #WHEEL_UP    repeatable script-message pan-image y -0.02 yes yes
        #WHEEL_DOWN  repeatable script-message pan-image y +0.02 yes yes
        #WHEEL_LEFT  repeatable script-message pan-image x -0.02 yes yes
        #WHEEL_RIGHT repeatable script-message pan-image x +0.02 yes yes

        # align the border of the image to the border of the window
        # align-border takes the following arguments:
        # align-border ALIGN_X ALIGN_Y
        # any value for ALIGN_* is accepted, -1 and 1 map to the border of the window
        ctrl+shift+right {image-viewer} script-message align-border -1 ""
        ctrl+shift+left  {image-viewer} script-message align-border 1 ""
        ctrl+shift+down  {image-viewer} script-message align-border "" -1
        ctrl+shift+up    {image-viewer} script-message align-border "" 1

        # reset the image
        ctrl+0  {image-viewer} no-osd set video-pan-x 0; no-osd set video-pan-y 0; no-osd set video-zoom 0

        + {image-viewer} add video-zoom 0.5
        - {image-viewer} add video-zoom -0.5; script-message reset-pan-if-visible
        = {image-viewer} no-osd set video-zoom 0; script-message reset-pan-if-visible

        ctrl+J add video-zoom -0.5
        ctrl+K add video-zoom 0.5

        e {image-viewer} script-message equalizer-toggle
        ctrl+e {image-viewer} script-message equalizer-reset

        h {image-viewer} no-osd vf toggle hflip; show-text "Horizontal flip"
        v {image-viewer} no-osd vf toggle vflip; show-text "Vertical flip"

        r {image-viewer} script-message rotate-video 90; show-text "Clockwise rotation"
        R {image-viewer} script-message rotate-video -90; show-text "Counter-clockwise rotation"
        ctrl+r {image-viewer} no-osd set video-rotate 0; show-text "Reset rotation"

        d {image-viewer} script-message ruler

        # Toggling between pixel-exact reproduction and interpolation
        a {image-viewer} cycle-values scale nearest ewa_lanczossharp

        # Toggle color management on or off
        c {image-viewer} cycle icc-profile-auto

        # Screenshot of the window output
        S {image-viewer} screenshot window

        # Toggle aspect ratio information on and off
        A {image-viewer} cycle-values video-aspect-override "-1" "no"

        p {image-viewer} script-message force-print-filename
      '';
    };
  };
}
