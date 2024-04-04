{ pkgs, ... }:
let
  browser = [ "firefox.desktop" ];

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

    "audio/*" = [ "mpv.desktop" ];
    "video/*" = [ "mpv.dekstop" ];
    "image/*" = [ "qimgv.desktop" ];
    "application/json" = browser;
    "application/pdf" = [ "org.pwmt.zathura.desktop.desktop" ];
  };
in
{
  xdg = {
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
    mimeApps.enable = true;
    mimeApps.associations.added = associations;
    mimeApps.defaultApplications = associations;
  };
}
