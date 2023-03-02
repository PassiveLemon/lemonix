{ config, pkgs, ... }: {
  programs.vscode = {
    enable = true;
    package = pkgs.unstable.vscodium;
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
  nixpkgs = {
    config = {
      packageOverrides = pkgs: {
        unstable = import (fetchTarball https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz) {
          config = config.nixpkgs.config;
        };
      };
    };
  };
}