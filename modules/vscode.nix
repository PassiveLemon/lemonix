{ config, pkgs, ... }: {
  programs.vscode = {
    package = pkgs.vscodium;
    enableUpdateCheck = false;
    #userSettings = {
    #  "workbench.colorTheme" = "vs-theme-template";
    #  "workbench.iconTheme" = "material-icon-theme";
    #  "editor.bracketPairColorization.enabled" = false;
    #  "editor.minimap.enabled" = false;
    #  "editor.tabSize" = 2;
    #  "workbench.welcomePage.extraAnnouncements" = false;
    #  "workbench.startupEditor" = "none";
    #  "security.workspace.trust.untrustedFiles" = "open";
    #  "emmet.excludeLanguages" = [ "html" ];
    #};
  };
}