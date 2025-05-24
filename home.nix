{ config, pkgs, ... }:
{
  home.username = "hussainsultan";
  home.homeDirectory = "/Users/hussainsultan";
  home.stateVersion = "23.11";

  programs.tmux = {
    enable = true;
  };

  # Link tmux.conf file
  home.file.".tmux.conf".source = ./configs/tmux/tmux.conf;

  home.sessionPath = [
    "/run/current-system/sw/bin"
    "${config.home.homeDirectory}/.nix-profile/bin"
    "/usr/local/bin"
    "/usr/bin"
    "/bin"
    "/usr/sbin"
    "/sbin"
  ];

  programs.zsh = {
    enable = true;
    shellAliases = {
      ls = "eza --color=always --group-directories-first";
      ll = "eza -l --color=always --group-directories-first --git";
      la = "eza -la --color=always --group-directories-first --git";
      lt = "eza --tree --color=always --group-directories-first";
      l = "eza -lah --color=always --group-directories-first --git";
      g = "git";
      gc = "git commit";
      gf = "git fetch";
      gs = "git status";
      gd = "git diff";
      gg = "git grep -n";
      gpo = "git push origin";
      gco = "git checkout";
      ga = "git add";
      gai = "git add -i";
      gap = "git add -p";
      gau = "git add -u";
      gcw = "git commit -m wip";
      gcm = "git commit -m";
      gpu = "git push";
      gpl = "git pull";
      gdc = "git diff --cached";
      gds = "git diff --staged";
      gre = "git checkout --";
      gus = "git reset HEAD";
      gla = "git log --graph --oneline --all";
      gll = "git log --graph --oneline";
      glp = "git log -p";
      gls = "git ls-files";
      grl = "git rebase -i HEAD^^";
      gwc = "git whatchanged";
      git-commit-empty-initial-commit = "git commit --allow-empty -m 'initial commit'";
      gb = "git branch";
      glog = "git log --oneline --graph --decorate";
    };

    history = {
      size = 10000;
      path = "${config.xdg.dataHome}/zsh/history";
    };
  };

  programs.starship = {
    enable = true;
    settings = builtins.fromTOML (builtins.readFile ./configs/starship/starship.toml);
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    extraLuaConfig = builtins.readFile ./configs/nvim/init.lua;
  };

  # Install packages
  home.packages = with pkgs; [
    eza
    fd
    ripgrep
    fzf
    git
    gh
    htop
    curl
    wget
    jq
    yq
    tree
  ];

  programs.home-manager.enable = true;
}
