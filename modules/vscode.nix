{ config, pkgs, ... }: {
  programs.vscode = {
    enableUpdateCheck = false;
    userSettings = {
      "workbench.colorTheme" = "One Dark Pro";
      "workbench.iconTheme" = "material-icon-theme";
      "editor.minimap.enabled" = false;
      "editor.tabSize" = 2;
      "workbench.welcomePage.extraAnnouncements" = false;
      "workbench.startupEditor" = "none";
      "security.workspace.trust.untrustedFiles" = "open";
      "editor.bracketPairColorization.enabled" = false;
    };
  };
}