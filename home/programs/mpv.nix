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
        with outputs.packages.${pkgs.stdenv.hostPlatform.system};
        [
          anacreon-mpv-script
          mpv-image-viewer.detect-image
          mpv-image-viewer.equalizer
          mpv-image-viewer.freeze-window
          mpv-image-viewer.image-positioning
          mpv-image-viewer.minimap
          mpv-image-viewer.status-line
          mpris
          mpv-http-mitmytproxy
          mpv-websocket-script
          progressbar
          thumbfast
          webtorrent-mpv-hook
          sponsorblock
          mpv-youtube-srv3-subs
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

        # sdr
        tone-mapping = "bt.2446a";

        # audio
        volume-max = 200;
        audio-file-auto = "fuzzy";

        # lang
        alang = "jpn,jp,eng,en,enUS,en-US";
        slang = "eng,en,jp,jap,jpn";

        sub-scale = "0.6";

        input-ipc-server = "/tmp/mpv-socket";
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
          command_on_first_image_loaded = "enable-section image-viewer; set video-zoom 0; set loop-file inf";
          command_on_image_loaded = "enable-section image-viewer; set video-zoom 0; set loop-file inf";
          command_on_non_image_loaded = "disable-section image-viewer; script-message status-line-disable; set video-zoom 0; set loop-file no";
        };
        status_line = {
          enabled = "no";
        };
        animecards = {
          FRONT_FIELD = "Expression";
          SENTENCE_FIELD = "";
          IMAGE_FIELD = "Picture";
          SENTENCE_AUDIO_FIELD = "SentenceAudio";

          ENABLE_SUBS_TO_CLIP = "no";
          ASK_TO_OVERWRITE = "yes";
          OVERWRITE_LIMIT = 8;
          HIGHLIGHT_WORD = "no";

          AUDIO_CLIP_PADDING = 0.75;
          AUDIO_CLIP_FADE = 0.2;
          AUDIO_MONO = "yes";
          USE_MPV_VOLUME = "no";

          AUTOPLAY_AUDIO = "no";
          IMAGE_FORMAT = "png";

          # Resize image to this height (in pixels).
          # Preserves aspect ratio. (0 = keep original resolution)
          IMAGE_HEIGHT = 480;

          WRITE_MISCINFO = "yes";
          MISCINFO_FIELD = "MiscInfo";

          # Pattern for the Misc Info content:
          #   %f   = filename (without extension)
          #   %F   = filename (with extension)
          #   %t   = timestamp (HH:MM:SS)
          #   %T   = timestamp with milliseconds (HH:MM:SS:MLS)
          #   <br> = Next line tag
          MISCINFO_PATTERN = "%f (%t)";
        };
        minimap = {
          enabled = false;
        };
      };
      profiles = {
        fast = {
          vo = "vdpau";
        };
      };
      bindings = {
        t = "script-binding webtorrent/toggle-info";
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

        "alt+h" = "repeatable playlist-prev";
        "alt+l" = "repeatable playlist-next";

        o = ''cycle-values loop-file "inf" "no"'';
        O = "ab-loop";
        i = "show-text \${playlist}";
        I = "show-text \${track-list}";

        PGUP = "add chapter 1";
        PGDWN = "add chapter -1";

        C = "af toggle dynaudnorm=f=75:g=15";

        g = "ignore";
        G = "add sub-scale 0.1"; # mpv default that sponsorblock overrides

        MBTN_MID = "script-binding update-anki-card";

        "-" = "cycle-values scale nearest ewa_lanczossharp";

        e = "{image-viewer} script-message equalizer-toggle";
        "ctrl+e" = "{image-viewer} script-message equalizer-reset";

        r = "{image-viewer} script-message rotate-video 90";
        R = "{image-viewer} script-message rotate-video -90";
        "ctrl+r" = "{image-viewer} no-osd set video-rotate 0";

        "ctrl+i" =
          "{image-viewer} disable-section image-viewer; script-message status-line-disable; set loop-file no; set video-zoom 0; no-osd set panscan 0; no-osd set video-pan-x 0; no-osd set video-pan-y 0; no-osd set video-align-x 0; no-osd set video-align-y 0"; # needed as some files get incorrectly detected as images
      };
      extraInput = ''
        MBTN_RIGHT {image-viewer} script-binding pan-follows-cursor
        MBTN_LEFT  {image-viewer} script-binding drag-to-pan
        MBTN_LEFT_DBL {image-viewer} ignore
        WHEEL_UP   {image-viewer} no-osd script-binding cursor-centric-zoom 0.1
        WHEEL_DOWN {image-viewer} no-osd script-binding cursor-centric-zoom -0.1

        j {image-viewer} repeatable script-message pan-image y -0.1 yes no
        k {image-viewer} repeatable script-message pan-image y +0.1 yes no
        l {image-viewer} repeatable script-message pan-image x -0.1 yes no
        h {image-viewer} repeatable script-message pan-image x +0.1 yes no

        J {image-viewer} repeatable script-message pan-image y -0.01 yes no
        K {image-viewer} repeatable script-message pan-image y +0.01 yes no
        L {image-viewer} repeatable script-message pan-image x -0.01 yes no
        H {image-viewer} repeatable script-message pan-image x +0.01 yes no

        v {image-viewer} no-osd vf toggle vflip
        V {image-viewer} no-osd vf toggle hflip

        S {image-viewer} screenshot window

        m {image-viewer} script-binding minimap-toggle

        s {image-viewer} script-binding status-line-toggle
      ''; # needed for duplicates
    };
  };
}
