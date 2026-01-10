{ lib, ... }:
let
  inherit (lib) genAttrs mergeAttrsList;
  genMimeApps = app: types: (genAttrs types (name: app));
    
in
{
  xdg = {
    mime.enable = true;
    mimeApps = {
      enable = true;
      defaultApplications = mergeAttrsList [
        (genMimeApps "firefox.desktop" [
          "application/x-extension-htm"
          "application/x-extension-html"
          "application/x-extension-shtml"
          "application/x-extension-xht"
          "application/x-extension-xhtml"
          "application/xhtml+xml"
          "text/html"
          "x-scheme-handler/chrome"
          "x-scheme-handler/http"
          "x-scheme-handler/https"
        ])
        (genMimeApps "org.gnome.Loupe.desktop" [
          "image/bmp"
          "image/gif"
          "image/heic"
          "image/heif"
          "image/jpeg"
          "image/png"
          "image/svg+xml"
          "image/webp"
        ])
        (genMimeApps "mpv.desktop" [
          "audio/flac"
          "audio/matroska"
          "audio/mpeg"
          "audio/ogg"
          "audio/opus"
          "audio/vorbis"
          "audio/wav"
          "audio/x-opus+ogg"
          "video/matroska"
          "video/mp4"
          "video/mpeg"
          "video/MPV"
          "video/ogg"
          "video/quicktime"
          "video/webm"
          "video/x-matroska"
        ])
        {
          "application/octet-stream" = "org.lite_xl.lite_xl.desktop";
          "application/pdf" = "org.gnome.Papers.desktop";
          "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" = "onlyoffice-desktopeditors.desktop";
          "application/vnd.openxmlformats-officedocument.wordprocessingml.document" = "onlyoffice-desktopeditors.desktop";
          "application/zip" = "xarchiver.desktop";
          "inode/directory" = "pcmanfm.desktop";
          "text/plain" = "org.lite_xl.lite_xl.desktop";
        }
      ];
    };
    configFile = {
      "mimeapps.list".force = true;
    };
    desktopEntries = {
      "pcmanfm-desktop-pref" = {
        name = "Desktop Preferences";
        noDisplay = true;
      };
    };
  };
}

