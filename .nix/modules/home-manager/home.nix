{
  imports = [
    ./spicetify.nix
  ];

  home.username = "lemon";
  home.homeDirectory = "/home/lemon";

  home.stateVersion = "22.05";

  # Configs
  programs = {
    home-manager.enable = true;
    spicetify = {
      enable = true;
      theme = "catppuccin-mocha";
      # OR 
      # theme = spicetify-nix.pkgSets.${pkgs.system}.themes.catppuccin-mocha;
      colorScheme = "flamingo";

      enabledExtensions = [
        "fullAppDisplay.js"
        "shuffle+.js"
    ];
  };
}