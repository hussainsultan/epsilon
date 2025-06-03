{config, pkgs, ... }:
{
  home.username = "hussainsultan";
  home.homeDirectory = "/Users/hussainsultan";
  home.stateVersion = "23.11";

  programs.tmux = {
    enable = true;
    prefix = "C-s";
    mouse = true;
    keyMode = "vi";
    escapeTime = 0;
    terminal = "tmux-256color";
    plugins = with pkgs.tmuxPlugins; [
      vim-tmux-navigator
      {
        plugin = catppuccin;
        extraConfig = ''
          set -g @catppuccin_window_left_separator ""
          set -g @catppuccin_window_right_separator " "
          set -g @catppuccin_window_middle_separator " █"
          set -g @catppuccin_window_number_position "right"
          set -g @catppuccin_window_default_fill "number"
          set -g @catppuccin_window_default_text "#W"
          set -g @catppuccin_window_current_fill "number"
          set -g @catppuccin_window_current_text "#W"
          set -g @catppuccin_status_modules_right "directory session"
          set -g @catppuccin_status_left_separator  " "
          set -g @catppuccin_status_right_separator ""
          set -g @catppuccin_status_right_separator_inverse "no"
          set -g @catppuccin_status_fill "icon"
          set -g @catppuccin_status_connect_separator "no"
          set -g @catppuccin_directory_text "#{pane_current_path}"
        '';
      }
      sensible
    ];
    extraConfig = ''
      # Custom key bindings
      unbind r
      bind r source-file ~/.config/tmux/tmux.conf
      bind-key h select-pane -L
      bind-key j select-pane -D
      bind-key k select-pane -U
      bind-key l select-pane -R

      # Override default pane creation to ensure environment
      bind-key '"' split-window -v -c "#{pane_current_path}"
      bind-key '%' split-window -h -c "#{pane_current_path}"
      bind-key 'c' new-window -c "#{pane_current_path}"

      set-environment -g PATH "/run/current-system/sw/bin:${config.home.homeDirectory}/.nix-profile/bin:/etc/profiles/per-user/${config.home.username}/bin:/nix/var/nix/profiles/default/bin:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

      set-option -g default-command "${pkgs.zsh}/bin/zsh -l"
      set-option -g default-shell "${pkgs.zsh}/bin/zsh"

      # Update environment variables that should be inherited
      set-option -ga update-environment " NIX_PATH"
      set-option -ga update-environment " NIX_PROFILES"
      set-option -ga update-environment " NIX_SSL_CERT_FILE"
      set-option -ga update-environment " NIX_USER_PROFILE_DIR"
      set-option -ga update-environment " XDG_DATA_DIRS"
      set-option -ga update-environment " XDG_CONFIG_DIRS"
      set-option -ga update-environment " LOCALE_ARCHIVE"
      set-option -ga update-environment " UPTERM_ADMIN_SOCKET"

      # OSC 52 clipboard support for tmux
      set -g set-clipboard on
      set -g allow-passthrough on

      # Specific overrides for Alacritty + tmux
      set -as terminal-overrides ',alacritty:Ms=\E]52;c;%p2%s\007'
      set -as terminal-overrides ',tmux*:Ms=\E]52;c;%p2%s\007'
      set -as terminal-features ',alacritty:clipboard'
      set -as terminal-features ',*:clipboard'

      # Force tmux to pass through OSC sequences to the parent terminal
      set -as terminal-features ',*:Ms=\E]52;c;%p2%s\007'
      set -g set-clipboard on
      set -g allow-passthrough on
      # Fix cursor shape https://github.com/neovim/neovim/issues/5096#issuecomment-469027417
      set -ga terminal-overrides '*:Ss=\E[%p1%d q:Se=\E[ q'

      # Undercurl support
      set -as terminal-overrides ',*:Smulx=\E[4::%p1%dm'

      # Underscore colours - needs tmux-3.0
      set -as terminal-overrides ',*:Setulc=\E[58::2::%p1%{65536}%/%d::%p1%{256}%/%{255}%&%d::%p1%{255}%&%d%;m'

      # Status interval
      set -g status-interval 0
    '';
  };

  home.sessionPath = [
    "/run/current-system/sw/bin"
    "${config.home.homeDirectory}/.nix-profile/bin"
    "/usr/bin"
    "/bin"
    "/usr/sbin"
    "/sbin"
  ];

  # Add session variables for Nix
  home.sessionVariables = {
    NIX_PATH = "$HOME/.nix-defexpr/channels:/nix/var/nix/profiles/per-user/root/channels";
  };

  programs.zsh = {
    enable = true;
    shellAliases = {
      vim= "nvim";
      cd = "z";
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

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
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
    tmux
    watch
    uv
    eza
    fd
    ripgrep
    fzf
    git
    gh
    htop
    btop
    curl
    wget
    jq
    yq
    tree
    asciinema
    presenterm
    colima
    docker
    nodejs_24
  ];

  programs.direnv = {
   enable= true;
   enableZshIntegration= true;
  };

  programs.home-manager.enable = true;
}
