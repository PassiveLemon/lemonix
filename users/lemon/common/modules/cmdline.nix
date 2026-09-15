{ pkgs, ... }: {
  home.packages = with pkgs; [
    tym
    nh eza bat comma fend
  ];

  programs = {
    home-manager.enable = true;
    fish = {
      enable = true;
      interactiveShellInit = ''
        set fish_greeting

        set hydro_symbol_prompt ">"
        set hydro_color_pwd 61b8ff
        set hydro_color_git f05d6b
        set hydro_color_error f05d6b
        set hydro_color_prompt 93cb6b
        set hydro_color_duration cd61ec
      '';
      shellAliases = {
        # Core
        t = "tym";
        ls = "eza -lgF --group-directories-first";
        bat = "bat --theme=Lemon";
        # Nix
        nos = "nh os switch ~/Documents/GitHub/lemonix";
        nhs = "nh home switch ~/Documents/GitHub/lemonix";
        nb = "nix build";
        nd = "nix develop";
        nr = "nix run";
        ns = "nix shell";
        nfu = "nix flake update";
        npr = "nixpkgs-review rev --print-result HEAD";
        cma = "comma";
        # Git
        cdr = "cd $(git rev-parse --show-toplevel)";
        g = "git status";
        gl = "git log --reverse";
        ga = "git add";
        gc = "git commit -S";
        gs = "git stash";
        gp = "git push";
        grb = "git rebase";
        grs = "git reset";
        # Other
        dc = "docker compose";
      };
      plugins = [
        { name = "hydro"; src = pkgs.fishPlugins.hydro.src; }
      ];
    };
    git = {
      enable = true;
      signing = {
        format = "ssh";
        key = "~/.ssh/id_ed25519.pub";
        signByDefault = true;
      };
      settings = {
        core.pager = "less +G";
        url."ssh://git@github.com/".insteadOf = "https://github.com/";
      };
    };
    gh = {
      enable = true;
      settings.git_protocol = "ssh";
    };
  };
}

