{ lib, osConfig, ... }:
let
  browser = [ "firefox.desktop" ];
  mpv = [ "mpv.desktop" ];

  associations = {
    "text/html" = browser;
    "x-scheme-handler/http" = browser;
    "x-scheme-handler/https" = browser;
    "x-scheme-handler/ftp" = browser;
    "x-scheme-handler/about" = browser;
    "x-scheme-handler/unknown" = browser;
    "application/x-extension-htm" = browser;
    "application/x-extension-html" = browser;
    "application/x-extension-shtml" = browser;
    "application/xhtml+xml" = browser;
    "application/x-extension-xhtml" = browser;
    "application/x-extension-xht" = browser;
    "application/json" = browser;

    "audio/*" = mpv;
    "video/*" = mpv;
    "image/*" = mpv;

    "image/avif" = mpv;
    "image/bmp" = mpv;
    "image/gif" = mpv;
    "image/heic" = mpv;
    "image/jpeg" = mpv;
    "image/jp2" = mpv;
    "image/jpeg2000" = mpv;
    "image/jpeg2000-image" = mpv;
    "image/jpx" = mpv;
    "image/jxl" = mpv;
    "image/png" = mpv;
    "image/svg+xml" = mpv;
    "image/tiff" = mpv;
    "image/webp" = mpv;
    "image/x-bmp" = mpv;
    "image/x-jpeg2000-image" = mpv;
    "image/x-portable-bitmap" = mpv;
    "image/x-portable-graymap" = mpv;
    "image/x-portable-pixmap" = mpv;
    "image/x-tga" = mpv;
    "image/x-xbitmap" = mpv;
    "image/x-xpixmap" = mpv;
    "image/vnd.microsoft.icon" = mpv;

    "application/pdf" = [ "org.pwmt.zathura-pdf-mupdf.desktop" ];
  };
in
{
  xdg = lib.mkIf osConfig.graphics.enable {
    # userDirs = {
    #   enable = true;
    #   documents = "$HOME/documents";
    #   download = "$HOME/download";
    #   videos = "$HOME/videos";
    #   music = "$HOME/music";
    #   pictures = "$HOME/pictures";
    #   desktop = "$HOME/desktop";
    #   publicShare = "$HOME/other";
    #   templates = "$HOME/other";
    # };
    mimeApps = {
      enable = true;
      associations.added = associations;
      defaultApplications = associations;
    };
  };
}
